# Make Doable yours

Everything here works from a phone browser or the GitHub app.

## 1. Get your own Android build

1. Fork the repo.
2. Open **Actions** in your fork and enable workflows.
3. Push a change, or run **Actions → Android build → Run workflow**.

Each build publishes a release with `doable.apk`. On your phone, open **Releases**, download `doable.apk`, and install it. If Android asks, allow your browser to install apps.

Your build automatically uses the app ID `io.github.<your-username>.<repo-name>`, so it installs separately from the original Doable and from other forks.

> Without a signing key (step 3), the APK is a **test build**. It shows up as "Doable (test)" and works fully. Add a key to get a proper release build.

## 2. Change the name, colours and icon

Edit [`app.config.json`](app.config.json):

```json
{
  "appName": "My Tasks",
  "appId": "com.yourname.mytasks",
  "originalOwner": "maheshsurada9434",
  "iconColor": "#e0442b",
  "lightBackground": "#f6efe8",
  "darkBackground": "#141110"
}
```

- `appName` – the name under the icon.
- `appId` – your Play Store package name. Pick it once. It can never change after you publish. Leave it as `com.maheshsurada.doable` and forks get `io.github.<you>.<repo>` automatically.
- `iconColor` – background of the adaptive app icon.
- `lightBackground` / `darkBackground` – splash screen colours.

To change the icon, replace the PNGs in [`assets/`](assets/), keeping the same names and sizes:

| File | Size | What it is |
| --- | --- | --- |
| `icon-only.png` | 1024×1024 | Full icon, used on older Android |
| `icon-foreground.png` | 1024×1024, transparent | Your logo, kept inside the middle 60% |
| `icon-background.png` | 1024×1024 | Solid background behind it |
| `splash.png` / `splash-dark.png` | 2732×2732 | Logo centred on the splash colour |

The notification icon is [`android-res/drawable-*/ic_stat_doable.png`](android-res/). It must be white on transparent.

Colours and text inside the app are in [`index.html`](index.html). Search for `--accent-l` to change the default blue.

## 3. Sign a release build (for Google Play)

Create a signing key once and keep it safe. You need the same key for every update.

```bash
keytool -genkeypair -v -keystore release.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
base64 -w0 release.jks > release.jks.base64   # macOS: base64 -i release.jks
```

No computer? Any Android terminal app such as Termux can run these commands.

In your fork: **Settings → Secrets and variables → Actions → New repository secret**. Add:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Contents of `release.jks.base64` |
| `ANDROID_KEYSTORE_PASSWORD` | Your keystore password |
| `ANDROID_KEY_ALIAS` | `upload` (or the alias you chose) |
| `ANDROID_KEY_PASSWORD` | Your key password |

The next build's release has a signed `doable.apk` and `doable.aab`. Upload the `.aab` to Google Play Console. Never commit the `.jks` file. `.gitignore` already blocks it.

## 4. Put it on the web

Settings → Pages → Branch: `main`, folder `/ (root)` → Save. Your app goes live at `https://<you>.github.io/<repo>/` and can be installed from the browser.

## 5. Publish on Google Play

- Upload `doable.aab` from a signed release.
- Use `store/` for screenshots, the feature graphic and listing text, and edit them to match your version.
- Privacy policy URL: `https://<you>.github.io/<repo>/privacy.html` (once Pages is on). Update the contact link in `privacy.html`.
- New personal developer accounts must run a closed test with at least 12 testers for 14 days before going public. See Google's [testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465).
