#!/usr/bin/env bash
set -e

# ==============================================================================
# ورتِّله (Rattil) - Release Script Router / Local Build Fallback
# Re-routes to the automated GitHub Actions release workflow (scripts/release.sh)
# Unless explicitly invoked with --local or --offline for manual local testing.
# ==============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

APP_NAME="rattil"

# If user didn't explicitly request a local compilation, forward to cloud release
if [ "$1" != "--local" ] && [ "$1" != "--offline" ]; then
    echo "================================================================="
    echo "🚀 تنبيه: عمليات بناء الريليس والنشر لـ Google Play أصبحت سحابية!"
    echo "   تتم تلقائياً عبر GitHub Actions دون الحاجة لبناء محلي أو مجلد releases/."
    echo "   جاري التوجيه إلى سكربت الريليس السحابي: scripts/release.sh"
    echo "   (إذا كنت بحاجة لبناء محلي للاختبار اليدوي مرر: --local)"
    echo "================================================================="
    exec bash "$PROJECT_ROOT/scripts/release.sh" "$@"
fi

# Local compilation path (Fallback / Offline debugging only)
shift # Remove --local or --offline
echo "========================================================"
echo "🛠️  بدء بناء حزمة محلية (Offline / Local Debugging): $APP_NAME"
echo "========================================================"

# 1. قراءة الإصدار ورقم البناء من pubspec.yaml
VERSION_LINE=$(grep '^version:' pubspec.yaml | sed 's/version: //')
VERSION_NAME=$(echo "$VERSION_LINE" | cut -d'+' -f1 | tr -d '[:space:]')
BUILD_NUMBER=$(echo "$VERSION_LINE" | cut -d'+' -f2 | tr -d '[:space:]')
DATE_STAMP=$(date +"%d-%m-%Y")

echo "📦 الإصدار المستهدف: v$VERSION_NAME (Build: $BUILD_NUMBER)"
echo "📅 التاريخ: $DATE_STAMP"

# 2. إنشاء مجلد releases إذا لم يكن موجوداً
mkdir -p "$PROJECT_ROOT/releases"

# 3. التحقق من وجود ملف key.properties
KEY_PROPS="$PROJECT_ROOT/android/app/key.properties"
if [ ! -f "$KEY_PROPS" ] && [ ! -f "$PROJECT_ROOT/android/key.properties" ]; then
    echo "⚠️  تحذير: ملف key.properties غير موجود! سيتم البناء بمفاتيح الـ debug الافتراضية."
else
    echo "🔑 تم العثور على ملف إعدادات التوقيع: key.properties"
fi

ENV_ARG=""
if [ -f "$PROJECT_ROOT/.env.json" ]; then
    echo "📄 تم العثور على ملف البيئة: .env.json"
    ENV_ARG="--dart-define-from-file=.env.json"
fi

# 4. تنظيف الكاش والاعتماديات
echo "🧹 تنظيف الكاش والاعتماديات..."
flutter clean
flutter pub get

BUILD_AAB=true
BUILD_APK=false

if [ "$1" == "--apk-only" ]; then
    BUILD_AAB=false
    BUILD_APK=true
elif [ "$1" == "--apk" ] || [ "$1" == "--all" ]; then
    BUILD_APK=true
fi

# 5. بناء AAB (Google Play Store Bundle)
if [ "$BUILD_AAB" = true ]; then
    echo "⚙️  جاري بناء Android App Bundle (AAB)..."
    flutter build appbundle --release $ENV_ARG --android-skip-build-dependency-validation

    AAB_SOURCE="$PROJECT_ROOT/build/app/outputs/bundle/release/app-release.aab"
    AAB_TARGET="$PROJECT_ROOT/releases/${APP_NAME}-v${VERSION_NAME}-release.aab"
    AAB_DATED="$PROJECT_ROOT/releases/${APP_NAME}-v${VERSION_NAME}-build${BUILD_NUMBER}-${DATE_STAMP}.aab"

    if [ -f "$AAB_SOURCE" ]; then
        cp "$AAB_SOURCE" "$AAB_TARGET"
        cp "$AAB_SOURCE" "$AAB_DATED"
        echo "✅ تم نسخ الـ AAB بنجاح إلى: $AAB_TARGET"
        echo "✅ تم نسخ الـ AAB المؤرخ إلى: $AAB_DATED"
        echo "📊 الحجم: $(ls -lh "$AAB_TARGET" | awk '{print $5}')"
        sha256sum "$AAB_TARGET" > "${AAB_TARGET}.sha256"
        sha256sum "$AAB_DATED" > "${AAB_DATED}.sha256"
    else
        echo "❌ خطأ: لم يتم العثور على ملف $AAB_SOURCE"
        exit 1
    fi
fi

# 6. بناء APK (اختياري / للتوزيع المباشر والتجربة الميدانية)
if [ "$BUILD_APK" = true ]; then
    echo "⚙️  جاري بناء APK للتوزيع المباشر والتجربة الميدانية..."
    flutter build apk --release $ENV_ARG
    APK_SOURCE="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"
    APK_STANDARD="$PROJECT_ROOT/releases/${APP_NAME}-v${VERSION_NAME}-release.apk"
    APK_DATED="$PROJECT_ROOT/releases/${APP_NAME}-v${VERSION_NAME}-build${BUILD_NUMBER}-${DATE_STAMP}.apk"

    if [ -f "$APK_SOURCE" ]; then
        cp "$APK_SOURCE" "$APK_STANDARD"
        cp "$APK_SOURCE" "$APK_DATED"
        echo "✅ تم نسخ الـ APK القياسي إلى: $APK_STANDARD"
        echo "✅ تم نسخ الـ APK المؤرخ إلى: $APK_DATED"
        echo "📊 الحجم: $(ls -lh "$APK_STANDARD" | awk '{print $5}')"
        sha256sum "$APK_STANDARD" > "${APK_STANDARD}.sha256"
        sha256sum "$APK_DATED" > "${APK_DATED}.sha256"
    else
        echo "❌ خطأ: لم يتم العثور على ملف $APK_SOURCE"
        exit 1
    fi
fi

echo "========================================================"
echo "🎉 اكتملت عملية البناء المحلي بنجاح!"
echo "📁 محتويات مجلد releases/:"
ls -lh "$PROJECT_ROOT/releases/"
echo "========================================================"
