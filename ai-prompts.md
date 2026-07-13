# AI Prompts Log

Tool: GitHub Copilot Chat (GPT-5.3-Codex)

## Prompt 1

"please follow the setup instructions, cp .env.example .env already complete"

## Prompt 2

"We will begin with a plan based on the requirements in this doc..."

## Prompt 3

"For our kubernetes deployment, we will deploy on minikube, for IaC I want to work with terraform/terragrunt, for CI/CD I would like you to show me options"

## Prompt 4

"Let's use option B. Please implement the skeleton" Option B Being Argo CD

## Prompt 5

Summary: Built a production-style multi-stage Dockerfile for the Next.js app, then optimized it for faster rebuilds with pnpm and Next.js cache mounts, a reduced build context, and a cache-friendly .dockerignore. Also fixed Docker build failures caused by Prisma by copying prisma.config.ts and prisma/schema.prisma into the build stages, setting a build-time POSTGRES_PRISMA_URL placeholder, and switching the builder stage to npm run build to avoid pnpm build-script approval issues.
