# projectad

A Flutter app (iOS focus) built while learning to code. Users solve daily quotes, earn coins, connect with friends and link their Instagram account.

## Setup

Secrets are not part of this repository. Before building you need to provide them locally:

### 1. Build-time configuration

Copy the example file and fill in your own values:

```sh
cp env.example.json env.json
```

`env.json` is git-ignored. Pass it to Flutter when running or building:

```sh
flutter run --dart-define-from-file=env.json
```

(Older Flutter versions without `--dart-define-from-file` can pass each value with `--dart-define=KEY=value`.)

The values are read in `lib/env.dart`.

> Note: values passed via `--dart-define` end up inside the compiled app. Anything shipped in a client app can be extracted, so real secrets (mail passwords, account credentials) should live on a server, not in the app.

### 2. Firebase

Download `GoogleService-Info.plist` for your own Firebase project and place it at `ios/Runner/GoogleService-Info.plist`. A template with the expected keys is in `ios/Runner/GoogleService-Info.example.plist`. The real file is git-ignored.
