// Pure rules for deriving a machine's status from its records. Kept free of
// Firebase imports so it can be unit-tested without emulators.

export type MachineStatus = 'Running' | 'Maintenance' | 'Breakdown' | 'Idle';
export type InspectionCondition = 'Passed' | 'Needs Repair' | 'Critical';
export type BreakdownSeverity = 'Critical' | 'Needs Repair' | 'Warning';

/** Statuses this module sets on its own. 'Running' and 'Idle' are set by people. */
const PROBLEM_STATUSES: readonly MachineStatus[] = ['Breakdown', 'Maintenance'];

export interface MachineStatusInputs {
  /** The machine's current status. */
  currentStatus: string;
  /** Severities of the machine's unresolved breakdowns. */
  openBreakdownSeverities: string[];
  /** Condition of the machine's most recent inspection, if any. */
  latestInspectionCondition?: string;
}

function problemFor(value: string | undefined): MachineStatus | null {
  switch (value) {
    case 'Critical':
      return 'Breakdown';
    case 'Needs Repair':
      return 'Maintenance';
    default:
      return null; // 'Passed', 'Warning' and unknown values don't take a machine down.
  }
}

/**
 * Returns the status a machine should have, given its open breakdowns and its
 * latest inspection.
 *
 * - Any 'Critical' open breakdown or latest inspection makes it 'Breakdown'.
 * - Otherwise, any 'Needs Repair' makes it 'Maintenance'.
 * - Once nothing is wrong, a machine in 'Breakdown' or 'Maintenance' goes back
 *   to 'Running'. 'Running' and 'Idle' are left as they are.
 */
export function deriveMachineStatus(inputs: MachineStatusInputs): MachineStatus {
  const problems = [
    ...inputs.openBreakdownSeverities.map(problemFor),
    problemFor(inputs.latestInspectionCondition),
  ];

  if (problems.includes('Breakdown')) return 'Breakdown';
  if (problems.includes('Maintenance')) return 'Maintenance';

  const current = inputs.currentStatus as MachineStatus;
  if (PROBLEM_STATUSES.includes(current)) return 'Running';
  return current === 'Running' || current === 'Idle' ? current : 'Idle';
}
