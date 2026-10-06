# Contributing to Doable

Thanks for helping. Doable is deliberately simple: the whole app is one file, [`index.html`](index.html), with no framework and no build step. That means you can contribute with nothing more than a browser and a text editor.

## Run it

```bash
git clone https://github.com/<you>/doable
cd doable
python3 -m http.server 8000   # or any static server
```

Open http://localhost:8000. Opening `index.html` directly also works, apart from the offline service worker.

## Good first issues

Pick one and open a PR. Each is a self-contained change:

- **Hindi / Hinglish dates.** Teach `parse()` words like `kal` (tomorrow), `parso` and `somvar`.
- **Calendar month view.** A new view next to Upcoming.
- **Task templates.** Save a list of tasks ("morning routine") and add it in one tap.
- **Custom focus length.** Let people pick 15, 25 or 50 minutes.
- **More share-card styles.** See `drawWrap()`.
- **Import.** Read a Google Tasks or Todoist export into Doable's backup format.

Bigger ideas, like a home screen widget, are welcome too. Open an issue first so we can agree on the approach.

## Guidelines

- Keep it one file and dependency-free on the web side.
- Everything stays on the device. No analytics, no network calls for user data.
- Test on a phone-sized screen and in dark mode.
- Write UI text in plain, friendly sentence case.
- One feature per PR, with a screenshot or short video if it changes the UI.

## How the Android build works

Every push to `main` runs [`.github/workflows/android.yml`](.github/workflows/android.yml), which calls [`scripts/ci-build.sh`](scripts/ci-build.sh). It generates a Capacitor 8 Android project, applies icons and settings from `app.config.json` and `assets/`, builds an APK and an `.aab`, and publishes a GitHub Release. You don't need Android Studio to contribute.

Thanks for making Doable better.
