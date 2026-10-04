# Doable

A fast, private to-do app for Android and the web. Type tasks the way you'd say them — Doable picks out the date, time, tags, priority and repeat for you.

**Live app:** https://maheshsurada9434.github.io/doable/

## Type it like you'd say it

| You type | Doable understands |
| --- | --- |
| `Pay rent tomorrow 9am #home !high every month` | Tomorrow 9:00, tag *home*, high priority, repeats monthly |
| `Call mom on friday at 6pm` | Next Friday, 6:00 pm |
| `Gym 7am every weekday #health` | Weekdays at 7:00, tag *health* |
| `Dentist 15 oct 10:30` | 15 October, 10:30 |
| `Taxes 31/12` | 31 December (day/month) |
| `Report next week !med @work` | Next Monday, medium priority, in the *Work* list |
| `Buy milk tonight` | Today 8:00 pm |
| `Meeting in 3 days` | Three days from today |

Priority: `!high` `!med` `!low` · Tags: `#anything` · Lists: `@ListName` · Repeats: `every day`, `every weekday`, `every monday`, `weekly`, `monthly`, `yearly`.

## Features

- **Reminders that reach you** – at the time of a task or up to a day before, plus an optional morning summary (Android app).
- **Swipe gestures** – swipe right to complete, left to move a task to tomorrow.
- **Today** – overdue and today's tasks with a progress ring for the day.
- **Upcoming** – the next two weeks, grouped by day.
- **Inbox and lists** – colour-coded lists; drag tasks into the order you want.
- **Task details** – quick date chips, subtasks, notes, tags, priority, reminder and repeat.
- **Repeating tasks** – completing one schedules the next automatically.
- **Focus timer** – a 25-minute focus session for any task.
- **Search** – across titles, notes, subtasks and `#tags`.
- **Stats** – your streak and what you finished this week.
- **Settings** – light/dark theme, six accent colours, default reminder, daily summary, vibration and sound.
- **Undo** for completing, moving, deleting and clearing.
- **Private** – no account, no ads, no tracking. Tasks stay on your device. Export / import a backup file.

## Android app

The Android app wraps this same web app with [Capacitor 8](https://capacitorjs.com) (targets Android 16, API 36) and adds real notifications, haptics, the back button and native sharing for backups.

Every push to `main` runs the **Android build** workflow, which builds:

- `doable-<version>-<build>-unsigned.aab` – the Play Store bundle (signed separately with the private upload key, which is never stored in this repo)
- `doable-<version>-<build>-test.apk` – a test build that installs next to the Play version as **Doable (test)**

The finished files are pushed to the [`builds`](../../tree/builds) branch. Store listing text and graphics are in [`store/`](store/). Privacy policy: https://maheshsurada9434.github.io/doable/privacy.html

## Run it

No build step and no dependencies: open `index.html`, or host the folder on any static host such as GitHub Pages.
