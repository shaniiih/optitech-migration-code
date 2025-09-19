const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 1000;

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

function asNumber(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  const str = String(value).trim().replace(/,/g, ".");
  if (!str) return null;
  const num = Number(str);
  return Number.isFinite(num) ? num : null;
}

function normalizeDate(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "string") {
    const trimmed = value.trim();
    if (!trimmed) return null;
    if (/^0{4}-0{2}-0{2}/.test(trimmed)) return null;
    const parsed = new Date(trimmed);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  if (typeof value === "number") {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  return null;
}

function normalizeLegacyId(value) {
  if (value === null || value === undefined) return null;

  if (typeof value === "number" && Number.isFinite(value)) {
    return String(value);
  }

  if (typeof value === "bigint") {
    return value.toString();
  }

  if (Buffer.isBuffer(value)) {
    return normalizeLegacyId(value.toString("utf8"));
  }

  const trimmed = String(value).trim();
  if (!trimmed) return null;

  if (/^[+-]?\d+(?:\.0+)?$/.test(trimmed)) {
    return String(parseInt(trimmed, 10));
  }

  return trimmed.toLowerCase();
}

function legacyIdCandidates(value) {
  const normalized = normalizeLegacyId(value);
  if (!normalized) return [];

  const candidates = new Set([normalized]);
  if (/\D/.test(normalized)) {
    const digitsOnly = normalized.replace(/\D+/g, "");
    if (digitsOnly) {
      const numericCandidate = normalizeLegacyId(digitsOnly);
      if (numericCandidate) {
        candidates.add(numericCandidate);
      }
    }
  }

  return Array.from(candidates);
}

function buildLookup(rows, idField, nameField) {
  const map = new Map();
  for (const row of rows) {
    const id = normalizeLegacyId(row[idField]);
    const name = cleanText(row[nameField]);
    if (id && !map.has(id)) {
      map.set(id, name);
    }
  }
  return map;
}

function summarizeAids({ manufacturer, frame, area, cap, eye, pdr, pdl, notes }) {
  const parts = [];
  if (eye) parts.push(`Eye: ${eye}`);
  if (manufacturer) parts.push(`Manufacturer: ${manufacturer}`);
  if (frame) parts.push(`Frame: ${frame}`);
  if (area) parts.push(`Area: ${area}`);
  if (cap) parts.push(`Cap: ${cap}`);
  if (pdr !== null || pdl !== null) {
    const pd = [pdr !== null ? `PD Right ${pdr}` : null, pdl !== null ? `PD Left ${pdl}` : null]
      .filter(Boolean)
      .join(", ");
    if (pd) parts.push(pd);
  }
  if (notes) parts.push(notes);
  return parts.length ? parts.join(" | ") : null;
}

async function migrateLowVisionCheck(tenantId = "tenant_1") {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let lastId = 0;
  let total = 0;
  let skippedMissingCustomer = 0;
  const missingCustomerSamples = new Set();

  try {
    const { rows: customerRows } = await pg.query(
      `SELECT id, "customerId" FROM "Customer" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const customerMap = new Map();
    for (const c of customerRows) {
      for (const key of legacyIdCandidates(c.customerId)) {
        if (!customerMap.has(key)) {
          customerMap.set(key, c.id);
        }
      }
    }

    const { rows: userRows } = await pg.query(
      `SELECT id, email FROM "User" WHERE "tenantId" = $1`,
      [tenantId]
    );
    const userEmailMap = new Map(
      userRows
        .filter((u) => u.email)
        .map((u) => [u.email.toLowerCase(), u.id])
    );

    const [legacyUsers] = await mysql.query(
      `SELECT UserId, CellPhone, HomePhone, UserTz FROM tblUsers`
    );
    const legacyUserMap = new Map();
    for (const user of legacyUsers) {
      for (const key of legacyIdCandidates(user.UserId)) {
        if (!legacyUserMap.has(key)) {
          legacyUserMap.set(key, user);
        }
      }
    }

    const [manufacturerRows] = await mysql.query(
      `SELECT LVManufId AS id, LVManufName AS name FROM tblCrdLVManuf`
    );
    const manufacturerMap = buildLookup(manufacturerRows, "id", "name");

    const [frameRows] = await mysql.query(
      `SELECT LVFrameId AS id, LVFrameName AS name FROM tblCrdLVFrame`
    );
    const frameMap = buildLookup(frameRows, "id", "name");

    const [areaRows] = await mysql.query(
      `SELECT LVAreaId AS id, LVAreaName AS name FROM tblCrdLVArea`
    );
    const areaMap = buildLookup(areaRows, "id", "name");

    const [capRows] = await mysql.query(
      `SELECT LVCapId AS id, LVCapName AS name FROM tblCrdLVCap`
    );
    const capMap = buildLookup(capRows, "id", "name");

    while (true) {
      const [rows] = await mysql.query(
        `SELECT LVId, PerId, CheckDate, PDR, PDL, ManufId, FrameId, AreaId, CapId,
                VAD, VAN, VADL, VANL, Com, EyeId
           FROM tblCrdLVChecks
          WHERE LVId > ?
          ORDER BY LVId
          LIMIT ${WINDOW_SIZE}`,
        [lastId]
      );

      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);
        const values = [];
        const params = [];
        const now = new Date();

        for (const r of chunk) {
          const customerId = legacyIdCandidates(r.PerId)
            .map((candidate) => customerMap.get(candidate))
            .find((value) => value) || null;
          if (!customerId) {
            skippedMissingCustomer += 1;
            const legacyIds = legacyIdCandidates(r.PerId);
            if (legacyIds.length && missingCustomerSamples.size < 10) {
              missingCustomerSamples.add(legacyIds[0]);
            }
            continue;
          }

          const examDate = normalizeDate(r.CheckDate) || now;

          const visualAcuityParts = [
            cleanText(r.VAD) ? `Distance Right: ${cleanText(r.VAD)}` : null,
            cleanText(r.VADL) ? `Distance Left: ${cleanText(r.VADL)}` : null,
            cleanText(r.VAN) ? `Near Right: ${cleanText(r.VAN)}` : null,
            cleanText(r.VANL) ? `Near Left: ${cleanText(r.VANL)}` : null,
          ].filter(Boolean);
          const visualAcuity = visualAcuityParts.length ? visualAcuityParts.join("; ") : null;

          const eyeLabel = (() => {
            const eyeId = asNumber(r.EyeId);
            if (eyeId === 1) return "Right";
            if (eyeId === 2) return "Left";
            if (eyeId === 3) return "Both";
            return null;
          })();

          const aidsRecommended = summarizeAids({
            manufacturer: manufacturerMap.get(normalizeLegacyId(r.ManufId)) || null,
            frame: frameMap.get(normalizeLegacyId(r.FrameId)) || null,
            area: areaMap.get(normalizeLegacyId(r.AreaId)) || null,
            cap: capMap.get(normalizeLegacyId(r.CapId)) || null,
            pdr: asNumber(r.PDR),
            pdl: asNumber(r.PDL),
            eye: eyeLabel,
            notes: cleanText(r.Com),
          });

          const id = `${tenantId}-lvc-${r.LVId}`;
          const createdAt = examDate;

          const columns = [
            id,
            tenantId,
            customerId,
            null,
            examDate,
            visualAcuity,
            null,
            null,
            aidsRecommended,
            cleanText(r.Com),
            createdAt,
            null,
          ];

          const placeholderOffset = params.length;
          const placeholders = columns
            .map((_, idx) => `$${placeholderOffset + idx + 1}`)
            .join(", ");
          values.push(`(${placeholders})`);
          params.push(...columns);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          await pg.query(
            `
            INSERT INTO "LowVisionCheck" (
              id, "tenantId", "customerId", "examinerId", "examDate", "visualAcuity",
              "contrastSensitivity", "visualField", "aidsRecommended", notes, "createdAt",
              "branchId"
            )
            VALUES ${values.join(",")}
            ON CONFLICT (id)
            DO UPDATE SET
              "customerId" = EXCLUDED."customerId",
              "examinerId" = EXCLUDED."examinerId",
              "examDate" = EXCLUDED."examDate",
              "visualAcuity" = EXCLUDED."visualAcuity",
              "contrastSensitivity" = EXCLUDED."contrastSensitivity",
              "visualField" = EXCLUDED."visualField",
              "aidsRecommended" = EXCLUDED."aidsRecommended",
              notes = EXCLUDED.notes,
              "branchId" = EXCLUDED."branchId"
            `,
            params
          );
          await pg.query("COMMIT");
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }

        total += values.length;
      }

      lastId = rows[rows.length - 1].LVId;
      console.log(`Low vision checks migrated: ${total} (lastId=${lastId})`);
    }

    console.log(`✅ LowVisionCheck migration completed. Total inserted/updated: ${total}`);
    if (skippedMissingCustomer) {
      console.warn(`⚠️ Skipped ${skippedMissingCustomer} low vision checks due to missing customers`);
      if (missingCustomerSamples.size) {
        console.warn(
          `⚠️ Example legacy customer IDs with no match: ${Array.from(missingCustomerSamples).join(", ")}`
        );
      }
    }
  } finally {
    await mysql.end();
    await pg.end();
  }
}

module.exports = migrateLowVisionCheck;
