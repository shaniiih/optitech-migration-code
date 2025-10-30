// api.js - Minimal service: extract XNS, create MySQL database, import schema.no_fk.sql
require("dotenv").config();

const express = require("express");
const cors = require("cors");
const multer = require("multer");
const path = require("path");
const os = require("os");
const fs = require("fs");
const { spawn } = require("child_process");
const { v4: uuidv4 } = require("uuid");

const projectRoot = __dirname;
const tmpRoot = path.join(projectRoot, "tmp");
const uploadRoot = path.join(os.tmpdir(), "optitech-xns-uploads");

fs.mkdirSync(tmpRoot, { recursive: true });
fs.mkdirSync(uploadRoot, { recursive: true });

const upload = multer({ dest: uploadRoot });
const app = express();
const PORT = Number(process.env.API_PORT || 3001);

const allowedOrigins = (process.env.CORS_ALLOWED_ORIGINS || "http://localhost:3000,http://178.128.45.173:4041")
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error("Not allowed by CORS"));
      }
    },
    credentials: true,
  })
);

app.get("/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

app.post("/import-schema", upload.single("xns_file"), async (req, res) => {
  const tenantId = sanitizeTenantId(req.body.tenant_id || req.body.tenantId);
  const branchId = sanitizeTenantId(req.body.branch_id || req.body.branchId);
  const databaseName = sanitizeDatabaseName(req.body.database || req.body.databaseName || tenantId);
  const uploadedFile = req.file;

  if (!tenantId) {
    cleanupTemp(uploadedFile);
    return res.status(400).json({ error: "tenant_id is required" });
  }

  if (!databaseName) {
    cleanupTemp(uploadedFile);
    return res.status(400).json({ error: "database name could not be derived" });
  }

  if (!uploadedFile) {
    return res.status(400).json({ error: "xns_file upload is required" });
  }

  const logs = [];

  function logStep(label, value) {
    const message = `[${new Date().toISOString()}] ${label}: ${value}`;
    console.log(message);
    logs.push({ label, value });
  }

  try {
    logStep("upload", `Received ${uploadedFile.originalname} (${uploadedFile.size} bytes)`);

    const exportResult = await convertXnsToSql(uploadedFile.path, tenantId);
    logStep("extract", `SQL artifacts ready at ${exportResult.outputDir}`);

    await createDatabase(databaseName);
    logStep("database", `Database ${databaseName} ensured via mysql CLI`);

    const importResult = await importSchema(exportResult.schemaNoFkPath, databaseName);
    if (importResult.stdout.trim()) {
      logStep("import-stdout", importResult.stdout.trim());
    }
    if (importResult.stderr.trim()) {
      logStep("import-stderr", importResult.stderr.trim());
    }

    if (exportResult.dataSqlPath) {
      const dataImportResult = await importData(exportResult.dataSqlPath, databaseName);
      if (dataImportResult.stdout.trim()) {
        logStep("data-stdout", dataImportResult.stdout.trim());
      }
      if (dataImportResult.stderr.trim()) {
        logStep("data-stderr", dataImportResult.stderr.trim());
      }
    }

    const migrationResult = await runMigration(tenantId, branchId, databaseName);
    if (migrationResult.stdout.trim()) {
      logStep("migrate-stdout", migrationResult.stdout.trim());
    }
    if (migrationResult.stderr.trim()) {
      logStep("migrate-stderr", migrationResult.stderr.trim());
    }

    res.json({
      tenantId,
      branchId,
      database: databaseName,
      schemaPath: exportResult.schemaNoFkPath,
      dataPath: exportResult.dataSqlPath,
      migrationScript: "main.js",
      migrationRan: true,
      logs,
    });
  } catch (error) {
    console.error("/import-schema failed", error);
    res.status(500).json({
      error: error.message,
      stdout: error.stdout || "",
      stderr: error.stderr || "",
      logs,
    });
  } finally {
    cleanupTemp(uploadedFile);
  }
});

function sanitizeTenantId(value) {
  if (!value) {
    return "";
  }
  return String(value).trim();
}

function sanitizeDatabaseName(value) {
  if (!value) {
    return "";
  }
  return String(value)
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^0-9a-zA-Z_]/g, "_")
    .replace(/_+/g, "_")
    .replace(/^_+/, "")
    .replace(/_+$/, "")
    .toLowerCase()
    .slice(0, 63);
}

