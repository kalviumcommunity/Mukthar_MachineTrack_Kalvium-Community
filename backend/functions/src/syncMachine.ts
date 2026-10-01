import { FieldValue, getFirestore, Timestamp } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { deriveMachineStatus } from './machineStatus.js';

/**
 * Recomputes a machine's `status` and `lastInspectedAt` from its open
 * breakdowns and latest inspection.
 *
 * It reads everything from scratch inside a transaction, so it's safe to run
 * for any record change, in any order, and more than once.
 */
export async function syncMachine(machineId: string): Promise<void> {
  const db = getFirestore();
  const machineRef = db.collection('machines').doc(machineId);
  const openBreakdowns = db
    .collection('breakdowns')
    .where('machineId', '==', machineId)
    .where('resolved', '==', false);
  const latestInspection = db
    .collection('inspections')
    .where('machineId', '==', machineId)
    .orderBy('createdAt', 'desc')
    .limit(1);

  await db.runTransaction(async (tx) => {
    const machine = await tx.get(machineRef);
    if (!machine.exists) {
      logger.warn('Skipping sync for a machine that does not exist', { machineId });
      return;
    }

    const [breakdowns, inspections] = await Promise.all([
      tx.get(openBreakdowns),
      tx.get(latestInspection),
    ]);
    const latest = inspections.docs[0]?.data();

    const current = machine.data() ?? {};
    const status = deriveMachineStatus({
      currentStatus: String(current.status ?? 'Idle'),
      openBreakdownSeverities: breakdowns.docs.map((d) => String(d.get('severity'))),
      latestInspectionCondition: latest?.condition,
    });
    const lastInspectedAt: Timestamp | undefined = latest?.inspectedAt;

    const update: Record<string, unknown> = {};
    if (status !== current.status) update.status = status;
    if (lastInspectedAt && !lastInspectedAt.isEqual(current.lastInspectedAt ?? Timestamp.fromMillis(0))) {
      update.lastInspectedAt = lastInspectedAt;
    } else if (!lastInspectedAt && current.lastInspectedAt) {
      update.lastInspectedAt = FieldValue.delete();
    }

    if (Object.keys(update).length === 0) return;
    tx.update(machineRef, update);
    logger.info('Synced machine', { machineId, from: current.status, to: status });
  });
}
