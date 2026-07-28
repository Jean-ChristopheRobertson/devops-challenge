import path from "node:path";
import { defineConfig, env } from "prisma/config";

export default defineConfig({
  schema: path.join("..", "schema.prisma"),
  datasource: {
    url: env("POSTGRES_PRISMA_URL"),
  },
  migrations: {
    path: path.join("..", "migrations"),
  },
});
