# RecycleOrigin Driver App Deployment

This guide covers both **dev** and **prod** runs for the driver app.

## 1) Environment mapping

- `dev` entrypoint: `lib/main_dev.dart` -> `assets/env/.env.dev`
- `staging` entrypoint: `lib/main_staging.dart` -> `assets/env/.env.staging`
- `prod` entrypoint: `lib/main_prod.dart` -> `assets/env/.env.prod`

Current production backend:
- `API_BASE_URL=https://api.app.recycleorigin.xyz/`

## 2) Dev mode (local run)

```bash
cd "recycle origin driver"
flutter pub get
flutter run -t lib/main_dev.dart
```

## 3) Prod mode (local smoke run)

```bash
cd "recycle origin driver"
flutter pub get
flutter run --release -t lib/main_prod.dart
```

## 4) Production artifacts

### Android AAB

```bash
cd "recycle origin driver"
flutter pub get
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

### iOS IPA

```bash
cd "recycle origin driver"
flutter pub get
flutter build ipa --release --flavor prod -t lib/main_prod.dart
```

## 5) Update flow

```bash
cd "recycle origin driver"
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

Publish artifact through your release pipeline/store console.

## 6) Rollback

- Promote previous approved release from store console.
- Keep previous signed artifacts per environment.

## 7) Production verification checklist

- [ ] Driver login works.
- [ ] Assigned requests list loads from prod backend.
- [ ] Accept/complete request status updates work.
- [ ] Cross-check request status in admin/customer apps.
- [ ] No API calls target localhost or dev URLs.

Quick backend check:

```bash
curl -fsS https://api.app.recycleorigin.xyz/healthz
```

## 8) Config reference

| Variable | Required | Description |
|---|---|---|
| `ENVIRONMENT` | Yes | `development`, `staging`, `production`. |
| `API_BASE_URL` | Yes | Backend base URL for driver APIs. |
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
