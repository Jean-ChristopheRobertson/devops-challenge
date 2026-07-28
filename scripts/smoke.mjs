#!/usr/bin/env node

import process from 'node:process';

const targetUrl = process.env.SMOKE_URL ?? 'http://devops-challenge.127.0.0.1.nip.io';
const expectedContent = ['LatestPrices', 'Recent Currencies'];
const retries = Number(process.env.SMOKE_RETRIES ?? 30);
const delayMs = Number(process.env.SMOKE_DELAY_MS ?? 2000);

function sleep(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

for (let attempt = 1; attempt <= retries; attempt += 1) {
  try {
    console.log(`Smoke check ${attempt}/${retries}: ${targetUrl}`);
    const response = await fetch(targetUrl);
    const body = await response.text();

    if (!response.ok) {
      throw new Error(`Expected HTTP 200 but received ${response.status}`);
    }

    const missingContent = expectedContent.filter((snippet) => !body.includes(snippet));

    if (missingContent.length > 0) {
      throw new Error(`Response is missing expected content: ${missingContent.join(', ')}`);
    }

    console.log('Smoke check passed');
    process.exit(0);
  } catch (error) {
    const isLastAttempt = attempt === retries;

    if (isLastAttempt) {
      console.error(`Smoke check failed for ${targetUrl}`);
      console.error(error instanceof Error ? error.message : String(error));
      process.exit(1);
    }

    console.log(`Retrying in ${delayMs}ms...`);
    await sleep(delayMs);
  }
}