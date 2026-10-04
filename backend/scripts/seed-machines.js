import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { initAdmin } from './firebase-admin.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DEFAULT_DATA_PATH = resolve(__dirname, 'data/sample-machines.json');

const VALID_STATUSES = new Set(['Running', 'Maintenance', 'Breakdown', 'Idle']);

/**
 * Validates a machine object against the Firestore data model.
 */
function validateMachine(machine, index) {
  const prefix = `Machine #${index + 1} (${machine.code || machine.name || 'unnamed'})`;

  if (!machine.name || typeof machine.name !== 'string' || machine.name.trim().length === 0) {
    throw new Error(`${prefix}: missing or invalid 'name'. Must be a non-empty string.`);
  }
  if (!machine.code || typeof machine.code !== 'string' || machine.code.trim().length === 0) {
    throw new Error(`${prefix}: missing or invalid 'code'. Must be a non-empty string.`);
  }
  if (!machine.location || typeof machine.location !== 'string' || machine.location.trim().length === 0) {
    throw new Error(`${prefix}: missing or invalid 'location'. Must be a non-empty string.`);
  }
  if (!machine.status || !VALID_STATUSES.has(machine.status)) {
    throw new Error(
      `${prefix}: invalid 'status' "${machine.status}". Must be one of: ${[...VALID_STATUSES].join(', ')}.`
    );
  }
}

/**
 * Seeds sample machines into Firestore.
 *
 * @param {object} options
 * @param {boolean} [options.prod=false] Connect to live Firebase production.
 * @param {boolean} [options.emulator=false] Connect to local emulator.
 * @param {boolean} [options.clear=false] Clear machines collection before seeding.
 * @param {string} [options.file] Path to a custom JSON file.
 * @param {string} [options.project] Firebase project ID override.
 * @param {Array<object>} [options.machines] In-memory machine list override.
 * @param {object} [options.logger=console] Custom logger.
 */
export async function seedMachines(options = {}) {
  const logger = options.logger || console;
  const { db, isEmulator, projectId } = initAdmin(options);

  // Load machines data
  let rawMachines = options.machines;
  if (!rawMachines) {
    const filePath = options.file ? resolve(process.cwd(), options.file) : DEFAULT_DATA_PATH;
    const content = readFileSync(filePath, 'utf8');
    rawMachines = JSON.parse(content);
  }

  if (!Array.isArray(rawMachines) || rawMachines.length === 0) {
    throw new Error('No machines found to seed.');
  }

  // Validate each machine
  rawMachines.forEach(validateMachine);

  try {
    // Optionally wipe existing machines first
    if (options.clear) {
      logger.log(`Clearing existing machines from [${projectId}]...`);
      const existingSnap = await db.collection('machines').get();
      if (!existingSnap.empty) {
        const deleteBatch = db.batch();
        existingSnap.docs.forEach((d) => deleteBatch.delete(d.ref));
        await deleteBatch.commit();
        logger.log(`Deleted ${existingSnap.size} existing machine(s).`);
      }
    }

    // Write machines in batches (Firestore limit: 500 writes/batch)
    const BATCH_SIZE = 500;
    const seeded = [];

    for (let i = 0; i < rawMachines.length; i += BATCH_SIZE) {
      const chunk = rawMachines.slice(i, i + BATCH_SIZE);
      const batch = db.batch();

      for (const item of chunk) {
        const id = String(item.id || item.code);
        // Exclude 'id' from doc data so it adheres to validMachine schema in firestore.rules
        const { id: _ignoredId, ...docData } = item;
        const docRef = db.collection('machines').doc(id);
        batch.set(docRef, docData);
        seeded.push({ id, ...docData });
      }

      await batch.commit();
    }

    return {
      count: seeded.length,
      machines: seeded,
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
        `Could not connect to Firestore emulator at ${host}.\n` +
          `Make sure the emulator is running: npm run emulators (or pass --prod for production).`
      );
    }
    throw error;
  }
}

// CLI Execution
if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  const { values } = parseArgs({
    options: {
      prod: { type: 'boolean', default: false },
      emulator: { type: 'boolean', default: false },
      clear: { type: 'boolean', default: false },
      file: { type: 'string' },
      project: { type: 'string' },
      help: { type: 'boolean', short: 'h', default: false },
    },
    allowPositionals: false,
  });

  if (values.help) {
    console.log(`
MachineTrack - Seed Sample Machines
Usage: node scripts/seed-machines.js [options]

Options:
  --prod           Target live Firebase production project (default: demo emulator)
  --emulator       Target local Firebase emulator
  --clear          Delete existing machines before inserting sample fleet
  --file <path>    Path to a custom JSON dataset of machines
  --project <id>   Override Firebase project ID
  -h, --help       Show this help message
`);
    process.exit(0);
  }

  (async () => {
    try {
      const targetLabel = values.prod ? 'Production' : 'Local Emulator';
      console.log(`\n🚀 Seeding machines to ${targetLabel}...`);

      const result = await seedMachines(values);

      console.log(`\nTarget Project: ${result.projectId} (${result.isEmulator ? 'Emulator' : 'Production'})`);
      console.log(`Seeded ${result.count} machine(s):`);
      for (const m of result.machines) {
        console.log(`  ✔ [${m.id}] ${m.name} (${m.code}) - ${m.status} | Location: ${m.location}`);
      }
      console.log(`\n✨ Seeding completed successfully!\n`);
      process.exit(0);
    } catch (err) {
      console.error(`\n❌ Seeding failed: ${err.message}\n`);
      process.exit(1);
    }
  })();
}
