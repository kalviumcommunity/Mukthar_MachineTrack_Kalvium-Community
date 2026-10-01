// End-to-end tests for the Cloud Functions triggers. Run with
// `npm run test:functions`, which starts the Auth, Firestore and Functions
// emulators and sets the *_EMULATOR_HOST variables the Admin SDK reads.
import assert from 'node:assert/strict';
import { after, before, describe, test } from 'node:test';
import { deleteApp, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, Timestamp, getFirestore } from 'firebase-admin/firestore';

const PROJECT_ID = 'demo-machinetrack';
const app = initializeApp({ projectId: PROJECT_ID });
const db = getFirestore(app);
const auth = getAuth(app);

/** Polls until `check` stops throwing, so tests can wait for async triggers. */
async function eventually(check, timeoutMs = 10_000) {
  const deadline = Date.now() + timeoutMs;
  for (;;) {
    try {
      return await check();
    } catch (error) {
      if (Date.now() > deadline) throw error;
      await new Promise((resolve) => setTimeout(resolve, 200));
    }
  }
}

async function machineStatus(id) {
  return (await db.doc(`machines/${id}`).get()).get('status');
}

let counter = 0;
const uniqueId = (prefix) => `${prefix}-${Date.now()}-${counter++}`;

async function addMachine(status = 'Running') {
  const id = uniqueId('machine');
  await db.doc(`machines/${id}`).set({
    name: 'CNC Lathe Machine #02', code: 'CNC-LTH-02', location: 'Zone B', status,
  });
  return id;
}

function addInspection(machineId, condition, inspectedAt = Timestamp.now()) {
  return db.collection('inspections').add({
    machineId, machineName: 'CNC Lathe Machine #02', machineCode: 'CNC-LTH-02',
    condition, checklist: { 'Oil level': true }, inspectorId: 'tech', inspectorName: 'Mukthar',
    inspectedAt, createdAt: FieldValue.serverTimestamp(),
  });
}

function addBreakdown(machineId, severity) {
  return db.collection('breakdowns').add({
    machineId, machineName: 'CNC Lathe Machine #02', machineCode: 'CNC-LTH-02',
    title: 'Spindle overheating', description: 'Too hot', severity,
    reportedById: 'tech', reportedByName: 'Mukthar', resolved: false,
    createdAt: FieldValue.serverTimestamp(),
  });
}

const resolve = (ref) => ref.update({
  resolved: true, resolvedAt: FieldValue.serverTimestamp(), resolvedById: 'tech',
});

// Each test uses its own machine and user, so data isn't cleared between tests.
before(() => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST, 'Run via `npm run test:functions` so the emulators are up');
});

after(async () => {
  await deleteApp(app);
});

describe('createUserProfile', () => {
  test('creates a technician profile on signup', async () => {
    const user = await auth.createUser({
      email: `${uniqueId('tech')}@factory.com`, password: 'secret123', displayName: 'Mukthar',
    });
    const profile = await eventually(async () => {
      const snap = await db.doc(`users/${user.uid}`).get();
      assert.ok(snap.exists, 'profile not created yet');
      return snap.data();
    });
    assert.equal(profile.name, 'Mukthar');
    assert.equal(profile.email, user.email);
    assert.equal(profile.role, 'technician');
    assert.ok(profile.createdAt instanceof Timestamp);
  });

  test('falls back to the email name when there is no display name', async () => {
    const local = uniqueId('nodisplay');
    const user = await auth.createUser({ email: `${local}@factory.com`, password: 'secret123' });
    await eventually(async () => {
      assert.equal((await db.doc(`users/${user.uid}`).get()).get('name'), local);
    });
  });

  test('keeps a profile the app already created', async () => {
    const uid = uniqueId('uid');
    await db.doc(`users/${uid}`).set({ name: 'From App', email: 'x@factory.com', role: 'technician' });
    await auth.createUser({ uid, email: `${uid}@factory.com`, password: 'secret123', displayName: 'From Auth' });
    // Give the trigger time to run, then confirm it didn't overwrite anything.
    await new Promise((resolve) => setTimeout(resolve, 2000));
    assert.equal((await db.doc(`users/${uid}`).get()).get('name'), 'From App');
  });
});

describe('syncMachineOnBreakdown', () => {
  test('critical breakdown sets Breakdown, resolving it restores Running', async () => {
    const machineId = await addMachine('Running');
    const ref = await addBreakdown(machineId, 'Critical');
    await eventually(async () => assert.equal(await machineStatus(machineId), 'Breakdown'));

    await resolve(ref);
    await eventually(async () => assert.equal(await machineStatus(machineId), 'Running'));
  });

  test('stays down until every serious breakdown is resolved', async () => {
    const machineId = await addMachine('Running');
    const critical = await addBreakdown(machineId, 'Critical');
    await addBreakdown(machineId, 'Needs Repair');
    await eventually(async () => assert.equal(await machineStatus(machineId), 'Breakdown'));

    await resolve(critical);
    await eventually(async () => assert.equal(await machineStatus(machineId), 'Maintenance'));
  });

  test('warning leaves an idle machine idle', async () => {
    const machineId = await addMachine('Idle');
    await addBreakdown(machineId, 'Warning');
    // Nothing should change, so give the trigger time to run before checking.
    await new Promise((resolve) => setTimeout(resolve, 2000));
    assert.equal(await machineStatus(machineId), 'Idle');
  });
});

describe('syncMachineOnInspection', () => {
  test('sets lastInspectedAt and status from the latest inspection', async () => {
    const machineId = await addMachine('Running');
    const inspectedAt = Timestamp.fromDate(new Date('2026-10-01T08:30:00Z'));
    await addInspection(machineId, 'Needs Repair', inspectedAt);

    await eventually(async () => {
      const machine = (await db.doc(`machines/${machineId}`).get()).data();
      assert.equal(machine.status, 'Maintenance');
      assert.ok(machine.lastInspectedAt?.isEqual(inspectedAt));
    });

    await addInspection(machineId, 'Passed');
    await eventually(async () => assert.equal(await machineStatus(machineId), 'Running'));
  });

  test('passed inspection does not clear an open critical breakdown', async () => {
    const machineId = await addMachine('Running');
    await addBreakdown(machineId, 'Critical');
    await eventually(async () => assert.equal(await machineStatus(machineId), 'Breakdown'));

    await addInspection(machineId, 'Passed');
    await eventually(async () => {
      assert.ok((await db.doc(`machines/${machineId}`).get()).get('lastInspectedAt'));
    });
    assert.equal(await machineStatus(machineId), 'Breakdown');
  });

  test('records for a missing machine are ignored without crashing', async () => {
    const ref = await addInspection('does-not-exist', 'Critical');
    await new Promise((resolve) => setTimeout(resolve, 1000));
    assert.ok((await ref.get()).exists);
    assert.equal((await db.doc('machines/does-not-exist').get()).exists, false);
  });
});
