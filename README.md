# Flumble

Flumble is a premium, private way for two people to exchange contact cards in real life by scanning a QR code.

Package name: `fumble`. Android / iOS identifiers: `com.fumble.app`.

Firebase project: `fumble-d3387`.

## V1 features

- Email + password authentication
- Flumble home with circular FUMBLE CTA
- QR scanner → preview → confirm → connection
- My Flumble profile + QR identity
- Connections list
- Firebase Auth, Firestore, Analytics, Crashlytics, FCM, App Check
- Offline queue for pending fumble completions
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

- `flumbleCodes/{code}` for QR resolve (authenticated read)
- Mutual writes to `users/{uid}/connections/{peerUid}`
