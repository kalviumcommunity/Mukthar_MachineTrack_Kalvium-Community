import assert from 'node:assert/strict';
import { after, before, beforeEach, describe, test } from 'node:test';
import { deleteApp, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { Timestamp, getFirestore } from 'firebase-admin/firestore';
import { seedMachines } from '../scripts/seed-machines.js';
import { setAdmin } from '../scripts/set-admin.js';

const PROJECT_ID = 'demo-machinetrack';
const app = initializeApp({ projectId: PROJECT_ID });
const db = getFirestore(app);
const auth = getAuth(app);

const silentLogger = {
  log: () => {},
  warn: () => {},
  error: () => {},
};

describe('Day 3 Admin Scripts', () => {
  beforeEach(async () => {
    // Clear machines collection
    const machinesSnap = await db.collection('machines').get();
    if (!machinesSnap.empty) {
      const b = db.batch();
      machinesSnap.docs.forEach((d) => b.delete(d.ref));
      await b.commit();
    }

    // Clear users collection
    const usersSnap = await db.collection('users').get();
    if (!usersSnap.empty) {
      const b = db.batch();
      usersSnap.docs.forEach((d) => b.delete(d.ref));
      await b.commit();
    }
  });

  after(async () => {
    try {
      await deleteApp(app);
    } catch {
      // Ignore
    }
  });

  describe('seedMachines', () => {
    test('seeds the 5 sample machines from the frontend dataset', async () => {
      const result = await seedMachines({
        project: PROJECT_ID,
        logger: silentLogger,
      });

      assert.equal(result.count, 5);
      assert.equal(result.isEmulator, true);
      assert.equal(result.projectId, PROJECT_ID);

      const machinesSnap = await db.collection('machines').get();
      assert.equal(machinesSnap.size, 5);

      const machine1Doc = await db.collection('machines').doc('1').get();
      assert.equal(machine1Doc.exists, true);
      const m1 = machine1Doc.data();
      assert.equal(m1.name, 'Hydraulic Press 500T');
      assert.equal(m1.code, 'PRESS-500T-04');
      assert.equal(m1.location, 'Zone A - Stamping Line');
      assert.equal(m1.status, 'Breakdown');
      assert.equal(m1.lastInspected, '25 mins ago');
      assert.equal(m1.model, 'StamperPro 500');
      assert.equal(m1.serialNumber, 'SN-99812-A');
      assert.equal(m1.assignedTech, 'Mukthar');
      // id should not be in doc data (matches validMachine schema)
      assert.equal(m1.id, undefined);

      const machine2Doc = await db.collection('machines').doc('2').get();
      const m2 = machine2Doc.data();
      assert.equal(m2.code, 'CNC-LTH-02');
      assert.equal(m2.status, 'Running');

      const machine3Doc = await db.collection('machines').doc('3').get();
      const m3 = machine3Doc.data();
      assert.equal(m3.code, 'CNV-BELT-05');
      assert.equal(m3.status, 'Maintenance');

      const machine4Doc = await db.collection('machines').doc('4').get();
      const m4 = machine4Doc.data();
      assert.equal(m4.code, 'ROB-WLD-01');
      assert.equal(m4.status, 'Running');

      const machine5Doc = await db.collection('machines').doc('5').get();
      const m5 = machine5Doc.data();
      assert.equal(m5.code, 'INJ-MLD-03');
      assert.equal(m5.status, 'Idle');
    });

    test('is idempotent when run multiple times', async () => {
      await seedMachines({ project: PROJECT_ID, logger: silentLogger });
      await seedMachines({ project: PROJECT_ID, logger: silentLogger });

      const machinesSnap = await db.collection('machines').get();
      assert.equal(machinesSnap.size, 5);
    });

    test('clears existing machines first if clear: true is specified', async () => {
      // Add an extra machine that isn't in the sample set
      await db.collection('machines').doc('extra-1').set({
        name: 'Extra Machine',
        code: 'EXT-01',
        location: 'Zone Z',
        status: 'Idle',
      });

      const beforeSnap = await db.collection('machines').get();
      assert.equal(beforeSnap.size, 1);

      await seedMachines({
        project: PROJECT_ID,
        clear: true,
        logger: silentLogger,
      });

      const afterSnap = await db.collection('machines').get();
      assert.equal(afterSnap.size, 5);
      const extraDoc = await db.collection('machines').doc('extra-1').get();
      assert.equal(extraDoc.exists, false);
    });

    test('rejects machine data with invalid status', async () => {
      await assert.rejects(
        async () => {
          await seedMachines({
            project: PROJECT_ID,
            machines: [
              {
                id: 'bad-1',
                name: 'Bad Machine',
                code: 'BAD-01',
                location: 'Zone B',
                status: 'UnknownStatus',
              },
            ],
            logger: silentLogger,
          });
        },
        {
          message: /invalid 'status' "UnknownStatus"/,
        }
      );
    });

    test('rejects machine data with missing required fields', async () => {
      await assert.rejects(
        async () => {
          await seedMachines({
            project: PROJECT_ID,
            machines: [
              {
                id: 'bad-2',
                code: 'BAD-02',
                location: 'Zone B',
                status: 'Running',
              },
            ],
            logger: silentLogger,
          });
        },
        {
          message: /missing or invalid 'name'/,
        }
      );
    });
  });

  describe('setAdmin', () => {
    let testUid;
    const testEmail = `tech-${Date.now()}@factory.com`;

    before(async () => {
      // Create a test user in Auth
      const user = await auth.createUser({
        email: testEmail,
        displayName: 'Test Tech',
      });
      testUid = user.uid;
    });

    after(async () => {
      if (testUid) {
        try {
          await auth.deleteUser(testUid);
        } catch {
          // Ignore cleanup error
        }
      }
    });

    test('promotes a user to admin by email and updates both Auth claims and Firestore doc', async () => {
      // Preset user doc as technician
      await db.collection('users').doc(testUid).set({
        name: 'Test Tech',
        email: testEmail,
        role: 'technician',
        createdAt: Timestamp.now(),
      });

      const res = await setAdmin(testEmail, {
        project: PROJECT_ID,
        logger: silentLogger,
      });

      assert.equal(res.uid, testUid);
      assert.equal(res.role, 'admin');

      // Check Firestore doc role
      const userDoc = await db.collection('users').doc(testUid).get();
      assert.equal(userDoc.get('role'), 'admin');

      // Check Auth custom claims
      const authUser = await auth.getUser(testUid);
      assert.equal(authUser.customClaims?.admin, true);
    });

    test('promotes a user by UID', async () => {
      const res = await setAdmin(testUid, {
        project: PROJECT_ID,
        logger: silentLogger,
      });

      assert.equal(res.uid, testUid);
      assert.equal(res.role, 'admin');

      const userDoc = await db.collection('users').doc(testUid).get();
      assert.equal(userDoc.get('role'), 'admin');
    });

    test('creates the Firestore user profile if missing when promoting an Auth user', async () => {
      const emailOnlyUser = await auth.createUser({
        email: `new-${Date.now()}@factory.com`,
        displayName: 'New Operator',
      });

      try {
        const res = await setAdmin(emailOnlyUser.email, {
          project: PROJECT_ID,
          logger: silentLogger,
        });

        assert.equal(res.role, 'admin');
        const docSnap = await db.collection('users').doc(emailOnlyUser.uid).get();
        assert.equal(docSnap.exists, true);
        assert.equal(docSnap.get('role'), 'admin');
        assert.equal(docSnap.get('name'), 'New Operator');
        assert.equal(docSnap.get('email'), emailOnlyUser.email);
      } finally {
        await auth.deleteUser(emailOnlyUser.uid);
      }
    });

    test('demotes an admin back to technician with revoke: true', async () => {
      // First ensure user is admin
      await setAdmin(testEmail, { project: PROJECT_ID, logger: silentLogger });

      // Now revoke
      const res = await setAdmin(testEmail, {
        project: PROJECT_ID,
        revoke: true,
        logger: silentLogger,
      });

      assert.equal(res.role, 'technician');

      const userDoc = await db.collection('users').doc(testUid).get();
      assert.equal(userDoc.get('role'), 'technician');

      const authUser = await auth.getUser(testUid);
      assert.equal(authUser.customClaims?.admin, false);
    });

    test('throws when user cannot be found', async () => {
      await assert.rejects(
        async () => {
          await setAdmin('nonexistent@factory.com', {
            project: PROJECT_ID,
            logger: silentLogger,
          });
        },
        {
          message: /User not found/,
        }
      );
    });

    test('throws when identifier is empty', async () => {
      await assert.rejects(
        async () => {
          await setAdmin('', {
            project: PROJECT_ID,
            logger: silentLogger,
          });
        },
        {
          message: /A user email or UID must be provided/,
        }
      );
    });
  });
});
