#!/usr/bin/env bash
# Copies the web app into www/ for the Android build and bundles the font
# locally, so the app looks right on first launch even without internet.
set -euo pipefail
cd "$(dirname "$0")/.."

rm -rf www && mkdir -p www/fonts
cp index.html manifest.webmanifest privacy.html www/
cp -r icons www/

UA="Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Mobile Safari/537.36"
CSS_URL="https://fonts.googleapis.com/css2?family=Familjen+Grotesk:wght@400;500;600;700&display=swap"
if curl -fsSL -A "$UA" "$CSS_URL" -o /tmp/font.css; then
  i=0
  cp /tmp/font.css www/fonts/fonts.css
  for url in $(grep -o 'https://fonts.gstatic.com/[^)]*' /tmp/font.css | sort -u); do
    i=$((i+1)); f="font-$i.woff2"
    curl -fsSL "$url" -o "www/fonts/$f"
    sed -i "s#$url#$f#g" www/fonts/fonts.css
  done
  # Swap the online font link for the bundled copy and drop the preconnects.
  sed -i 's#<link id="gfont"[^>]*>#<link rel="stylesheet" href="fonts/fonts.css">#' www/index.html
  sed -i '/fonts.googleapis.com" *>/d; /fonts.gstatic.com" crossorigin>/d' www/index.html
  echo "Bundled $i font files"
else
  echo "WARNING: could not download the font; the app will use the system font offline"
fi
# The Android app does not need the web install manifest link.
sed -i '/rel="manifest"/d' www/index.html