async function convertXnsToSql(xnsPath, tenantId) {
  const runId = uuidv4();
  const exportDir = path.join(tmpRoot, "xns_sql", sanitizeDatabaseName(tenantId) || "tenant", runId);
  await fs.promises.mkdir(exportDir, { recursive: true });

  console.log(`[${new Date().toISOString()}] convertXnsToSql: starting export for ${xnsPath} -> ${exportDir}`);
  await runCommand("bash", [path.join(projectRoot, "xns_to_sql.sh"), xnsPath, "mysql", exportDir]);

  const schemaNoFkPath = path.join(exportDir, "schema.no_fk.sql");
  if (!(await fileExists(schemaNoFkPath))) {
    throw new Error(`Expected schema file not found: ${schemaNoFkPath}`);
  }

  const dataSqlPath = path.join(exportDir, "data.sql");
  if (!(await fileExists(dataSqlPath))) {
    throw new Error(`Expected data file not found: ${dataSqlPath}`);
  }

  console.log(`[${new Date().toISOString()}] convertXnsToSql: export complete (schema: ${schemaNoFkPath}, data: ${dataSqlPath})`);

  return { outputDir: exportDir, schemaNoFkPath, dataSqlPath };
}

async function createDatabase(databaseName) {
  console.log(`[${new Date().toISOString()}] createDatabase: ensuring ${databaseName}`);
  const args = buildMysqlArgs({
    extra: [`--execute=CREATE DATABASE IF NOT EXISTS \`${databaseName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`],
  });
  return runCommand("mysql", args);
}

async function importSchema(schemaPath, databaseName) {
  console.log(`[${new Date().toISOString()}] importSchema: loading ${schemaPath} into ${databaseName}`);
  const args = buildMysqlImportArgs({
    database: databaseName,
    charset: process.env.MYSQL_IMPORT_CHARSET || "utf8mb4",
    initCommand:
      process.env.MYSQL_IMPORT_INIT_COMMAND ||
      "SET SESSION sql_mode='NO_ENGINE_SUBSTITUTION,NO_BACKSLASH_ESCAPES,ALLOW_INVALID_DATES';",
    force: true,
  });
  return runCommand("mysql", args, { stdinFilePath: schemaPath });
}

async function importData(dataPath, databaseName) {
  console.log(`[${new Date().toISOString()}] importData: loading ${dataPath} into ${databaseName}`);
  const args = buildMysqlImportArgs({
    database: databaseName,
    charset: process.env.MYSQL_IMPORT_CHARSET || "utf8mb4",
    initCommand:
      process.env.MYSQL_IMPORT_INIT_COMMAND ||
      "SET SESSION sql_mode='NO_ENGINE_SUBSTITUTION,NO_BACKSLASH_ESCAPES,ALLOW_INVALID_DATES';",
    force: true,
  });
  return runCommand("mysql", args, { stdinFilePath: dataPath });
}

async function runMigration(tenantId, branchId, databaseName) {
  console.log(`[${new Date().toISOString()}] runMigration: executing main.js for tenant ${tenantId} and branch ${branchId} using MySQL database ${databaseName}`);
  const migrationEnv = {
    TENANT_ID: tenantId,
    BRANCH_ID: branchId,
    MYSQL_DATABASE: databaseName,
  };
  return runCommand("node", [path.join(projectRoot, "main.js")], { env: migrationEnv });
}

