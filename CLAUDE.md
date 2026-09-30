# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

MachineTrack is a Flutter app for logging factory machine inspections and breakdowns. The app lives in the Flutter project under `frontend/`. The Dart package is named `frontend`, so imports look like `package:frontend/...`. There is no separate server. The backend is Firebase (Auth + Cloud Firestore, project `machinetrack-701bd`), which the app calls directly. Its server-side pieces (security rules, indexes, emulator config, and later Cloud Functions) live in `backend/`. The data model and roadmap are in `backend/README.md`.

## Commands

Run these from `frontend/`:

```bash
flutter pub get                                # install dependencies
flutter run                                    # run the app (add -d chrome or -d <device-id>)
flutter analyze                                # lint with flutter_lints; android/, ios/, web/, build/ are excluded
flutter test                                   # run all tests
flutter test test/machine_model_test.dart      # run a single test file
flutter test --plain-name "copyWith updates"   # run tests whose name contains the string
```

Run these from `backend/` (needs Node 20+ and Java 21+):

```bash
npm install
npm test            # Firestore security-rules tests on the emulator
npm run emulators   # local Auth + Firestore emulators, UI on :4000
```

`backend/firestore.rules` doubles as the schema: it rejects unknown fields and enforces the domain values below. When you change a Firestore field or status value, update the rules and `backend/tests/` along with the Dart code.

The FlutterFire CLI generates `lib/firebase_options.dart` and `android/app/google-services.json`, with its settings in `firebase.json`. Regenerate them with `flutterfire configure`; don't edit them by hand.

## Architecture

### Startup and navigation

- `main.dart` initializes Firebase and then runs `MachineTrackApp` (`lib/app/app.dart`).
- All routes are named constants in `AppRoutes` (`lib/app/routes.dart`), resolved in `AppRoutes.onGenerateRoute`. A new screen needs both a constant and a `case` there.
- Route arguments are always a `Map<String, dynamic>?`. Destination screens read the keys with hardcoded fallback values, so they still render when no arguments are passed.
- `SplashScreen` waits 2 seconds, then routes to `/main` if `AuthService().currentUser` is set and to `/login` otherwise.
- `MainScreen` is the bottom-nav shell: an `IndexedStack` of the Home, Machines, Records and Profile tabs. `HomeScreen` switches tabs through its `onNavigateToTab` callback.

There is no state-management package. Screens are `StatefulWidget`s that use `setState` and construct services directly (`AuthService()`, `MachineService()`).

### Services (`lib/services/`)

The tests depend on these conventions:

- **Injectable Firebase instances.** Constructors take optional instances: `AuthService(auth:)`, `FirestoreService(firestore:)`, `MachineService(firestoreService:)`. Without one, a service reads `.instance` lazily inside a try/catch.
- **Quiet fallback when Firebase isn't initialized.** Services then return a `null` user or `Stream.empty()`, and `FirestoreService.isAvailable` is `false`.
  - Unit and widget tests run without calling `Firebase.initializeApp` and without any Firebase mock package. They assert this fallback behavior, and `widget_test.dart` pumps the whole app.
  - Any Firebase access reachable from a plain `flutter test` must therefore be guarded.
- **Errors are user-facing strings.** Failures are thrown as `String`s, not exception objects (see `AuthService.getReadableAuthError`). Screens catch them and show `error.toString()` in a `SnackBar` colored `AppTheme.statusBreakdown`.
- **Collection names are centralized.** They're defined in `FirestoreCollections` (`lib/constants/firestore_constants.dart`): `users`, `machines`, `inspections`, `breakdowns`. `FirestoreService` exposes a getter for each, and domain services like `MachineService` build on those getters.

### What is live and what is mock

Only authentication is wired to Firebase: login, signup, password reset and logout. Everything else is still a UI prototype:

- The Home, Machines, Records, New Inspection and Report Breakdown screens render hardcoded sample maps, e.g. the `const List<Map<String, String>>` in `MachinesScreen` and `RecordsScreen`.
- `Machine` (`lib/models/machine.dart`) and `MachineService` exist, but no screen uses them yet.
- Submitting an inspection or a breakdown only waits on a `Future.delayed`. The payload map is then passed to the next screen as route arguments, and nothing is written to Firestore.

The sample machine maps use the same keys as `Machine.fromMap`/`toMap`. Wiring in Firestore therefore means switching screens from maps to `Machine` objects, and passing `toMap()` output wherever a route still expects a map.

### Domain values are plain strings

| Field | Values |
|---|---|
| Machine `status` | `'Running'`, `'Maintenance'`, `'Breakdown'`, `'Idle'` (default `'Idle'`) |
| Record `recordType` | `'Inspection'`, `'Breakdown'` |
| Inspection condition | `'Passed'`, `'Needs Repair'`, `'Critical'` |
| Breakdown severity | `'Critical'`, `'Needs Repair'`, `'Warning'` |

A record's `status` holds either the inspection condition or the breakdown severity. Dates such as `lastInspected` are free-form display strings, e.g. `"25 mins ago"`.

Status-to-color mapping is duplicated: `machine_card.dart`, `record_card.dart` and `record_details_screen.dart` each have their own private `_getStatusColor`. When you add or rename a status, update all three.

### Styling

`AppTheme` (`lib/app/theme.dart`) holds the palette constants, including the `status*` colors, and the Material 3 `lightTheme`. Screens reference `AppTheme.*` constants directly and rarely use `Theme.of(context)`.

Shared widgets live in `lib/widgets/`. `CustomButton` supports `isLoading`, `isOutlined` and `icon`, and `CustomTextField` wraps a `TextFormField`.

## Git workflow

Changes reach `main` through GitHub PRs to `kalviumcommunity/Mukthar_MachineTrack_Kalvium-Community`. Recent commit messages follow the `feat: <short summary>` style.
