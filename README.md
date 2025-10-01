# Optitech Demo Migration

This project migrates Optitech data from the legacy MySQL schema into the new Postgres schema for a single tenant. The migration scripts expect both databases to be accessible and share configuration through a `.env` file.

## Prerequisites
- Node.js 18+ (the scripts rely on modern async/await syntax)
- MySQL instance containing the legacy Optitech data
- Postgres instance with the new Optitech schema already applied

## 1. Install dependencies
```bash
npm install
```

## 2. Configure `.env`
Update the existing `.env` in the project root with credentials for your environments. All values are required.

```env
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=your_mysql_user
MYSQL_PASSWORD=your_mysql_password
MYSQL_DATABASE=optitech_dev
# Optional helpers for dynamic schemas when using the API:
# MYSQL_DATABASE_PREFIX=optitech_
# MYSQL_DATABASE_TEMPLATE=optitech_{tenantSlug}
# MYSQL_DATABASE_CHARSET=utf8mb4
# MYSQL_DATABASE_COLLATION=utf8mb4_unicode_ci
# MYSQL_IMPORT_CHARSET=utf8mb4
# MYSQL_IMPORT_INIT_COMMAND=SET sql_mode='NO_BACKSLASH_ESCAPES';
# MYSQL_IMPORT_FORCE=true
# MYSQL_IMPORT_SCHEMA_ONLY=false

PG_HOST=127.0.0.1
PG_PORT=5432
PG_USER=your_postgres_user
PG_PASSWORD=your_postgres_password
PG_DATABASE=shani

TENANT_ID=tenant_1  # 👈 replace with your real tenantId
```

Key points:
- Replace the MySQL and Postgres connection details with values that match your setup.
- `TENANT_ID` **must** be set to the tenant you want to migrate. Use the same identifier you have (or plan to use) in the `Tenant` table of the Postgres database. Example: `TENANT_ID=optitech_tenant_001`.
- For the HTTP API you can let the service create per-tenant MySQL schemas automatically by setting either `MYSQL_DATABASE_TEMPLATE` (supports `{tenantId}` and `{tenantSlug}` placeholders) or a simple `MYSQL_DATABASE_PREFIX`. If neither is set, the import falls back to `MYSQL_DATABASE`.

## 3. Ensure the tenant exists
`main.js` will automatically create the tenant if it does not already exist. When you run the script (next step), it checks the `Tenant` table and inserts a record with sensible defaults:
- `id`: value from `TENANT_ID`
- `name`: `Default Tenant`
- `subdomain`: `<tenantId>.example.com`

If you prefer to create the tenant manually before running migrations, execute the following SQL on your Postgres database (adjust the values as needed):

```sql
INSERT INTO public."Tenant" (id, name, subdomain, "createdAt", "updatedAt")
VALUES ('optitech_tenant_001', 'Optitech Tenant', 'optitech-tenant-001.example.com', NOW(), NOW());
```

## 4. Run the migration
Once `.env` is set and the tenant exists (or will be created automatically), run:

```bash
node main.js
```

The script logs progress for each migration step and stops on the first error. Check your database logs if you encounter issues.

## 5. Post-migration checks
- Verify that the new tenant data appears in the Postgres tables.
- Spot-check a few migrated entities (customers, sales, etc.) to confirm counts and key fields.
- Review any warnings printed to the console for follow-up actions.

---
If you make changes to the migration order or add new migration scripts, remember to require and schedule them in `main.js` in the desired position.

## Optional: Run via HTTP API

An Express API is available if you prefer to automate the workflow end-to-end (upload `.xns` → convert → import → run `main.js`).

1. Ensure the following tools are installed on the host:
   - `mdbtools` (for `xns_to_sql.sh`)
   - `mysql` CLI client (used to import the generated SQL)
2. Install Node dependencies (adds `express` and `multer`):
   ```bash
   npm install
   ```
3. Start the server (defaults to `http://localhost:3001`):
   ```bash
   npm run dev
   ```
   Use `npm run stage` if you want to set `NODE_ENV=staging` automatically. Set `API_PORT` in your environment to override the port if needed.
4. Send a `POST /migrate` request with `multipart/form-data` containing `tenant_id` and the `.xns` file:
   ```bash
   curl -X POST http://localhost:3001/migrate \
     -F tenant_id=tenant_1 \
     -F xns_file=@/absolute/path/to/optData.xns
   ```

The endpoint returns JSON with a log of each step, including any stdout/stderr produced by the underlying commands.

The API writes exports to `tmp/xns_sql/<tenantSlug>/<runId>/` and will create a MySQL schema named after the derived tenant slug (for example, `optitech_tenant_001`). The resolved schema name is returned in the JSON payload as `mysqlDatabase`.

If you need to rebuild a schema from scratch for a subsequent run, include `reset_database=true` (form field or query param) or set `MYSQL_DATABASE_RESET=true` in the environment. This will drop the tenant database before recreating it, avoiding "table already exists" import errors.

When importing, the API executes the generated SQL in phases using the MySQL CLI: `schema.no_fk.sql` (if present), `data.sql`, then the FK helper files (`fk_support_indexes.sql`, `fk_constraints.sql`). Each step runs with `--default-character-set=utf8mb4 --force --init-command="SET sql_mode='NO_BACKSLASH_ESCAPES';"` by default. Override these via `MYSQL_IMPORT_CHARSET`, `MYSQL_IMPORT_FORCE`, or `MYSQL_IMPORT_INIT_COMMAND` if your environment requires different flags. Before the first phase the server inspects the schema; unless you explicitly set `reset_database=false`, it will drop and recreate the tenant database whenever existing tables are detected, keeping repeated runs idempotent. Both schema and data are imported by default; if you prefer to load only the schema (and handle data yourself), add `schema_only=true` to the request or set `MYSQL_IMPORT_SCHEMA_ONLY=true`. After the MySQL load finishes, the service automatically runs `node main.js`, which reads your `.env` for Postgres settings and performs the MySQL → Postgres tenant migration using the derived database name and tenant id.

Example using the browser `fetch` API (in a modern framework or vanilla JS):

```js
async function triggerMigration({ tenantId, file }) {
  const form = new FormData();
  form.append("tenant_id", tenantId);
  form.append("xns_file", file);

  const response = await fetch("http://localhost:3001/migrate", {
    method: "POST",
    body: form,
  });

  if (!response.ok) {
    const errorPayload = await response.json().catch(() => ({}));
    throw new Error(errorPayload.error || `Migration failed with status ${response.status}`);
  }

  return response.json();
}
```

Call `triggerMigration` with the selected tenant id and file reference from an `<input type="file">` element.
