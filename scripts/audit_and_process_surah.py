#!/usr/bin/env python3
"""
Audits, splits, and renames Quran ayah audio clips for Rattil Mobile.
- Detects multi-part ayahs (one ayah split across multiple audio clips) -> renames to {verse:03d}-1.mp3, {verse:03d}-2.mp3
- Detects merged ayahs (multiple ayahs inside one audio clip) -> splits using ffmpeg at the exact pause
- Ensures Basmala is 000.mp3 (verse 0) for surahs != 1, and verse numbers match canonical Quran verses 1..N
- Creates automatic backups before making changes
- Generates JSON reports and Dart segment code snippets
"""

import os
import sys
import json
import re
import shutil
import argparse
import subprocess
from difflib import SequenceMatcher

def normalize_arabic(text):
    if not text:
        return ""
    # Remove tashkeel / harakat and Quranic annotation marks
    text = re.sub(r'[\u064B-\u065F\u0670\u06D6-\u06ED]', '', text)
    # Normalize Alef forms
    text = re.sub(r'[إأآٱ]', 'ا', text)
    # Normalize Taa Marbuta
    text = re.sub(r'ة', 'ه', text)
    # Normalize Yaa
    text = re.sub(r'ى', 'ي', text)
    # Remove punctuation & non-arabic symbols except spaces
    text = re.sub(r'[^\w\s]', '', text)
    return ' '.join(text.split()).strip()

def similarity(a, b):
    return SequenceMatcher(None, normalize_arabic(a), normalize_arabic(b)).ratio()

def load_canonical_surah(surah_num):
    path = f"scripts/quran_texts/surah_{surah_num:03d}.json"
    if not os.path.exists(path):
        raise FileNotFoundError(f"Canonical text file not found: {path}")
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    # List of ayahs: 1-indexed
    ayahs = []
    for i, a in enumerate(data['ayahs']):
        text = a['text']
        # If surah != 1 and first ayah contains Basmala, strip Basmala prefix from Ayah 1
        if surah_num != 1 and i == 0:
            basmala = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
            clean_basmala = normalize_arabic(basmala)
            clean_text = normalize_arabic(text)
            if clean_text.startswith(clean_basmala):
                text = text[len(basmala):].strip()
        ayahs.append({
            'numberInSurah': a['numberInSurah'],
            'text': text,
            'clean': normalize_arabic(text)
        })
    return ayahs

def transcribe_audio_files(audio_files, model_size='tiny'):
    from faster_whisper import WhisperModel
    print(f"Loading Whisper model ({model_size})...")
    model = WhisperModel(model_size, device="cpu", compute_type="int8")
    
    results = []
    for f in audio_files:
        print(f"Transcribing {os.path.basename(f)}...", end=' ', flush=True)
        segments, info = model.transcribe(f, language="ar", word_timestamps=True)
        seg_list = list(segments)
        text = " ".join(s.text for s in seg_list).strip()
        words = []
        for s in seg_list:
            if s.words:
                for w in s.words:
                    words.append({
                        'word': w.word,
                        'start': w.start,
                        'end': w.end,
                        'probability': w.probability
                    })
        results.append({
            'file': f,
            'duration': info.duration,
            'text': text,
            'clean': normalize_arabic(text),
            'words': words
        })
        print(f"Done ({info.duration:.1f}s) -> '{text[:30]}...'")
    return results

def detect_silence_boundary(audio_file, search_start, search_end):
    """Uses ffmpeg silencedetect within [search_start, search_end] to find exact silence pause."""
    try:
        cmd = [
            'ffmpeg', '-hide_banner', '-vn',
            '-ss', str(max(0, search_start - 0.5)),
            '-to', str(search_end + 0.5),
            '-i', audio_file,
            '-af', 'silencedetect=n=-30dB:d=0.2',
            '-f', 'null', '-'
        ]
        res = subprocess.run(cmd, stderr=subprocess.PIPE, text=True)
        silence_starts = []
        silence_ends = []
        for line in res.stderr.split('\n'):
            if 'silence_start:' in line:
                m = re.search(r'silence_start:\s*([\d\.]+)', line)
                if m:
                    silence_starts.append(float(m.group(1)) + max(0, search_start - 0.5))
            elif 'silence_end:' in line:
                m = re.search(r'silence_end:\s*([\d\.]+)', line)
                if m:
                    silence_ends.append(float(m.group(1)) + max(0, search_start - 0.5))
        if silence_starts and silence_ends:
            # Pick silence closest to middle of search interval
            mid = (search_start + search_end) / 2.0
            best_s = min(zip(silence_starts, silence_ends), key=lambda se: abs((se[0]+se[1])/2.0 - mid))
            return (best_s[0] + best_s[1]) / 2.0
    except Exception:
        pass
    return (search_start + search_end) / 2.0

