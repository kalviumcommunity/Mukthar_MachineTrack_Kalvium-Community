// Unit tests for the pure status rules. Run with `npm test` in functions/.
const assert = require('node:assert/strict');
const { describe, test } = require('node:test');
const { deriveMachineStatus } = require('../lib/machineStatus.js');

const derive = (currentStatus, openBreakdownSeverities = [], latestInspectionCondition) =>
  deriveMachineStatus({ currentStatus, openBreakdownSeverities, latestInspectionCondition });

describe('deriveMachineStatus', () => {
  test('critical breakdown takes the machine down', () => {
    assert.equal(derive('Running', ['Critical']), 'Breakdown');
  });

  test('needs-repair breakdown puts it into maintenance', () => {
    assert.equal(derive('Running', ['Needs Repair']), 'Maintenance');
  });

  test('warnings do not change status', () => {
    assert.equal(derive('Running', ['Warning']), 'Running');
    assert.equal(derive('Idle', ['Warning']), 'Idle');
  });

  test('worst problem wins', () => {
    assert.equal(derive('Running', ['Warning', 'Needs Repair', 'Critical']), 'Breakdown');
    assert.equal(derive('Running', ['Needs Repair'], 'Critical'), 'Breakdown');
  });

  test('latest inspection condition counts as a problem', () => {
    assert.equal(derive('Running', [], 'Critical'), 'Breakdown');
    assert.equal(derive('Idle', [], 'Needs Repair'), 'Maintenance');
  });

  test('open breakdown outranks a passed inspection', () => {
    assert.equal(derive('Breakdown', ['Critical'], 'Passed'), 'Breakdown');
  });

  test('machine recovers to Running once nothing is wrong', () => {
    assert.equal(derive('Breakdown', [], 'Passed'), 'Running');
    assert.equal(derive('Maintenance', []), 'Running');
  });

  test('Running and Idle are left alone when nothing is wrong', () => {
    assert.equal(derive('Running', [], 'Passed'), 'Running');
    assert.equal(derive('Idle', [], 'Passed'), 'Idle');
  });

  test('unknown current status falls back to Idle', () => {
    assert.equal(derive('???', []), 'Idle');
  });
});
