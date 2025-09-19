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
