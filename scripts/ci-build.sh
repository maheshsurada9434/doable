#!/usr/bin/env bash
# Builds the Doable Android app on GitHub Actions. Output goes to ./dist
#
# Works in forks with no setup: the app ID becomes io.github.<you>.<repo>
# so your build never clashes with anyone else's.
#
# Optional signing (add these as repository secrets to get a release APK and
# a Play-ready bundle signed with your own key):
#   ANDROID_KEYSTORE_BASE64   base64 of your .jks file
#   ANDROID_KEYSTORE_PASSWORD keystore password
#   ANDROID_KEY_ALIAS         key alias
#   ANDROID_KEY_PASSWORD      key password (often the same as the keystore's)
set -euo pipefail
cd "$(dirname "$0")/.."

cfg() { node -p "require('./app.config.json')['$1']"; }
APP_NAME=$(cfg appName)
APP_ID=$(cfg appId)
ORIGINAL_OWNER=$(cfg originalOwner)
OWNER=${GITHUB_REPOSITORY_OWNER:-$ORIGINAL_OWNER}
REPO=${GITHUB_REPOSITORY:-$ORIGINAL_OWNER/doable}
if [ "$OWNER" != "$ORIGINAL_OWNER" ] && [ "$APP_ID" = "com.maheshsurada.doable" ]; then
  clean() { echo "$1" | tr 'A-Z' 'a-z' | sed 's/[^a-z0-9]/_/g; s/^\([0-9]\)/_\1/'; }
  APP_ID="io.github.$(clean "$OWNER").$(clean "${REPO#*/}")"
fi
VERSION_NAME=$(node -p "require('./package.json').version")
VERSION_CODE=${VERSION_CODE:-1}
echo "== $APP_NAME $VERSION_NAME ($VERSION_CODE) as $APP_ID from $REPO"

npm install --no-audit --no-fund
bash scripts/build-www.sh

# Capacitor config with this build's name and ID
node -e "
const fs=require('fs'); const c=JSON.parse(fs.readFileSync('capacitor.config.json'));
c.appId='$APP_ID'; c.appName=process.argv[1]; fs.writeFileSync('capacitor.config.json', JSON.stringify(c,null,2));
" "$APP_NAME"

rm -rf android
npx cap add android

ICON=$(cfg iconColor); LIGHT=$(cfg lightBackground); DARK=$(cfg darkBackground)
npx @capacitor/assets generate --android \
  --iconBackgroundColor "$ICON" --iconBackgroundColorDark "$ICON" \
  --splashBackgroundColor "$LIGHT" --splashBackgroundColorDark "$DARK"

# Notification icon
cp -r android-res/* android/app/src/main/res/

# A shared, public debug key so each test build installs over the last one.
mkdir -p ~/.android && cp ci/debug.keystore ~/.android/debug.keystore

python3 - "$VERSION_NAME" "$VERSION_CODE" "$APP_NAME" <<'PY'
import re, sys, os
name, code, app = sys.argv[1], sys.argv[2], sys.argv[3]
p = 'android/app/build.gradle'
s = open(p).read()
s = re.sub(r'versionCode\s+\d+', f'versionCode {code}', s)
s = re.sub(r'versionName\s+"[^"]*"', f'versionName "{name}"', s)
if 'applicationIdSuffix' not in s:
    s = s.replace('buildTypes {', 'buildTypes {\n        debug {\n            applicationIdSuffix ".test"\n            versionNameSuffix "-test"\n        }', 1)
open(p, 'w').write(s)
d = 'android/app/src/debug/res/values'
os.makedirs(d, exist_ok=True)
esc = app.replace('&', '&amp;').replace('<', '&lt;').replace("'", "\\'")
open(f'{d}/strings.xml', 'w').write(f'<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <string name="app_name">{esc} (test)</string>\n    <string name="title_activity_main">{esc} (test)</string>\n</resources>\n')
PY

npx cap sync android

SIGN=0
if [ -n "${ANDROID_KEYSTORE_BASE64:-}" ]; then SIGN=1; fi

cd android
chmod +x gradlew
if [ $SIGN = 1 ]; then ./gradlew --no-daemon bundleRelease assembleRelease assembleDebug
else ./gradlew --no-daemon bundleRelease assembleDebug; fi
cd ..

rm -rf dist && mkdir -p dist
AAB=android/app/build/outputs/bundle/release/app-release.aab
cp android/app/build/outputs/apk/debug/app-debug.apk dist/doable-test.apk

if [ $SIGN = 1 ]; then
  echo "== Signing with the repository's release key"
  KS="${RUNNER_TEMP:-/tmp}/release.jks"
  echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > "$KS"
  export KSP="$ANDROID_KEYSTORE_PASSWORD" KP="${ANDROID_KEY_PASSWORD:-$ANDROID_KEYSTORE_PASSWORD}"
  BT=$(ls -d "$ANDROID_HOME"/build-tools/* | sort -V | tail -1)
  "$BT/zipalign" -p -f 4 android/app/build/outputs/apk/release/app-release-unsigned.apk /tmp/aligned.apk
  "$BT/apksigner" sign --ks "$KS" --ks-key-alias "$ANDROID_KEY_ALIAS" --ks-pass env:KSP --key-pass env:KP --out dist/doable.apk /tmp/aligned.apk
  "$BT/apksigner" verify dist/doable.apk
  jarsigner -sigalg SHA256withRSA -digestalg SHA-256 -keystore "$KS" -storepass "$KSP" -keypass "$KP" -signedjar dist/doable.aab "$AAB" "$ANDROID_KEY_ALIAS"
  rm -f "$KS"
else
  cp "$AAB" dist/doable-unsigned.aab
  # Without a release key the downloadable APK is the test build.
  cp dist/doable-test.apk dist/doable.apk
fi

{
  echo "app: $APP_NAME ($APP_ID)"
  echo "version: $VERSION_NAME"
  echo "versionCode: $VERSION_CODE"
  echo "signed: $([ $SIGN = 1 ] && echo yes || echo no)"
  grep -E "compileSdkVersion|targetSdkVersion|minSdkVersion" android/variables.gradle
  echo "capacitor: $(node -p "require('@capacitor/core/package.json').version")"
  echo "plugins:"; npx cap ls android 2>/dev/null | sed 's/^/  /' || true
} > dist/build-info.txt
cat dist/build-info.txt
echo "signed=$SIGN" >> "${GITHUB_OUTPUT:-/dev/null}"
