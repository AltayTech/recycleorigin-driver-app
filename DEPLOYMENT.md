# RecycleOrigin Driver App Deployment

This guide covers both **dev** and **prod** runs for the driver app.

## Secrets (local development)

Environment files, keystores, Firebase keys, and TLS material are **not**
committed in this monorepo. They live in the private sibling repository
`recycle-origin-secrets/` inside this workspace (private Git repo; not the
driver app repo).

From the monorepo root, after cloning that repo:

```powershell
pwsh scripts/secrets/sync-secrets.ps1 -Pull
```

On macOS/Linux:

```bash
./scripts/secrets/sync-secrets.sh --pull
```

Override the default path with `RECYCLE_ORIGIN_SECRETS_DIR` if needed.
**CI** must use platform secrets (for example GitHub Actions encrypted
secrets), not the sibling repo or these sync scripts.

If the script reports a **blocked** copy (file locked), close editors or
processes using that path and run it again.

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

## 8) Google Play: FOREGROUND_SERVICE_LOCATION

Play shows this because the driver app shares GPS with dispatch **while the
app is not on screen** (driver is navigating or the phone is in a pocket).
That requires a **location** foreground service and a **persistent
notification**. Do not remove `FOREGROUND_SERVICE_LOCATION`.

Do **not** add `ACCESS_BACKGROUND_LOCATION`. While-using-the-app plus the
foreground service is the correct Play path. "Allow all the time" is a
different, stricter declaration.

### 8.1 Play Console form

After you upload the AAB:

**Monitor and improve → App content → Foreground service permissions**

| Field | Value |
|---|---|
| FGS type | Location (`FOREGROUND_SERVICE_LOCATION`) |
| Use cases | **Background Location Updates: User-initiated location sharing** and **Navigation** |
| Video | Unlisted YouTube (or a Drive link Play can open) of the flow below |

**Functionality description** (paste):

> RecycleOrigin Driver shares the driver's live GPS with dispatch only after
> the driver opens **My route** for a day that still has pickups. Sharing
> continues while they navigate, collect, or leave the app so the operations
> team can see the vehicle. An ongoing, non-dismissible status-bar
> notification ("On route — location sharing") stays visible until every stop
> is completed/failed or the driver signs out.

**User impact if the task is deferred or interrupted:**

> Dispatch loses the live map of the vehicle. Pickups are delayed and
> customers cannot be given an accurate ETA. The driver must reopen My route
> to resume sharing.

### 8.2 Video to record (required)

Use a physical Android phone, prod (or staging) build, with at least one
assigned stop:

1. Sign in as a driver.
2. Open **My route**. Allow **While using the app** (not "all the time").
   Allow notifications if Android asks.
3. Show the in-app banner that location is being shared.
4. Press **Home**. Pull down the shade and show the **ongoing** notification
   that cannot be swiped away.
5. Return to the app, complete or fail remaining stops (or sign out).
6. Show that the notification is gone.

### 8.3 Data safety

In Data safety, declare that location is collected and shared with the
backend (not sold) for app functionality (live dispatch).

## 9) Config reference

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
