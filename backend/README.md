# MachineTrack Backend

The Firebase backend for the MachineTrack Flutter app (project `machinetrack-701bd`). The app reads and writes Cloud Firestore directly, so this folder holds the server-side pieces:

| File | Purpose |
|---|---|
| `firebase.json` | Firebase CLI config for Firestore and the local emulators |
| `.firebaserc` | Default project alias (`machinetrack-701bd`) |
| `firestore.rules` | Security rules, which are also the schema validation |
| `firestore.indexes.json` | Composite indexes for the app's record queries |
| `functions/` | Cloud Functions (TypeScript) that react to signups and record writes |
| `tests/` | Rules tests and end-to-end trigger tests that run against the emulators |

The FlutterFire config (`frontend/firebase.json`) stays in `frontend/`. The two files don't overlap.

## Setup

You need Node 20 or newer and Java 21 or newer, because the Firestore emulator needs Java.

```bash
cd backend
npm install
npm install --prefix functions
npm test                # all tests (rules, functions, and admin scripts)
npm run test:rules      # security rules on the Firestore emulator
npm run test:functions  # function unit tests, then triggers on the emulators
npm run test:scripts    # tests for seed and set-admin scripts
npm run emulators       # builds functions, starts all emulators, UI at http://localhost:4000
npm run emulators:data  # starts emulators importing ./emulator-data and exporting on exit
npm run emulators:export # exports current emulator state to ./emulator-data
```

### Admin Scripts

Scripts to manage machines and user roles live in `scripts/`:

```bash
# Seeding machines (sample fleet from frontend)
npm run seed             # seed to local emulator (demo-machinetrack)
npm run seed:prod        # seed to live production (machinetrack-701bd)
node scripts/seed-machines.js --clear  # wipe existing fleet before seeding

# Role management (updates Firestore profile and Auth custom claims)
npm run set-admin -- user@factory.com        # promote user on emulator
npm run set-admin:prod -- user@factory.com   # promote user on production
npm run set-admin -- <uid>                   # promote by Auth UID
npm run set-admin -- user@factory.com --revoke  # demote back to technician
```

The emulators use the `demo-machinetrack` project ID, so local runs never touch production data.

Deploys are manual. Log in first with `npx firebase login`:

```bash
npm run deploy:rules       # Firestore rules and indexes
npm run deploy:functions   # Cloud Functions (needs the Blaze plan)
```

## Cloud Functions

The functions live in `functions/src/` and are compiled to `functions/lib/` with `npm --prefix functions run build`. They target Node 22.

| Function | Trigger | What it does |
|---|---|---|
| `createUserProfile` | Auth user created (v1 API) | Creates `users/{uid}` with `role: 'technician'`. The name is the display name, or the part of the email before the `@` if there isn't one. If the app already created the profile, it's left alone. |
| `syncMachineOnInspection` | `inspections/{id}` written | Recomputes the machine's `status` and `lastInspectedAt` |
| `syncMachineOnBreakdown` | `breakdowns/{id}` written | Recomputes the machine's `status` |

Both sync triggers call `syncMachine` (`functions/src/syncMachine.ts`). In a transaction, it reads the machine, its open breakdowns and its latest inspection, then derives the status with `deriveMachineStatus` (`functions/src/machineStatus.ts`):

1. Any open `Critical` breakdown, or a latest inspection that's `Critical`, makes the machine `Breakdown`.
2. Otherwise, any `Needs Repair` makes it `Maintenance`.
3. `Warning` breakdowns and `Passed` inspections never take a machine down.
4. When nothing is wrong, a machine in `Breakdown` or `Maintenance` goes back to `Running`. `Running` and `Idle` are left as they are.

The status is recomputed from scratch each time, so it's correct no matter what order events arrive in or how often they're retried. One consequence: if an admin manually sets a machine to `Maintenance`, the next record for that machine resets it to `Running` unless that record shows a problem.

To clear a `Critical` or `Needs Repair` inspection, log a newer inspection that passes. To clear a breakdown, resolve it.

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
| `lastInspectedAt` | timestamp? | Set by `syncMachineOnInspection` from the latest inspection's `inspectedAt`. Format it in the app (e.g. "25 mins ago"). |

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
- [x] **Day 2:** Cloud Functions (TypeScript, `functions/`):
  - create the `users/{uid}` profile on signup
  - set machine `status` when a breakdown is reported or resolved
  - update `lastInspectedAt`/`status` after an inspection
  - unit tests for the status rules, and end-to-end trigger tests on the emulators
- [x] **Day 3:** Admin scripts:
  - seed the emulator and production with the sample machines from the frontend
  - `set-admin` script to promote a user
  - export and import emulator data for repeatable local dev
- [x] **Day 4:** Frontend wiring:
  - add `InspectionService`, `BreakdownService` and `UserService` following the existing service conventions
  - switch the Machines, Records, New Inspection and Report Breakdown screens from sample maps to Firestore
  - add `lastInspectedAt` to the `Machine` model and show it as relative time
- [x] **Day 5:** Integration and release:
  - connect the Flutter app to the emulators in debug builds
  - add a GitHub Actions workflow for the backend tests
  - deploy rules, indexes and functions
  - update the docs
