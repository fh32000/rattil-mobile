#!/usr/bin/env bash
set -e

# ==============================================================================
# ورتِّله (Rattil) — Automated Cloud Release Script
# Updates version, commits, pushes to main, and creates a release tag to trigger
# GitHub Actions automated build & deployment to Google Play Store and GitHub Releases.
# ==============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Color codes for clean terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ── 1. Parse CLI Options ───────────────────────────────────────────────────────
AUTO_CONFIRM=false
DRY_RUN=false
SKIP_TESTS=false
ALLOW_BRANCH=false
MERGE_TO_MAIN=false
SPECIFIED_VERSION=""
SPECIFIED_BUILD=""
BUMP_TYPE=""
RELEASE_MESSAGE=""

show_help() {
  echo -e "${BLUE}ورتِّله (Rattil) — Cloud Release Manager${NC}"
  echo "Usage: bash scripts/release.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -v, --version <X.Y.Z>   Explicit version name (e.g. 1.0.19)"
  echo "  -b, --build <NUM>       Explicit build number (e.g. 7)"
  echo "  --patch                 Increment patch version (e.g. 1.0.18 -> 1.0.19) and increment build"
  echo "  --minor                 Increment minor version (e.g. 1.0.18 -> 1.1.0) and increment build"
  echo "  --major                 Increment major version (e.g. 1.0.18 -> 2.0.0) and increment build"
  echo "  --build-only            Keep current version name, increment build number only"
  echo "  -m, --message <TEXT>    Release notes or description"
  echo "  -y, --yes, --auto       Non-interactive mode (use defaults without confirmation)"
  echo "  --merge-to-main         Automatically merge current branch into 'main' before releasing"
  echo "  --skip-tests            Skip running local pre-flight tests"
  echo "  --allow-branch          Allow release on a branch other than 'main'"
  echo "  --dry-run               Preview changes without modifying git or pushing"
  echo "  -h, --help              Show this help message"
  echo ""
  echo "Examples:"
  echo "  bash scripts/release.sh                        # Interactive mode"
  echo "  bash scripts/release.sh --patch -y             # Automatic patch bump & push"
  echo "  bash scripts/release.sh --version 1.0.19 -b 7  # Specific version & build"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -v|--version)
      SPECIFIED_VERSION="$2"
      shift 2
      ;;
    -b|--build)
      SPECIFIED_BUILD="$2"
      shift 2
      ;;
    --patch)
      BUMP_TYPE="patch"
      shift
      ;;
    --minor)
      BUMP_TYPE="minor"
      shift
      ;;
    --major)
      BUMP_TYPE="major"
      shift
      ;;
    --build-only)
      BUMP_TYPE="build-only"
      shift
      ;;
    -m|--message)
      RELEASE_MESSAGE="$2"
      shift 2
      ;;
    -y|--yes|--auto)
      AUTO_CONFIRM=true
      shift
      ;;
    --merge-to-main)
      MERGE_TO_MAIN=true
      shift
      ;;
    --skip-tests)
      SKIP_TESTS=true
      shift
      ;;
    --allow-branch)
      ALLOW_BRANCH=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      show_help
      ;;
  esac
done

# ── 2. Read Current Version & Build ───────────────────────────────────────────
if [ ! -f "pubspec.yaml" ]; then
  echo -e "${RED}❌ Error: pubspec.yaml not found in $PROJECT_ROOT${NC}"
  exit 1
fi

CURRENT_VERSION_LINE=$(grep '^version:' pubspec.yaml | sed 's/version: //')
CURRENT_VERSION=$(echo "$CURRENT_VERSION_LINE" | cut -d'+' -f1 | tr -d '[:space:]')
CURRENT_BUILD=$(echo "$CURRENT_VERSION_LINE" | cut -d'+' -f2 | tr -d '[:space:]')

if [ -z "$CURRENT_BUILD" ]; then
  CURRENT_BUILD="1"
fi

# Split version into components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
MAJOR=${MAJOR:-1}
MINOR=${MINOR:-0}
PATCH=${PATCH:-0}

