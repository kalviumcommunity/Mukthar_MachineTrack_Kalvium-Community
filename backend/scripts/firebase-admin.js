import { existsSync, readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { deleteApp, getApp, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, Timestamp, getFirestore } from 'firebase-admin/firestore';

const __dirname = dirname(fileURLToPath(import.meta.url));

/**
 * Resolves the default production Firebase project ID from .firebaserc.
 */
function getDefaultProjectId() {
  const rcPath = resolve(__dirname, '../.firebaserc');
  if (existsSync(rcPath)) {
    try {
      const rc = JSON.parse(readFileSync(rcPath, 'utf8'));
      if (rc?.projects?.default) {
        return rc.projects.default;
      }
    } catch {
      // Ignore parse error and fall back
    }
  }
  return process.env.GCLOUD_PROJECT || 'machinetrack-701bd';
}

/**
 * Initializes and returns the Firebase Admin SDK instances.
 * Defaults to the local emulator for safety unless `prod: true` is passed.
 *
 * @param {object} options
 * @param {boolean} [options.prod=false] If true, connect to live Firebase production.
 * @param {boolean} [options.emulator=false] If true, explicitly connect to the local emulator.
 * @param {string} [options.project] Override project ID.
 */
export function initAdmin(options = {}) {
  const isProd = Boolean(options.prod);
  const isEmulator = !isProd;

  let projectId = options.project;
  if (!projectId) {
    projectId = isProd ? getDefaultProjectId() : 'demo-machinetrack';
  }

  if (isEmulator) {
    if (!process.env.FIRESTORE_EMULATOR_HOST) {
      process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';
    }
    if (!process.env.FIREBASE_AUTH_EMULATOR_HOST) {
      process.env.FIREBASE_AUTH_EMULATOR_HOST = '127.0.0.1:9099';
    }
  } else {
    delete process.env.FIRESTORE_EMULATOR_HOST;
    delete process.env.FIREBASE_AUTH_EMULATOR_HOST;
  }

  // Reuse existing default app if already initialized in this process
  let app;
  if (getApps().length > 0) {
    app = getApp();
  } else {
    app = initializeApp({ projectId });
  }

  const db = getFirestore(app);
  const auth = getAuth(app);

  return {
    app,
    db,
    auth,
    isEmulator,
    projectId,
    FieldValue,
    Timestamp,
    cleanup: async () => {
      try {
        await deleteApp(app);
      } catch {
        // App might already be deleted
      }
    },
  };
}