function buildMysqlArgs({ database, charset, initCommand, force, extra = [] }) {
  const host = requiredEnv("MYSQL_HOST");
  const port = process.env.MYSQL_PORT || "3306";
  const user = requiredEnv("MYSQL_USER");
  const password = requiredEnv("MYSQL_PASSWORD");

  const args = [
    `--host=${host}`,
    `--port=${port}`,
    `--user=${user}`,
    `--password=${password}`,
  ];

  if (charset) {
    args.push(`--default-character-set=${charset}`);
  }

  if (force) {
    args.push("--force");
  }

  if (initCommand) {
    args.push(`--init-command=${initCommand}`);
  }

  args.push(...extra);

  if (database) {
    args.push(database);
  }

  return args;
}

function buildMysqlImportArgs({ database, charset, initCommand, force, extra = [] }) {
  const host = requiredEnv("MYSQL_HOST");
  const port = process.env.MYSQL_PORT || "3306";
  const user = requiredEnv("MYSQL_USER");
  const password = requiredEnv("MYSQL_PASSWORD");

  const args = [];

  if (charset) {
    args.push(`--default-character-set=${charset}`);
  }

  args.push("-u", user);

  if (password) {
    args.push(`-p${password}`);
  }

  args.push(`--host=${host}`);
  args.push(`--port=${port}`);

  if (force) {
    args.push("--force");
  }

  if (initCommand) {
    args.push(`--init-command=${initCommand}`);
  }

  args.push(...extra);

  if (database) {
    args.push(database);
  }

  return args;
}

function requiredEnv(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`${name} is required`);
  }
  return value;
}

function runCommand(command, args, { stdinFilePath, env } = {}) {
  return new Promise((resolve, reject) => {
    const sanitizedArgs = args.map((arg) => {
      if (typeof arg !== "string") return arg;
      if (arg.startsWith("--password=")) return "--password=***";
      if (arg.startsWith("-p") && arg.length > 2) return "-p***";
      return arg;
    });
    console.log(`[${new Date().toISOString()}] runCommand: ${command} ${sanitizedArgs.join(" ")}${stdinFilePath ? ` < ${stdinFilePath}` : ""}`);

    const childEnv = env ? { ...process.env, ...env } : process.env;
    const child = spawn(command, args, { cwd: projectRoot, env: childEnv });

    let stdout = "";
    let stderr = "";

    child.stdout.on("data", (chunk) => {
      stdout += chunk.toString();
    });

    child.stderr.on("data", (chunk) => {
      stderr += chunk.toString();
    });

    child.on("error", (error) => {
      reject(Object.assign(new Error(`Failed to start ${command}: ${error.message}`), { stdout, stderr }));
    });

    child.on("close", (code) => {
      if (code === 0) {
        resolve({ stdout, stderr });
      } else {
        const err = new Error(`${command} exited with code ${code}`);
        err.stdout = stdout;
        err.stderr = stderr;
        err.code = code;
        reject(err);
      }
    });

    if (stdinFilePath) {
      const stream = fs.createReadStream(stdinFilePath);
      stream.on("error", (error) => {
        child.kill("SIGTERM");
        reject(Object.assign(new Error(`Failed to read ${stdinFilePath}: ${error.message}`), { stdout, stderr }));
      });
      stream.pipe(child.stdin);
    } else {
      child.stdin.end();
    }
  });
}

async function fileExists(p) {
  try {
    await fs.promises.access(p, fs.constants.F_OK);
    return true;
  } catch (error) {
    if (error.code === "ENOENT") {
      return false;
    }
    throw error;
  }
}

function cleanupTemp(uploadedFile) {
  if (!uploadedFile) {
    return;
  }
  fs.promises.unlink(uploadedFile.path).catch(() => {});
}

app.listen(PORT, () => {
  console.log(`Schema import API listening on http://localhost:${PORT}`);
  if (allowedOrigins.length) {
    console.log(`CORS enabled for: ${allowedOrigins.join(", ")}`);
  }
});
