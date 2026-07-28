#!/usr/bin/env node

import { spawnSync } from 'node:child_process';
import process from 'node:process';

const imageName = process.env.IMAGE_NAME ?? 'ghcr.io/moonpay/devops-challenge:latest';
const migrationImageName = process.env.MIGRATION_IMAGE_NAME ?? getMigrationImageName(imageName);
const isWindows = process.platform === 'win32';

function getMigrationImageName(image) {
  const lastSlashIndex = image.lastIndexOf('/');
  const tagIndex = image.lastIndexOf(':');

  if (tagIndex > lastSlashIndex) {
    return `${image.slice(0, tagIndex)}-migrate${image.slice(tagIndex)}`;
  }

  return `${image}-migrate`;
}

const stageSets = {
  verify: [
    ['lint', ['pnpm', 'lint']],
    ['test', ['pnpm', 'test']],
    ['audit', ['pnpm', 'audit', '--prod', '--audit-level', 'critical']],
    ['typecheck', ['pnpm', 'typecheck']],
  ],
  build: [['build', ['pnpm', 'build']]],
  image: [
    ['docker build application image', ['docker', 'build', '--target', 'runner', '-t', imageName, '-f', 'Dockerfile', '.']],
    ['docker build migration image', ['docker', 'build', '--target', 'migrator', '-t', migrationImageName, '-f', 'Dockerfile', '.']],
  ],
  deploy: [
    ['minikube image load', ['minikube', 'image', 'load', imageName]],
    ['minikube migration image load', ['minikube', 'image', 'load', migrationImageName]],
    ['delete previous migration job', ['kubectl', 'delete', 'job', 'prisma-migrate', '-n', 'devops-challenge', '--ignore-not-found']],
    ['kubectl apply', ['kubectl', 'apply', '-k', 'k8s/overlays/minikube']],
    ['wait for migration job', ['kubectl', 'wait', '--for=condition=complete', 'job/prisma-migrate', '-n', 'devops-challenge', '--timeout=10m']],
    ['wait for web rollout', ['kubectl', 'rollout', 'status', 'deployment/web', '-n', 'devops-challenge', '--timeout=5m']],
  ],
  smoke: [['smoke test', ['node', 'scripts/smoke.mjs']]],
};

const pipeline = {
  verify: ['verify'],
  build: ['build'],
  image: ['image'],
  deploy: ['deploy'],
  smoke: ['smoke'],
  ci: ['verify', 'build', 'image'],
  cd: ['deploy', 'smoke'],
  all: ['verify', 'build', 'image', 'deploy', 'smoke'],
};

const command = process.argv[2] ?? 'all';

if (!pipeline[command]) {
  console.error(`Unknown pipeline command: ${command}`);
  console.error(`Available commands: ${Object.keys(pipeline).join(', ')}`);
  process.exit(1);
}

for (const stageGroup of pipeline[command]) {
  for (const [stageName, stageCommand] of stageSets[stageGroup]) {
    console.log(`\n==> Stage: ${stageName}`);
    console.log(`    $ ${stageCommand.join(' ')}`);

    const [commandName, ...commandArgs] = stageCommand;
    const commandText = [commandName, ...commandArgs].join(' ');

    const result = spawnSync(commandText, {
      stdio: 'inherit',
      env: process.env,
      shell: isWindows ? 'cmd.exe' : true,
    });

    if (result.error) {
      console.error(`\nStage failed to start: ${stageName}`);
      console.error(result.error.message);
      process.exit(1);
    }

    if (result.status !== 0) {
      const exitCode = result.status ?? 1;
      console.error(`\nStage failed: ${stageName} (exit code ${exitCode})`);
      process.exit(exitCode);
    }
  }
}

console.log(`\nPipeline completed successfully: ${command}`);