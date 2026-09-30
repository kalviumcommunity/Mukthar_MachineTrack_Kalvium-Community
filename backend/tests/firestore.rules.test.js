// Security-rule tests. Run with `npm test`, which starts the Firestore emulator.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

const PROJECT_ID = 'demo-machinetrack';

const MACHINE = {
  name: 'CNC Lathe Machine #02',
  code: 'CNC-LTH-02',
  location: 'Zone B - Machining Cell',
  status: 'Running',
  model: 'LatheMatic 3000',
};

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});

after(async () => {
  await testEnv?.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/admin'), {
      name: 'Admin', email: 'admin@factory.com', role: 'admin', createdAt: Timestamp.now(),
    });
    await setDoc(doc(db, 'users/tech'), {
      name: 'Mukthar', email: 'tech@factory.com', role: 'technician', createdAt: Timestamp.now(),
    });
    await setDoc(doc(db, 'machines/m2'), MACHINE);
  });
});

const techDb = () => testEnv.authenticatedContext('tech', { email: 'tech@factory.com' }).firestore();
const otherTechDb = () => testEnv.authenticatedContext('other', { email: 'other@factory.com' }).firestore();
const adminDb = () => testEnv.authenticatedContext('admin', { email: 'admin@factory.com' }).firestore();
const guestDb = () => testEnv.unauthenticatedContext().firestore();

const newInspection = (overrides = {}) => ({
  machineId: 'm2',
  machineName: MACHINE.name,
  machineCode: MACHINE.code,
  machineLocation: MACHINE.location,
  condition: 'Passed',
  checklist: { 'Oil level': true, 'Safety guards': true },
  notes: 'All good',
  inspectorId: 'tech',
  inspectorName: 'Mukthar',
  shift: 'Shift #1 (08:00 - 16:00)',
  inspectedAt: Timestamp.now(),
  createdAt: serverTimestamp(),
  ...overrides,
});

const newBreakdown = (overrides = {}) => ({
  machineId: 'm2',
  machineName: MACHINE.name,
  machineCode: MACHINE.code,
  title: 'Spindle overheating',
  description: 'Spindle temperature above 90C after 20 minutes.',
  severity: 'Critical',
  component: 'Mechanical Subsystem',
  priority: 'Urgent / Line Halt',
  reportedById: 'tech',
  reportedByName: 'Mukthar',
  resolved: false,
  createdAt: serverTimestamp(),
  ...overrides,
});

describe('default deny', () => {
  test('unknown collections are closed', async () => {
    await assertFails(setDoc(doc(adminDb(), 'secrets/x'), { a: 1 }));
    await assertFails(getDoc(doc(adminDb(), 'secrets/x')));
  });
});

describe('users', () => {
  const profile = (overrides = {}) => ({
    name: 'New Tech', email: 'other@factory.com', role: 'technician', createdAt: serverTimestamp(),
    ...overrides,
  });

  test('guests cannot read profiles', async () => {
    await assertFails(getDoc(doc(guestDb(), 'users/tech')));
  });

  test('signed-in users can read profiles', async () => {
    await assertSucceeds(getDoc(doc(techDb(), 'users/admin')));
  });

  test('user can create own technician profile', async () => {
    await assertSucceeds(setDoc(doc(otherTechDb(), 'users/other'), profile()));
  });

  test('user cannot create a profile for someone else', async () => {
    await assertFails(setDoc(doc(otherTechDb(), 'users/someone'), profile()));
  });

  test('user cannot self-assign admin', async () => {
    await assertFails(setDoc(doc(otherTechDb(), 'users/other'), profile({ role: 'admin' })));
  });

  test('profile email must match the auth token', async () => {
    await assertFails(setDoc(doc(otherTechDb(), 'users/other'), profile({ email: 'fake@x.com' })));
  });

  test('user can rename themselves but not change role', async () => {
    await assertSucceeds(updateDoc(doc(techDb(), 'users/tech'), { name: 'Mukthar K' }));
    await assertFails(updateDoc(doc(techDb(), 'users/tech'), { role: 'admin' }));
  });

  test('admin can promote a user', async () => {
    await assertSucceeds(updateDoc(doc(adminDb(), 'users/tech'), { role: 'admin' }));
  });

  test('nobody can delete profiles', async () => {
    await assertFails(deleteDoc(doc(adminDb(), 'users/tech')));
  });
});

