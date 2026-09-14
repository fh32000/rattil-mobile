#!/usr/bin/env python3
"""
Ayah Audio Renaming Automation Script
======================================
Splits a specific ayah into multiple part files (e.g. 15-1, 15-2)
and shifts all subsequent files backward by (parts - 1).

Example usage:
  python3 scripts/rename_ayah_parts.py --surah 78 --ayah 15 --parts 2 --dry-run
  python3 scripts/rename_ayah_parts.py --surah 78 --ayah 15 --parts 2 --apply
"""

import os
import sys
import re
import argparse
import shutil

def rename_ayah_parts(surah: int, ayah: int, parts: int = 2, dry_run: bool = True):
    base_dir = f"assets/audio/juz_amma_ayahs/surah_{surah:03d}"
    if not os.path.isdir(base_dir):
        print(f"Error: Directory not found: {base_dir}")
        return False

    files = sorted([f for f in os.listdir(base_dir) if f.endswith(".mp3")])
    if not files:
        print(f"Error: No mp3 files found in {base_dir}")
        return False

    print(f"Found {len(files)} files in {base_dir}")

    # Build rename plan
    # Case: The ayah starts at file index (e.g. 15 for ayah 15)
    # The files to be converted into parts:
    #   ayah -> ayah-1
    #   ayah+1 -> ayah-2
    #   ...
    #   ayah+(parts-1) -> ayah-parts
    # Subsequent files from ayah+parts to end:
    #   ayah+parts (e.g. 17) -> ayah+1 (e.g. 16)
    #   ayah+parts+1 (e.g. 18) -> ayah+2 (e.g. 17)
    #   ...
    #   shift = parts - 1

    shift = parts - 1
    rename_plan = [] # list of (old_name, new_name)

    # Let's inspect files
    file_map = {}
    for f in files:
        m = re.match(r"^(\d+)(?:[-_](\d+))?\.mp3$", f)
        if m:
            base_num = int(m.group(1))
            file_map[base_num] = f

    # Verify that the files to split exist
    for p in range(parts):
        target_num = ayah + p
        if target_num not in file_map:
            print(f"Error: Target file for ayah {target_num} ({target_num:03d}.mp3) not found in directory!")
            return False

    # Part files
    for p in range(parts):
        old_file = file_map[ayah + p]
        new_file = f"{ayah:03d}-{p+1}.mp3"
        rename_plan.append((old_file, new_file))

    # Shift subsequent files
    max_num = max(file_map.keys())
    for curr in range(ayah + parts, max_num + 1):
        if curr in file_map:
            old_file = file_map[curr]
            new_num = curr - shift
            new_file = f"{new_num:03d}.mp3"
            rename_plan.append((old_file, new_file))

    print("\nProposed Rename Plan:")
    print("----------------------------------------")
    for old_name, new_name in rename_plan:
        print(f"  {old_name}  ==>  {new_name}")
    print("----------------------------------------")
    print(f"Total files renamed/reindexed: {len(rename_plan)}")

    if dry_run:
        print("\n[DRY RUN] No changes were made to the filesystem. Pass --apply to execute.")
        return True

    # Execution with safe temporary renaming to avoid collisions
    temp_dir = os.path.join(base_dir, "_temp_renaming")
    os.makedirs(temp_dir, exist_ok=True)

    try:
        # Step 1: Move to temp dir with target names
        for old_name, new_name in rename_plan:
            src = os.path.join(base_dir, old_name)
            dst = os.path.join(temp_dir, new_name)
            shutil.move(src, dst)

        # Step 2: Move back to base_dir
        for _, new_name in rename_plan:
            src = os.path.join(temp_dir, new_name)
            dst = os.path.join(base_dir, new_name)
            shutil.move(src, dst)

        os.rmdir(temp_dir)
        print("\n[SUCCESS] Successfully renamed all files!")
        return True

    except Exception as e:
        print(f"\n[ERROR] Failed during renaming: {e}")
        print("Restoring files from temp dir...")
        for f in os.listdir(temp_dir):
            shutil.move(os.path.join(temp_dir, f), os.path.join(base_dir, f))
        os.rmdir(temp_dir)
        return False

def main():
    parser = argparse.ArgumentParser(description="Rename split ayah audio files and shift subsequent files.")
    parser.add_argument("--surah", type=int, required=True, help="Surah number (e.g. 78)")
    parser.add_argument("--ayah", type=int, required=True, help="Ayah number that was split (e.g. 15)")
    parser.add_argument("--parts", type=int, default=2, help="Number of parts for this ayah (default: 2)")
    parser.add_argument("--apply", action="store_true", help="Execute the rename (default is dry-run)")

    args = parser.parse_args()
    rename_ayah_parts(args.surah, args.ayah, args.parts, dry_run=not args.apply)

if __name__ == "__main__":
    main()
