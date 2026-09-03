# Recycle Origin Driver App

Flutter mobile application used by drivers to accept, collect, and complete
recycling pickups. Warehouse deliveries are **Coming Soon**
(`ENABLE_WAREHOUSE_DELIVERIES=false`).

## Responsibilities

- driver authentication and profile completion
- list and inspect assigned collections
- update collected item quantities/weights and statuses
- view wallet/statistics and submit a **staff-handled payout request**
  (not an instant bank transfer)
- Crashlytics when Firebase initializes successfully

## Project Structure

- `lib/main.dart`: app bootstrap, providers, theme, routes
- `lib/provider`: state and remote data orchestration
- `lib/screens`: route-level UI screens
- `lib/widgets`: reusable presentation components
- `lib/models`: API and domain data models

## Prerequisites

- Flutter SDK (stable)
- Android Studio or VS Code + Flutter tooling
- backend API reachable from the running device/emulator

## Run Locally

```bash
flutter pub get
flutter run
```

## Quality Checks

```bash
dart format lib test
flutter analyze
flutter test
```

## Documentation Standards

- public widgets/services should include `///` API docs
- asynchronous load/update flows should document state transitions
- complex UI state should include short intent comments where needed
