# Timekeep

A screen time tracker that gives you the **timestamps**, so you never have to guess
*when* you did what.

## Why this exists

Apple's built-in Screen Time tells you that you spent, say, 47 minutes in a messaging app
today. It will not tell you *when*. Was it one long stretch at 2am, or six scattered
check-ins through the day? The raw timeline is your own behavior, on your own phone, and
the system simply won't hand it to you. You get aggregates and you're expected to be
content with them. It's second-class access to your own data.

Timekeep gives you the timeline back: every session with its actual start and end time,
so you can see the *shape* of your usage, not just a daily total.

Getting at that data is admittedly roundabout. iOS has no public API that hands an app
your usage history, so Timekeep can't just read it. Instead, two **Shortcuts automations**
you set up once tell it whenever you open or close a tracked app, and from that stream of
timestamped open/close events Timekeep reconstructs your sessions and charts where your
time goes. It's a workaround, but it's the only way to get this, and everything stays on
your device.

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
