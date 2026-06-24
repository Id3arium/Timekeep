# Timekeep

A screen time tracker that keeps the **timestamps**, so you can see *when* you used each
app, not just how long.

## Why this exists

Apple's Screen Time tells you that you spent 47 minutes in a messaging app today. It
won't tell you whether that was one long stretch at 2am or six check-ins across the day.
The timeline is the interesting part, and it's the part you don't get to see.

Timekeep keeps that timeline: every session with its real start and end time.

There's no public iOS API that will just hand an app your usage history, so Timekeep
builds it from the other direction. You set up two **Shortcuts automations** once, and
they tell Timekeep each time you open or close an app. It reconstructs your sessions from
those events. It's a roundabout setup, but it's the only way to get this, and nothing
ever leaves your phone.

## How it works

1. You create two automations in Apple's **Shortcuts** app, one that fires when a tracked
   app **opens** and one when it **closes**, each calling Timekeep's **"Log App Event"**
   action with the current app's name.
2. Each event is stored locally (SwiftData) as an `AppEvent` (app name, opened/closed,
   timestamp).
3. `SessionComputer` stitches those events into sessions, pairing an open with its close,
   and estimating an end time from the next app's open when a close is missing.
4. The Dashboard and Activity Log show daily/weekly totals, per-app breakdowns, and
   usage charts.

All data stays on device. There is no account, server, or network sync.

## Requirements

- An iPhone running iOS 17.0 or later
- Xcode + command-line tools, and an Apple ID signed in to Xcode (a free Apple ID is
  enough to install to your own device)

## Build & install

```sh
# one-time: set your Apple Development Team ID
cp Config.xcconfig.example Config.xcconfig
#   then edit Config.xcconfig and set DEVELOPMENT_TEAM to your team
#   (Xcode → Settings → Accounts → your team)

./build.sh                 # build, sign, install to the connected iPhone (default)
./build.sh --no-install    # build + sign only, stage into ./build/Timekeep.app
./build.sh -h              # full usage
```

`build.sh` is self-contained: it builds and signs with `xcodebuild`
(`-allowProvisioningUpdates` refreshes the free-account provisioning profile headlessly)
and installs to a connected device with `devicectl`. No Xcode GUI, Sideloadly, or
re-signing tools required.

`Config.xcconfig` holds your personal Team ID and is gitignored, so it never gets
committed.

## First-run setup (in the app)

After installing, the onboarding walks you through creating the two Shortcuts automations.
You can reopen those instructions any time from the ⓘ button. In short:

1. **Shortcuts** app → **Automation** tab → **+**
2. Trigger: **App** → choose every app you want to track → **Is Opened** only → **Run
   Immediately**
3. Add a **Get Name of Current App** action, then Timekeep's **Log App Event** action with
   **App Name = Current App Name** and **Event Type = Opened**
4. Repeat for a second automation with **Is Closed** and **Event Type = Closed**

To track more apps later, just edit both automations and add them to the triggers.

## Project layout

```
Sources/
  Models/        AppEvent, Session, EventType, SharedContainer (SwiftData)
  Services/      SessionComputer, StatsCalculator, AppIconFetcher
  Intents/       LogAppEventIntent (the Shortcuts action), AppShortcuts
  Views/         Dashboard, ActivityLog, AppDetail, Setup, Onboarding, Components
  Utilities/     time/date formatting, color generation
build.sh         build + sign + install
```