SUGGESTED_BUILD=$((CURRENT_BUILD + 1))
SUGGESTED_PATCH_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))"
SUGGESTED_MINOR_VERSION="${MAJOR}.$((MINOR + 1)).0"
SUGGESTED_MAJOR_VERSION="$((MAJOR + 1)).0.0"

# Determine target version & build
TARGET_VERSION=""
TARGET_BUILD=""

if [ -n "$SPECIFIED_VERSION" ]; then
  TARGET_VERSION="$SPECIFIED_VERSION"
elif [ "$BUMP_TYPE" == "patch" ]; then
  TARGET_VERSION="$SUGGESTED_PATCH_VERSION"
elif [ "$BUMP_TYPE" == "minor" ]; then
  TARGET_VERSION="$SUGGESTED_MINOR_VERSION"
elif [ "$BUMP_TYPE" == "major" ]; then
  TARGET_VERSION="$SUGGESTED_MAJOR_VERSION"
elif [ "$BUMP_TYPE" == "build-only" ]; then
  TARGET_VERSION="$CURRENT_VERSION"
fi

if [ -n "$SPECIFIED_BUILD" ]; then
  TARGET_BUILD="$SPECIFIED_BUILD"
elif [ -n "$BUMP_TYPE" ]; then
  TARGET_BUILD="$SUGGESTED_BUILD"
fi

# ── 3. Interactive Prompts (if not fully specified and not dry-run) ───────────
if [ "$DRY_RUN" = true ]; then
  TARGET_VERSION="${TARGET_VERSION:-$SUGGESTED_PATCH_VERSION}"
  TARGET_BUILD="${TARGET_BUILD:-$SUGGESTED_BUILD}"
fi

if [ -z "$TARGET_VERSION" ] || [ -z "$TARGET_BUILD" ]; then
  echo -e "${CYAN}================================================================${NC}"
  echo -e "${CYAN}🚀 ورتِّله (Rattil) — Cloud Release Manager (GitHub CI/CD)${NC}"
  echo -e "${CYAN}================================================================${NC}"
  echo -e "📌 Current version in pubspec.yaml : ${YELLOW}v${CURRENT_VERSION} (Build ${CURRENT_BUILD})${NC}"
  echo -e "💡 Suggested patch release        : ${GREEN}v${SUGGESTED_PATCH_VERSION} (Build ${SUGGESTED_BUILD})${NC}"
  echo -e "💡 Keep version, bump build only  : ${BLUE}v${CURRENT_VERSION} (Build ${SUGGESTED_BUILD})${NC}"
  echo -e "----------------------------------------------------------------"

  if [ -z "$TARGET_VERSION" ]; then
    read -p "Enter release version name [$CURRENT_VERSION]: " USER_VERSION_INPUT
    TARGET_VERSION="${USER_VERSION_INPUT:-$CURRENT_VERSION}"
  fi

  if [ -z "$TARGET_BUILD" ]; then
    read -p "Enter release build number [$SUGGESTED_BUILD]: " USER_BUILD_INPUT
    TARGET_BUILD="${USER_BUILD_INPUT:-$SUGGESTED_BUILD}"
  fi

  if [ -z "$RELEASE_MESSAGE" ]; then
    read -p "Enter release summary / message (optional): " USER_MSG_INPUT
    RELEASE_MESSAGE="$USER_MSG_INPUT"
  fi
fi

# Validate inputs
if ! [[ "$TARGET_BUILD" =~ ^[0-9]+$ ]]; then
  echo -e "${RED}❌ Error: Build number must be an integer, got: '$TARGET_BUILD'${NC}"
  exit 1
fi

