# RecycleOrigin Driver App Deployment Guide

## 1) Initial setup

### Prerequisites
- Flutter SDK installed.
- Android/iOS signing prepared.
- Backend environment available (`dev`, `staging`, `prod`).

### Flavor setup
- `dev`: `lib/main_dev.dart` + `assets/env/.env.dev`
- `staging`: `lib/main_staging.dart` + `assets/env/.env.staging`
- `prod`: `lib/main_prod.dart` + `assets/env/.env.prod`

`Urls.apiBaseUrl` is now environment-driven through `AppConfig` and flavor
bootstrap.

## 2) How to deploy

### Production Android build
```bash
cd "recycle origin driver"
flutter pub get
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

### Production iOS build
```bash
cd "recycle origin driver"
flutter pub get
flutter build ipa --release --flavor prod -t lib/main_prod.dart
```

### Staging build (when enabled)
```bash
flutter build apk --release --flavor staging -t lib/main_staging.dart
```

## 3) How to update

```bash
cd "recycle origin driver"
git pull --ff-only
flutter pub get
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

Upload artifact to store pipeline.

## 4) Rollback procedure

- Keep previous signed release artifacts per environment.
- Rollback by promoting the previous Play/App Store version.
- If backend compatibility breaks, ship a hotfix build with corrected flavor env.

## 5) Staging TODO checklist

- [ ] Register staging package IDs and signing credentials.
- [ ] Add iOS staging scheme using `ios/Flutter/Staging.xcconfig`.
- [ ] Add staging Firebase config files for Android and iOS.
- [ ] Distribute staging flavor to testers.

## 6) Environment variable reference

| Variable | Required | Description |
|---|---|---|
| `ENVIRONMENT` | Yes | Runtime environment name. |
| `API_BASE_URL` | Yes | Base backend URL for driver API calls. |