describe('machines', () => {
  test('guests cannot read machines', async () => {
    await assertFails(getDoc(doc(guestDb(), 'machines/m2')));
  });

  test('technicians can read but not write machines', async () => {
    await assertSucceeds(getDoc(doc(techDb(), 'machines/m2')));
    await assertFails(setDoc(doc(techDb(), 'machines/m9'), MACHINE));
    await assertFails(updateDoc(doc(techDb(), 'machines/m2'), { status: 'Idle' }));
  });

  test('admin can create, update and delete machines', async () => {
    await assertSucceeds(setDoc(doc(adminDb(), 'machines/m9'), MACHINE));
    await assertSucceeds(updateDoc(doc(adminDb(), 'machines/m9'), { status: 'Maintenance' }));
    await assertSucceeds(deleteDoc(doc(adminDb(), 'machines/m9')));
  });

  test('status must be a known value', async () => {
    await assertFails(setDoc(doc(adminDb(), 'machines/m9'), { ...MACHINE, status: 'Broken' }));
  });

  test('unknown fields are rejected', async () => {
    await assertFails(setDoc(doc(adminDb(), 'machines/m9'), { ...MACHINE, price: 10 }));
  });
});

describe('inspections', () => {
  test('technician can log a valid inspection', async () => {
    await assertSucceeds(setDoc(doc(techDb(), 'inspections/i1'), newInspection()));
  });

  test('guests cannot log inspections', async () => {
    await assertFails(setDoc(doc(guestDb(), 'inspections/i1'), newInspection()));
  });

  test('inspector id must be the caller', async () => {
    await assertFails(setDoc(doc(techDb(), 'inspections/i1'), newInspection({ inspectorId: 'admin' })));
  });

  test('condition must be a known value', async () => {
    await assertFails(setDoc(doc(techDb(), 'inspections/i1'), newInspection({ condition: 'Fine' })));
  });

  test('machine must exist', async () => {
    await assertFails(setDoc(doc(techDb(), 'inspections/i1'), newInspection({ machineId: 'nope' })));
  });

  test('createdAt must be the server time', async () => {
    await assertFails(setDoc(doc(techDb(), 'inspections/i1'), newInspection({ createdAt: Timestamp.now() })));
  });

  test('inspections are immutable; only admins delete', async () => {
    await assertSucceeds(setDoc(doc(techDb(), 'inspections/i1'), newInspection()));
    await assertFails(updateDoc(doc(techDb(), 'inspections/i1'), { condition: 'Critical' }));
    await assertFails(deleteDoc(doc(techDb(), 'inspections/i1')));
    await assertSucceeds(deleteDoc(doc(adminDb(), 'inspections/i1')));
  });
});

describe('breakdowns', () => {
  const resolve = (uid) => ({
    resolved: true, resolvedAt: serverTimestamp(), resolvedById: uid, resolutionNotes: 'Replaced bearing',
  });

  test('technician can report a valid breakdown', async () => {
    await assertSucceeds(setDoc(doc(techDb(), 'breakdowns/b1'), newBreakdown()));
  });

  test('new breakdowns cannot start resolved', async () => {
    await assertFails(setDoc(doc(techDb(), 'breakdowns/b1'), newBreakdown({ resolved: true })));
  });

  test('severity must be a known value', async () => {
    await assertFails(setDoc(doc(techDb(), 'breakdowns/b1'), newBreakdown({ severity: 'Meh' })));
  });

  test('description is required', async () => {
    await assertFails(setDoc(doc(techDb(), 'breakdowns/b1'), newBreakdown({ description: '   ' })));
  });

  test('reporter can resolve their breakdown', async () => {
    await assertSucceeds(setDoc(doc(techDb(), 'breakdowns/b1'), newBreakdown()));
    await assertSucceeds(updateDoc(doc(techDb(), 'breakdowns/b1'), resolve('tech')));
  });

  test('admin can resolve any breakdown', async () => {
    await assertSucceeds(setDoc(doc(techDb(), 'breakdowns/b1'), newBreakdown()));
    await assertSucceeds(updateDoc(doc(adminDb(), 'breakdowns/b1'), resolve('admin')));
  });

  test('other technicians cannot resolve it', async () => {
    await assertSucceeds(setDoc(doc(techDb(), 'breakdowns/b1'), newBreakdown()));
    await assertFails(updateDoc(doc(otherTechDb(), 'breakdowns/b1'), resolve('other')));
  });

  test('other fields cannot be edited', async () => {
    await assertSucceeds(setDoc(doc(techDb(), 'breakdowns/b1'), newBreakdown()));
    await assertFails(updateDoc(doc(techDb(), 'breakdowns/b1'), { severity: 'Warning' }));
  });

  test('a resolved breakdown cannot be resolved again', async () => {
    await assertSucceeds(setDoc(doc(techDb(), 'breakdowns/b1'), newBreakdown()));
    await assertSucceeds(updateDoc(doc(techDb(), 'breakdowns/b1'), resolve('tech')));
    await assertFails(updateDoc(doc(techDb(), 'breakdowns/b1'), resolve('tech')));
  });
});