if ! [[ "$TARGET_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
  echo -e "${RED}❌ Error: Version format should be X.Y.Z, got: '$TARGET_VERSION'${NC}"
  exit 1
fi

DATE_STAMP=$(date +"%d-%m-%Y")
TAG_NAME="v${TARGET_VERSION}"

# Check if tag already exists in local or remote repository
if git rev-parse "$TAG_NAME" >/dev/null 2>&1 || git ls-remote --tags origin "$TAG_NAME" 2>/dev/null | grep -q "$TAG_NAME"; then
  # If vX.Y.Z already exists, distinguish with build number tag
  TAG_NAME="v${TARGET_VERSION}+${TARGET_BUILD}"
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo ""
echo -e "${CYAN}----------------------------------------------------------------${NC}"
echo -e "📦 Target Version    : ${GREEN}v${TARGET_VERSION}+${TARGET_BUILD}${NC}"
echo -e "🏷️  Release Tag      : ${GREEN}${TAG_NAME}${NC}"
echo -e "📅 Release Date     : ${BLUE}${DATE_STAMP}${NC}"
echo -e "🌿 Target Branch    : ${CYAN}main${NC} (Current: ${YELLOW}${CURRENT_BRANCH}${NC})"
if [ -n "$RELEASE_MESSAGE" ]; then
  echo -e "📝 Release Notes    : ${YELLOW}${RELEASE_MESSAGE}${NC}"
fi
echo -e "${CYAN}----------------------------------------------------------------${NC}"

# ── 4. Dry-Run Check ──────────────────────────────────────────────────────────
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}🧪 DRY RUN MODE — No files will be modified or pushed.${NC}"
  echo "Would switch/merge branch: $CURRENT_BRANCH -> main"
  echo "Would update pubspec.yaml to: version: ${TARGET_VERSION}+${TARGET_BUILD}"
  echo "Would update app_constants.dart to: appVersion = '${TARGET_VERSION}', appReleaseDate = '${DATE_STAMP}'"
  echo "Would commit: release: v${TARGET_VERSION} (Build ${TARGET_BUILD})"
  echo "Would push to: origin main"
  echo "Would tag: ${TAG_NAME}"
  echo "Would push tag: origin ${TAG_NAME}"
  echo "Would trigger GitHub Actions -> Google Play Store & GitHub Release."
  exit 0
fi

if [ "$AUTO_CONFIRM" != true ]; then
  read -p "Proceed with release to Google Play & GitHub? (y/N): " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Release cancelled by user.${NC}"
    exit 0
  fi
fi

# ── 5. Git Branch & Working Tree Validation ───────────────────────────────────
if [ "$CURRENT_BRANCH" != "main" ] && [ "$ALLOW_BRANCH" != true ]; then
  echo -e "${YELLOW}⚠️  Notice: You are currently on branch '$CURRENT_BRANCH'. Production releases are released on 'main'.${NC}"
  
  CHOSEN_ACTION=""
  if [ "$MERGE_TO_MAIN" = true ]; then
    CHOSEN_ACTION="1"
  elif [ "$AUTO_CONFIRM" = true ]; then
    CHOSEN_ACTION="1"
  else
    echo "Please choose an action:"
    echo "  1) Merge '$CURRENT_BRANCH' into 'main', bump version, and release (Recommended)"
    echo "  2) Switch to 'main' without merging"
    echo "  3) Release directly on current branch '$CURRENT_BRANCH'"
    echo "  4) Abort"
    read -p "Select [1-4] (default 1): " ACTION_INPUT
    CHOSEN_ACTION="${ACTION_INPUT:-1}"
  fi

  case "$CHOSEN_ACTION" in
    1)
      echo "Checking working directory status..."
      if ! git diff-index --quiet HEAD --; then
        echo -e "${YELLOW}Staging uncommitted changes on '$CURRENT_BRANCH'...${NC}"
        git add -A
        git commit -m "chore: save working changes before release merge" || true
      fi
      echo "Checking out main..."
      git checkout main
      echo "Pulling latest main..."
      git pull origin main
      echo "Merging '$CURRENT_BRANCH' into main..."
      git merge --no-ff "$CURRENT_BRANCH" -m "Merge branch '$CURRENT_BRANCH' into main for release v${TARGET_VERSION}"
      CURRENT_BRANCH="main"
      ;;
    2)
      if ! git diff-index --quiet HEAD --; then
        echo -e "${RED}❌ Error: You have uncommitted changes on '$CURRENT_BRANCH'. Stash or commit them first.${NC}"
        exit 1
      fi
      echo "Checking out main..."
      git checkout main
      echo "Pulling latest main..."
      git pull origin main
      CURRENT_BRANCH="main"
      ;;
    3)
      echo -e "${YELLOW}Continuing release on current branch '$CURRENT_BRANCH'...${NC}"
      ;;
    *)
      echo -e "${RED}Release aborted by user.${NC}"
      exit 1
      ;;
  esac
