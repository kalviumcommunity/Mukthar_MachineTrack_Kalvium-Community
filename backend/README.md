# MachineTrack Backend

The Firebase backend for the MachineTrack Flutter app (project `machinetrack-701bd`). The app reads and writes Cloud Firestore directly, so this folder holds the server-side pieces:

| File | Purpose |
|---|---|
| `firebase.json` | Firebase CLI config for Firestore and the local emulators |
| `.firebaserc` | Default project alias (`machinetrack-701bd`) |
| `firestore.rules` | Security rules, which are also the schema validation |
| `firestore.indexes.json` | Composite indexes for the app's record queries |
| `tests/` | Rules tests that run against the Firestore emulator |

The FlutterFire config (`frontend/firebase.json`) stays in `frontend/`. The two files don't overlap.

## Setup

You need Node 20 or newer and Java 21 or newer, because the Firestore emulator needs Java.

```bash
cd backend
npm install
npm test            # starts the Firestore emulator, runs tests/*.test.js, stops it
npm run emulators   # Auth + Firestore emulators with the UI at http://localhost:4000
```

The emulators use the `demo-machinetrack` project ID, so local runs never touch production data.

Rules and indexes are deployed manually. Log in first with `npx firebase login`:

```bash
npm run deploy:rules
```

## Data model

Every document is validated by `firestore.rules`, which rejects unknown fields. `createdAt` must be `serverTimestamp()`.

### `users/{uid}`

The doc ID is the Firebase Auth uid.

| Field | Type | Notes |
|---|---|---|
| `name` | string | Required |
| `email` | string | Must equal the auth token's email |
| `role` | `'technician'` \| `'admin'` | Created as `'technician'`; only an admin can change it |
| `shift` | string? | e.g. `'Shift #1 (08:00 - 16:00)'` |
| `createdAt` | timestamp | Server time |

### `machines/{machineId}`

Fields match `Machine.toMap()` in `frontend/lib/models/machine.dart`. Only admins can write machines.

| Field | Type | Notes |
|---|---|---|
| `name`, `code`, `location` | string | Required |
| `status` | `'Running'` \| `'Maintenance'` \| `'Breakdown'` \| `'Idle'` | Required |
| `lastInspected`, `model`, `serialNumber`, `assignedTech`, `installationDate` | string? | Display strings |

### `inspections/{inspectionId}`

Any signed-in user can create an inspection. Inspections can't be edited, and only admins can delete them.

| Field | Type | Notes |
|---|---|---|
| `machineId` | string | The machine must exist |
| `machineName`, `machineCode`, `machineLocation?` | string | Copied from the machine for list views |
| `condition` | `'Passed'` \| `'Needs Repair'` \| `'Critical'` | |
| `checklist` | map<string, bool> | At most 50 items |
| `notes` | string? | At most 2000 characters |
| `inspectorId` | string | Must equal the caller's uid |
| `inspectorName`, `shift?` | string | |
| `inspectedAt` | timestamp | The date and time picked on the form |
| `createdAt` | timestamp | Server time |

### `breakdowns/{breakdownId}`

Any signed-in user can report a breakdown. Afterwards, only the reporter or an admin can resolve it.

| Field | Type | Notes |
|---|---|---|
| `machineId` | string | The machine must exist |
| `machineName`, `machineCode`, `machineLocation?` | string | Copied from the machine |
| `title`, `description` | string | Required and non-blank |
| `severity` | `'Critical'` \| `'Needs Repair'` \| `'Warning'` | The UI's record maps call this `status` |
| `component?`, `priority?`, `shift?` | string | |
| `reportedById` | string | Must equal the caller's uid |
| `reportedByName` | string | |
| `resolved` | bool | Must be `false` on create |
| `resolvedAt`, `resolvedById`, `resolutionNotes?` | | Set once, when `resolved` flips to `true` |
| `createdAt` | timestamp | Server time |

### Indexes

- `inspections`: `machineId` + `createdAt desc`, and `inspectorId` + `createdAt desc`
- `breakdowns`: `machineId` + `createdAt desc`, and `resolved` + `createdAt desc`

## Roadmap

- [x] **Day 1:** Set up the backend folder, Firebase CLI config, data model, security rules, indexes, and rules tests on the emulator.
- [ ] **Day 2:** Cloud Functions (TypeScript, `functions/`):
  - create the `users/{uid}` profile on signup
  - set machine `status` when a breakdown is reported or resolved
  - update `lastInspected`/`status` after an inspection
  - test the functions against the emulator
- [ ] **Day 3:** Admin scripts:
  - seed the emulator and production with the sample machines from the frontend
  - `set-admin` script to promote a user
  - export and import emulator data for repeatable local dev
- [ ] **Day 4:** Frontend wiring:
  - add `InspectionService`, `BreakdownService` and `UserService` following the existing service conventions
  - switch the Machines, Records, New Inspection and Report Breakdown screens from sample maps to Firestore
- [ ] **Day 5:** Integration and release:
  - connect the Flutter app to the emulators in debug builds
  - add a GitHub Actions workflow for the backend tests
  - deploy rules, indexes and functions
  - update the docs
