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
flutter run --flavor dev -t lib/main_dev.dart
```

## 3) Prod mode (local smoke run)

```bash
cd "recycle origin driver"
flutter pub get
flutter run --release --flavor prod -t lib/main_prod.dart
```

## 4) Production artifacts

> Use Flutter **3.50.1** (pinned in CI and `Dockerfile.ci`). Always pass `--flavor`:
> each flavor bundles only its own `assets/env/.env.<flavor>` (see `pubspec.yaml`).
> Release builds fail fast if `android/key.properties` is missing.

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

The app must show an **in-app prominent disclosure** (where and when
precise location is used) **before** the Android permission sheet. Do not
request location on map open; only after the driver taps Continue (or My
location / sort by distance).

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
> the driver opens **My route** for a day that still has pickups, accepts
> the in-app location disclosure, and grants **While using the app**.
> Sharing continues while they navigate, collect, or leave the app so the
> operations team can see the vehicle. An ongoing, non-dismissible
> status-bar notification ("On route — location sharing") stays visible
> until every stop is completed/failed or the driver signs out.

**User impact if the task is deferred or interrupted:**

> Dispatch loses the live map of the vehicle. Pickups are delayed and
> customers cannot be given an accurate ETA. The driver must reopen My route
> to resume sharing.

### 8.2 Location permissions declaration

**Policy → App content → Sensitive app permissions → Location permissions**

Declare **one** core feature: live GPS sharing with dispatch during an
active pickup route.

Paste:

> RecycleOrigin Driver collects precise location so dispatch can see the
> vehicle on the street while today's pickups are in progress. Approximate
> location (about 1–3 km) cannot place a truck at a stop or support ETA.
> Sharing starts only after the driver opens My route with remaining stops,
> sees the in-app disclosure, and taps Continue, then grants While using
> the app. Location continues when the app is not in use (Home / navigation)
> while the persistent "On route — location sharing" notification is
> visible. Sharing stops when the route is finished or the driver signs out.
> Location is not used for ads. The same grant is also used in-app to center
> the map and sort stops by distance.

Do **not** declare `ACCESS_BACKGROUND_LOCATION`.

### 8.3 Video to record (required)

Use a physical Android phone, prod (or staging) build, with at least one
assigned stop. The disclosure dialog **must** be readable in the video.

1. Sign in as a driver.
2. Open **My route**.
3. Show the in-app **Location sharing** disclosure (precise location, when
   the app is not in use, dispatch sharing, not used for ads).
4. Tap **Continue**.
5. Allow **While using the app** (not "all the time"). Allow notifications
   if Android 13+ asks.
6. Show the in-app banner that precise location is being shared.
7. Press **Home**. Pull down the shade and show the **ongoing** notification
   that cannot be swiped away.
8. Return to the app, complete or fail remaining stops (or sign out).
9. Show that the notification is gone.

### 8.4 Data safety

In Data safety, declare that **precise location** is collected and shared
with the RecycleOrigin backend (not sold, not used for ads) for app
functionality (live dispatch). Collected only during an active route after
the driver consents.

### 8.5 Privacy policy (Play listing + CMS)

Paste into the store listing URL and shop CMS privacy HTML:

> RecycleOrigin Driver collects precise location (GPS) to share the driver's
> vehicle with dispatch while today's pickup route is active, including when
> the app is not in use as long as the "On route — location sharing"
> notification is visible. Sharing starts after the driver opens My route,
> accepts the in-app disclosure, and grants location permission. It stops
> when all stops are completed or failed, or when the driver signs out.
> Location is also used in the app to center the map and sort stops by
> distance. Location is not sold and is not used for advertising.

## 9) Config reference

| Variable | Required | Description |
|---|---|---|
| `ENVIRONMENT` | Yes | `development`, `staging`, `production`. |
| `API_BASE_URL` | Yes | Backend base URL for driver APIs. |

## 10) Staging TODO checklist

- [ ] Register a distinct staging applicationId (staging currently shares the prod id).
- [ ] Add iOS staging scheme using `ios/Flutter/Staging.xcconfig`.
- [ ] Add staging Firebase config files for Android and iOS.
- [ ] Distribute staging flavor to testers.