fi

# ── 6. Run Pre-flight Tests (Optional) ────────────────────────────────────────
if [ "$SKIP_TESTS" != true ]; then
  echo -e "🧪 Running fast local test suite verification..."
  if ! flutter test --no-pub; then
    echo -e "${RED}❌ Error: Local tests failed. Fix test failures before creating a release.${NC}"
    echo -e "${YELLOW}Hint: Pass --skip-tests to bypass local testing if verified elsewhere.${NC}"
    exit 1
  fi
  echo -e "${GREEN}✅ All local tests passed!${NC}"
fi

# ── 7. Update Version Files ───────────────────────────────────────────────────
echo "📝 Updating version in pubspec.yaml..."
sed -i "s/^version: .*/version: ${TARGET_VERSION}+${TARGET_BUILD}/" pubspec.yaml

echo "📝 Updating constants in lib/core/constants/app_constants.dart..."
sed -i "s/static const String appVersion = '.*';/static const String appVersion = '${TARGET_VERSION}';/" lib/core/constants/app_constants.dart
sed -i "s/static const String appReleaseDate = '.*';/static const String appReleaseDate = '${DATE_STAMP}';/" lib/core/constants/app_constants.dart

# Update whatsnew files if release message is provided
if [ -n "$RELEASE_MESSAGE" ]; then
  mkdir -p distribution/whatsnew
  echo "📝 Updating distribution/whatsnew notes..."
  echo -e "تحديث جديد:\n- ${RELEASE_MESSAGE}" > distribution/whatsnew/whatsnew-ar-SA
  echo -e "New release update:\n- ${RELEASE_MESSAGE}" > distribution/whatsnew/whatsnew-en-US
  git add distribution/whatsnew/
fi

# ── 8. Commit Changes to Git ──────────────────────────────────────────────────
echo "💾 Staging version update files..."
git add pubspec.yaml lib/core/constants/app_constants.dart

COMMIT_MSG="release: v${TARGET_VERSION} (Build ${TARGET_BUILD})"
if [ -n "$RELEASE_MESSAGE" ]; then
  COMMIT_MSG="release: v${TARGET_VERSION} (Build ${TARGET_BUILD}) - ${RELEASE_MESSAGE}"
fi

echo "📦 Creating release commit..."
git commit -m "$COMMIT_MSG"

# ── 9. Push to Main & Create Git Tag ──────────────────────────────────────────
echo "🚀 Pushing release commit to origin/${CURRENT_BRANCH}..."
git push origin "$CURRENT_BRANCH"

echo "🏷️  Creating annotated release tag: ${TAG_NAME}..."
git tag -a "$TAG_NAME" -m "$COMMIT_MSG"

echo "🚀 Pushing tag ${TAG_NAME} to origin..."
git push origin "$TAG_NAME"

# ── 10. Summary & Live Monitoring ─────────────────────────────────────────────
echo ""
echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}🎉 Release ${TAG_NAME} successfully triggered!${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "✅ Updated version     : ${CYAN}${TARGET_VERSION}+${TARGET_BUILD}${NC}"
echo -e "✅ Pushed to branch    : ${CYAN}${CURRENT_BRANCH}${NC}"
echo -e "✅ Tag created & pushed: ${CYAN}${TAG_NAME}${NC}"
echo ""
echo -e "⚙️  ${BLUE}GitHub Actions Cloud CI/CD is now running automatically:${NC}"
echo -e "   1. 🧪 Executing test suite (${CYAN}flutter test${NC})"
echo -e "   2. 🔨 Building optimized, signed AAB bundle & APK"
echo -e "   3. 📦 Creating GitHub Release with attached AAB & APK (+ SHA-256 artifacts)"
echo -e "   4. 🚀 Deploying directly to Google Play Store"
echo ""
echo -e "🔗 ${YELLOW}Monitor workflow progress live:${NC}"
echo -e "   https://github.com/fh32000/rattil-mobile/actions"
echo -e "${GREEN}================================================================${NC}"
