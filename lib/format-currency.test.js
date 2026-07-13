import assert from 'node:assert/strict';
import test from 'node:test';

import { formatEuroPrice } from './format-currency.js';

test('formats whole and fractional values as euro prices', () => {
  assert.equal(formatEuroPrice(12), '€12.00');
  assert.equal(formatEuroPrice(12.3), '€12.30');
});

test('rounds values to two decimals', () => {
  assert.equal(formatEuroPrice(1.239), '€1.24');
});