#!/usr/bin/env bash
# Builds the Android app (Play Store bundle + installable test APK).
# Runs on GitHub Actions. Output goes to ./dist
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION_NAME=$(node -p "require('./package.json').version")
VERSION_CODE=${VERSION_CODE:-1}
echo "== Doable $VERSION_NAME ($VERSION_CODE)"

npm install --no-audit --no-fund
bash scripts/build-www.sh

rm -rf android
npx cap add android

# App icons, adaptive icons and splash screens from assets/
npx @capacitor/assets generate --android \
  --iconBackgroundColor '#2b45e0' --iconBackgroundColorDark '#2b45e0' \
  --splashBackgroundColor '#e9ece6' --splashBackgroundColorDark '#101312'

# Notification icon
cp -r android-res/* android/app/src/main/res/

python3 - "$VERSION_NAME" "$VERSION_CODE" <<'PY'
import re, sys
name, code = sys.argv[1], sys.argv[2]
p = 'android/app/build.gradle'
s = open(p).read()
s = re.sub(r'versionCode\s+\d+', f'versionCode {code}', s)
s = re.sub(r'versionName\s+"[^"]*"', f'versionName "{name}"', s)
# Test builds install next to the Play version instead of replacing it.
if 'applicationIdSuffix' not in s:
    s = s.replace('buildTypes {', 'buildTypes {\n        debug {\n            applicationIdSuffix ".test"\n            versionNameSuffix "-test"\n        }', 1)
open(p, 'w').write(s)

# Name the test build so it is easy to tell apart on the phone.
import os
d = 'android/app/src/debug/res/values'
os.makedirs(d, exist_ok=True)
open(f'{d}/strings.xml', 'w').write('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <string name="app_name">Doable (test)</string>\n    <string name="title_activity_main">Doable (test)</string>\n</resources>\n')
PY

npx cap sync android

echo "== SDK levels"
grep -E "compileSdkVersion|targetSdkVersion|minSdkVersion" android/variables.gradle || true

cd android
chmod +x gradlew
./gradlew --no-daemon bundleRelease assembleDebug
cd ..

rm -rf dist && mkdir -p dist
cp android/app/build/outputs/bundle/release/app-release.aab "dist/doable-$VERSION_NAME-$VERSION_CODE-unsigned.aab"
cp android/app/build/outputs/apk/debug/app-debug.apk "dist/doable-$VERSION_NAME-$VERSION_CODE-test.apk"
{
  echo "version: $VERSION_NAME"
  echo "versionCode: $VERSION_CODE"
  grep -E "compileSdkVersion|targetSdkVersion|minSdkVersion" android/variables.gradle
  echo "capacitor: $(node -p "require('@capacitor/core/package.json').version")"
  echo "plugins:"; npx cap ls android 2>/dev/null | sed 's/^/  /' || true
  echo "permissions:"; grep -ho 'android.permission.[A-Z_]*' android/app/build/intermediates/merged_manifests/release/*/AndroidManifest.xml 2>/dev/null | sort -u | sed 's/^/  /' || true
} > dist/build-info.txt
cat dist/build-info.txt
