import { Pool } from "pg";

declare global {
  // eslint-disable-next-line no-var
  var _pgPool: Pool | undefined;
}

if (!process.env.DATABASE_URL) {
  throw new Error(
    "DATABASE_URL is not set. Copy .env.example to .env.local and fill in your PostgreSQL connection string."
  );
}

export const pool =
  global._pgPool ??
  new Pool({ connectionString: process.env.DATABASE_URL });

pool.on("connect", (client) => {
  client.query("SET search_path TO academics, public");
});

if (process.env.NODE_ENV !== "production") {
  global._pgPool = pool;
}
