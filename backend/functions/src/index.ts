import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { setGlobalOptions } from 'firebase-functions';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import * as functionsV1 from 'firebase-functions/v1';
import { syncMachine } from './syncMachine.js';

initializeApp();
setGlobalOptions({ maxInstances: 10 });

/**
 * Creates the users/{uid} profile when someone signs up. The profile always
 * starts as a technician; promote admins with an admin-side script.
 *
 * Auth onCreate triggers only exist in the v1 API.
 */
export const createUserProfile = functionsV1.auth.user().onCreate(async (user) => {
  const email = user.email ?? '';
  const name = user.displayName?.trim() || email.split('@')[0] || 'Technician';
  try {
    await getFirestore().collection('users').doc(user.uid).create({
      name,
      email,
      role: 'technician',
      createdAt: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    // The app may have created the profile first; leave it alone.
    if ((error as { code?: number }).code === 6 /* ALREADY_EXISTS */) return;
    throw error;
  }
});

/** Keeps the machine's status and lastInspectedAt in step with its inspections. */
export const syncMachineOnInspection = onDocumentWritten('inspections/{inspectionId}', async (event) => {
  await syncMachinesFor(event.data?.before.get('machineId'), event.data?.after.get('machineId'));
});

/** Keeps the machine's status in step with its breakdowns being reported and resolved. */
export const syncMachineOnBreakdown = onDocumentWritten('breakdowns/{breakdownId}', async (event) => {
  await syncMachinesFor(event.data?.before.get('machineId'), event.data?.after.get('machineId'));
});

async function syncMachinesFor(...machineIds: unknown[]): Promise<void> {
  const ids = new Set(machineIds.filter((id): id is string => typeof id === 'string' && id !== ''));
  await Promise.all([...ids].map(syncMachine));
}
