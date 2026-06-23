#!/bin/bash
# Cut a GitHub Release for Timekeep: build a fresh signed .app, zip it, tag the
# version, and publish a release with the artifact attached.
#
# The version is read from MARKETING_VERSION in the Xcode project — the single
# source of truth — so the tag and the build can never disagree. To release a
# new version, bump MARKETING_VERSION (in Timekeep.xcodeproj/project.pbxproj),
# commit, push, then run ./release.sh.
#
# Usage:
#   ./release.sh        # build, tag v<version>, create the GitHub release
#   ./release.sh -h     # show this help

set -euo pipefail

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
fi

cd "$(dirname "$0")"

APP_NAME=Timekeep
PBXPROJ="$APP_NAME.xcodeproj/project.pbxproj"

# 1. Version from the single source of truth.
VERSION=$(grep -m1 'MARKETING_VERSION =' "$PBXPROJ" | sed -E 's/.*= ([^;]+);.*/\1/' | tr -d ' ')
if [ -z "$VERSION" ]; then
    echo "error: could not read MARKETING_VERSION from $PBXPROJ."
    echo "       Set MARKETING_VERSION in the project's build settings, then re-run."
    exit 1
fi
TAG="v$VERSION"

# 2. Refuse to release from a dirty or unpushed tree, so the tag always matches
#    what's on GitHub rather than uncommitted local code.
if [ -n "$(git status --porcelain)" ]; then
    echo "error: working tree is dirty. Commit or stash your changes first, then"
    echo "       re-run ./release.sh so the release matches what's committed."
    exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if ! git rev-parse --verify --quiet "origin/$BRANCH" >/dev/null; then
    echo "error: no upstream origin/$BRANCH. Push the branch first: git push -u origin $BRANCH"
    exit 1
fi
if [ -n "$(git log "origin/$BRANCH..HEAD" --oneline)" ]; then
    echo "error: you have local commits that aren't pushed. Run 'git push', then re-run"
    echo "       ./release.sh so the release tag matches the code on GitHub."
    exit 1
fi

# 3. Don't clobber an existing version. An existing tag means: bump the version.
if git rev-parse --verify --quiet "refs/tags/$TAG" >/dev/null \
    || gh release view "$TAG" >/dev/null 2>&1; then
    echo "error: $TAG already exists. Bump MARKETING_VERSION in $PBXPROJ, commit,"
    echo "       push, then re-run ./release.sh."
    exit 1
fi

# 4. Build fresh (signed .app), then zip it as the release artifact.
echo "→ Building $APP_NAME $VERSION"
./build.sh --no-install

APP_PATH="build/$APP_NAME.app"
if [ ! -d "$APP_PATH" ]; then
    echo "error: $APP_PATH not found after build. Run ./build.sh -v to see why."
    exit 1
fi

ARTIFACT="build/$APP_NAME-$VERSION.zip"
rm -f "$ARTIFACT"
echo "→ Zipping artifact: $ARTIFACT"
( cd build && ditto -c -k --keepParent "$APP_NAME.app" "$APP_NAME-$VERSION.zip" )

# 5. Tag and publish the release with auto-generated notes.
echo "→ Tagging $TAG and creating release"
git tag "$TAG"
git push origin "$TAG"
gh release create "$TAG" "$ARTIFACT" \
    --title "$APP_NAME $VERSION" \
    --generate-notes

echo "✓ Released $TAG → $(gh release view "$TAG" --json url -q .url)"
