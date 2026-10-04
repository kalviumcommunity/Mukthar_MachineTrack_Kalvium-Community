import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { initAdmin } from './firebase-admin.js';

/**
 * Promotes a user to admin or demotes them back to technician.
 *
 * Updates both the Firestore `users/{uid}` document (`role: 'admin'`)
 * and the Firebase Auth custom user claims (`admin: true`).
 *
 * @param {string} identifier User email address or UID.
 * @param {object} options
 * @param {boolean} [options.prod=false] Connect to live Firebase production.
 * @param {boolean} [options.emulator=false] Connect to local emulator.
 * @param {boolean} [options.revoke=false] Demote user to 'technician'.
 * @param {string} [options.project] Firebase project ID override.
 * @param {object} [options.logger=console] Custom logger.
 */
export async function setAdmin(identifier, options = {}) {
  const logger = options.logger || console;

  if (!identifier || typeof identifier !== 'string' || identifier.trim().length === 0) {
    throw new Error('A user email or UID must be provided.');
  }

  const cleanId = identifier.trim();
  const { auth, db, FieldValue, isEmulator, projectId } = initAdmin(options);

  const targetRole = options.revoke ? 'technician' : 'admin';
  const isAdminClaim = targetRole === 'admin';

  let userRecord = null;
  let uid = null;
  let email = null;
  let existingProfile = null;

  try {
    // 1. Try resolving via Firebase Auth
    if (cleanId.includes('@')) {
      try {
        userRecord = await auth.getUserByEmail(cleanId);
        uid = userRecord.uid;
        email = userRecord.email;
      } catch (err) {
        if (err.code !== 'auth/user-not-found') throw err;
      }
    } else {
      try {
        userRecord = await auth.getUser(cleanId);
        uid = userRecord.uid;
        email = userRecord.email;
      } catch (err) {
        if (err.code !== 'auth/user-not-found') throw err;
      }
    }

    // 2. If not found in Auth, check Firestore users collection directly
    if (!uid) {
      if (cleanId.includes('@')) {
        const querySnap = await db.collection('users').where('email', '==', cleanId).limit(1).get();
        if (!querySnap.empty) {
          const doc = querySnap.docs[0];
          uid = doc.id;
          existingProfile = doc.data();
          email = existingProfile.email;
        }
      } else {
        const docSnap = await db.collection('users').doc(cleanId).get();
        if (docSnap.exists) {
          uid = docSnap.id;
          existingProfile = docSnap.data();
          email = existingProfile.email;
        }
      }
    }

    if (!uid) {
      throw new Error(`User not found with email or UID: "${cleanId}". Ensure the account exists first.`);
    }

    // 3. Set Auth custom claims if user exists in Firebase Auth
    if (userRecord) {
      const currentClaims = userRecord.customClaims || {};
      await auth.setCustomUserClaims(uid, {
        ...currentClaims,
        admin: isAdminClaim,
      });
      logger.log(`Updated Auth custom claims for UID: ${uid} (admin: ${isAdminClaim})`);
    }

    // 4. Update Firestore user document
    const userRef = db.collection('users').doc(uid);
    const userDoc = await userRef.get();

    if (userDoc.exists) {
      await userRef.update({ role: targetRole });
      existingProfile = userDoc.data();
    } else {
      const displayName = userRecord?.displayName?.trim() || email?.split('@')[0] || 'User';
      await userRef.set({
        name: displayName,
        email: email || '',
        role: targetRole,
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    return {
      uid,
      email: email || userRecord?.email || existingProfile?.email || 'N/A',
      role: targetRole,
      isEmulator,
      projectId,
    };
  } catch (error) {
    if (
      isEmulator &&
      (error.code === 14 ||
        error.message?.includes('ECONNREFUSED') ||
        error.message?.includes('UNAVAILABLE'))
    ) {
      const host = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
      throw new Error(
        `Could not connect to Firebase emulator at ${host}.\n` +
          `Make sure the emulator is running: npm run emulators (or pass --prod for production).`
      );
    }
    throw error;
  }
}

// CLI Execution
if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  const { values, positionals } = parseArgs({
    options: {
      prod: { type: 'boolean', default: false },
      emulator: { type: 'boolean', default: false },
      revoke: { type: 'boolean', default: false },
      project: { type: 'string' },
      help: { type: 'boolean', short: 'h', default: false },
    },
    allowPositionals: true,
  });

  const identifier = positionals[0];

  if (values.help || !identifier) {
    console.log(`
MachineTrack - Set Admin Role
Promotes a user to admin in Firestore (role: 'admin') and Firebase Auth (admin claim).

Usage:
  node scripts/set-admin.js <email-or-uid> [options]

Examples:
  node scripts/set-admin.js tech@factory.com
  node scripts/set-admin.js tech@factory.com --prod
  node scripts/set-admin.js user_12345 --revoke

Options:
  --prod           Target live Firebase production project (default: demo emulator)
  --emulator       Target local Firebase emulator
  --revoke         Demote user back to technician
  --project <id>   Override Firebase project ID
  -h, --help       Show this help message
`);
    process.exit(values.help ? 0 : 1);
  }

  (async () => {
    try {
      const targetLabel = values.prod ? 'Production' : 'Local Emulator';
      const actionLabel = values.revoke ? 'Demoting user to technician' : 'Promoting user to admin';
      console.log(`\n🔑 ${actionLabel} on ${targetLabel}...`);

      const result = await setAdmin(identifier, values);

      console.log(`\nTarget Project: ${result.projectId} (${result.isEmulator ? 'Emulator' : 'Production'})`);
      console.log(`User: ${result.email} (UID: ${result.uid})`);
      console.log(`Assigned Role: ${result.role}`);
      console.log(`\n✨ Role updated successfully!\n`);
      process.exit(0);
    } catch (err) {
      console.error(`\n❌ Failed to set admin role: ${err.message}\n`);
      process.exit(1);
    }
  })();
}