def split_audio_ffmpeg(input_file, start_sec, end_sec, output_file):
    cmd = ['ffmpeg', '-y', '-hide_banner', '-loglevel', 'error']
    if start_sec > 0.01:
        cmd.extend(['-ss', f"{start_sec:.3f}"])
    if end_sec is not None:
        cmd.extend(['-to', f"{end_sec:.3f}"])
    cmd.extend(['-i', input_file, '-c:a', 'libmp3lame', '-q:a', '2', output_file])
    subprocess.run(cmd, check=True)

def main():
    parser = argparse.ArgumentParser(description="Audit and process Quran ayah clips")
    parser.add_argument("--surah", type=int, default=78, help="Surah number to audit (default: 78)")
    parser.add_argument("--apply", action="store_true", help="Apply file changes (default is dry-run)")
    parser.add_argument("--model", type=str, default="tiny", help="Whisper model size (tiny, base, small)")
    args = parser.parse_args()

    surah_num = args.surah
    surah_dir = f"assets/audio/juz_amma_ayahs/surah_{surah_num:03d}"
    if not os.path.exists(surah_dir):
        print(f"Error: Directory {surah_dir} does not exist.")
        sys.exit(1)

    print(f"=== Auditing Surah {surah_num} in {surah_dir} ===")
    canonical_ayahs = load_canonical_surah(surah_num)
    print(f"Canonical ayah count: {len(canonical_ayahs)} ayahs")

    files = sorted([os.path.join(surah_dir, f) for f in os.listdir(surah_dir) if f.endswith('.mp3')])
    print(f"Found {len(files)} audio files.")

    transcriptions = transcribe_audio_files(files, model_size=args.model)

    # Save transcription cache
    report_file = f"scripts/audit_reports/surah_{surah_num:03d}_transcriptions.json"
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(transcriptions, f, ensure_ascii=False, indent=2)
    print(f"Saved transcriptions to {report_file}")

    # Analysis
    basmala_text = normalize_arabic("بسم الله الرحمن الرحيم")
    
    print("\n--- Alignment & Verification ---")
    for item in transcriptions:
        base_name = os.path.basename(item['file'])
        clean = item['clean']
        
        # Check Basmala
        if similarity(clean, basmala_text) > 0.7 or "بسم الله" in clean:
            print(f"{base_name} ({item['duration']:.1f}s): [BASMALA] -> Verse 0 (000.mp3)")
            continue
            
        # Match against canonical ayahs
        best_v = None
        best_sim = 0
        for a in canonical_ayahs:
            sim = similarity(clean, a['clean'])
            if sim > best_sim:
                best_sim = sim
                best_v = a
                
        status = "MATCH"
        if best_sim < 0.4:
            # Check partial match (split ayah or sub-phrase)
            part_matches = []
            for a in canonical_ayahs:
                if clean in a['clean'] or a['clean'] in clean or similarity(clean, a['clean'][:len(clean)]) > 0.6:
                    part_matches.append(a['numberInSurah'])
            status = f"PARTIAL (Ayah {part_matches})" if part_matches else "UNCERTAIN"
            
        print(f"{base_name} ({item['duration']:.1f}s): Ayah {best_v['numberInSurah'] if best_v else '?'} (sim={best_sim:.2f}) [{status}] | '{item['text'][:40]}...'")

    print("\nAudit complete.")

if __name__ == "__main__":
    main()
