# syntax=docker/dockerfile:1.7

FROM node:22-alpine AS base
WORKDIR /app
ENV PNPM_HOME=/pnpm
ENV PATH=$PNPM_HOME:$PATH
RUN corepack enable

ARG POSTGRES_PRISMA_URL=postgres://postgres:postgres@localhost:5432/currencies?schema=public
ENV POSTGRES_PRISMA_URL=$POSTGRES_PRISMA_URL

FROM base AS deps
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml prisma.config.ts ./
COPY prisma/schema.prisma ./prisma/schema.prisma
COPY prisma/migrator/package.json ./prisma/migrator/package.json
RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store pnpm install --frozen-lockfile

FROM base AS migrator-deps
COPY pnpm-lock.yaml pnpm-workspace.yaml ./
COPY prisma/migrator/package.json ./prisma/migrator/package.json
RUN --mount=type=cache,id=pnpm-migrator-store,target=/pnpm/store \
    pnpm install --filter @devops-challenge/prisma-migrator --prod --frozen-lockfile

FROM migrator-deps AS migrator-package
RUN pnpm --filter @devops-challenge/prisma-migrator deploy --legacy --prod /migrator

FROM node:22-alpine AS migrator
WORKDIR /app/prisma/migrator
ENV NODE_ENV=production

RUN addgroup -S -g 1001 nextjs && adduser -S -u 1001 -G nextjs nextjs

COPY --from=migrator-package /migrator ./
COPY prisma/migrator/prisma.config.ts ./prisma.config.ts
COPY prisma/schema.prisma ../schema.prisma
COPY prisma/migrations ../migrations

USER nextjs

CMD ["node_modules/.bin/prisma", "migrate", "deploy"]

FROM base AS builder
COPY package.json ./
COPY prisma.config.ts ./
COPY prisma/schema.prisma ./prisma/schema.prisma
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/prisma/generated ./prisma/generated
COPY app ./app
COPY components ./components
COPY lib ./lib
COPY public ./public
COPY next.config.ts tsconfig.json postcss.config.mjs ./
RUN --mount=type=cache,id=next-cache,target=/app/.next/cache npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

RUN addgroup -S -g 1001 nextjs && adduser -S -u 1001 -G nextjs nextjs

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/prisma/generated ./prisma/generated

USER nextjs
EXPOSE 3000
CMD ["node", "server.js"]
