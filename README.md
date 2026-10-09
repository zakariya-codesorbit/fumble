# fumble

**Version 1 — not live / not published.**

| | |
|---|---|
| App | `1.0.0` (build `1`) — `pubspec.yaml` |
| Local DB schema | `1` — `AppConfig.databaseSchemaVersion` |
| Android | `versionName` / `versionCode` from Flutter |
| iOS | `FLUTTER_BUILD_NAME` / `FLUTTER_BUILD_NUMBER` |

fumble is a private way for two people to exchange contact cards in real life by scanning a QR code.

Package name: `fumble`. Android / iOS identifiers: `com.fumble.app`.

Firebase project: `fumble-d3387`.

## Version 1 features

- Email + password authentication + photo/phone onboarding
- Fumble home QR + scanner → preview → auto-connect
- My Fumble profile editing
- Connections list (local-first + Firebase sync)
- Settings: share phone/email, account actions
- Offline scan/save + online enrich/sync
- Firebase Auth, Firestore, Analytics, Crashlytics, FCM, App Check
- Dark theme only (true black + gold)

## Intentionally not used (for now)

- Firebase Storage (profile photo upload deferred)
- Cloud Functions (Spark/free plan compatible)
- Localization, onboarding, light theme
- Social auth, phone/OTP
- AdMob, Remote Config
- AI memories, notes, tags, groups, social feed

## Getting started

```bash
flutter pub get
flutter run
```

Deploy Firestore rules:

```bash
firebase deploy --only firestore:rules
```

## Architecture

```
UI (view/screens + view/widgets)
  → Riverpod providers / notifiers
  → Services (auth, fumble, notifications, analytics)
  → Repositories / local SQLite queue
  → Firebase (Auth, Firestore)
```

Fumble exchange is Firestore-only:

- `fumbleCodes/{code}` for QR resolve (authenticated read)
- Mutual writes to `users/{uid}/connections/{peerUid}`
