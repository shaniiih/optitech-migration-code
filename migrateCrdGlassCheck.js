const { createId } = require("@paralleldrive/cuid2");
const { getMySQLConnection, getPostgresConnection } = require("./dbConfig");

function normalizeInt(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") return Number.isFinite(value) ? Math.trunc(value) : null;
  if (typeof value === "bigint") return Number(value);
  if (Buffer.isBuffer(value)) return normalizeInt(value.toString("utf8"));
  const trimmed = String(value).trim();
  if (!trimmed) return null;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function normalizeDecimal(value) {
  if (value === null || value === undefined) return null;
  const num = Number(String(value).trim());
  return Number.isFinite(num) ? num : null;
}

function cleanText(value) {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
}

const WINDOW_SIZE = 5000;
const BATCH_SIZE = 100;

const COLUMNS = [
  "id", "tenantId", "branchId",
  "perId", "legacyPerId",
  "checkDate", "userId", "legacyUserId",
  "reCheckDate",
  "fvr", "fvl",
  "sphR", "sphL",
  "cylR", "cylL",
  "axR", "axL",
  "prisR", "prisL",
  "baseR", "legacyBaseR",
  "baseL", "legacyBaseL",
  "varR", "varL",
  "va",
  "phr", "phl",
  "readR", "readL",
  "addBaseR", "legacyAddBaseR",
  "addBaseL", "legacyAddBaseL",
  "addPrisR", "addPrisL",
  "intR", "intL",
  "bifR", "bifL",
  "mulR", "mulL",
  "highR", "highL",
  "pdDistR", "pdDistL",
  "pdReadR", "pdReadL",
  "dominEye",
  "iopl", "iopr",
  "iopInstId", "legacyIopInstId",
  "iopTime",
  "jr", "jl",
  "comments",
  "pdDistA", "pdReadA",
  "pfvr", "pfvl",
  "psphR", "psphL",
  "pcylR", "pcylL",
  "paxR", "paxL",
  "pprisR", "pprisL",
  "pBaseR", "legacyPBaseR",
  "pBaseL", "legacyPBaseL",
  "pvarR", "pvarL",
  "pva",
  "pphr", "pphl",
  "pReadR", "pReadL",
  "pAddBaseR", "legacyPAddBaseR",
  "pAddBaseL", "legacyPAddBaseL",
  "pAddPrisR", "pAddPrisL",
  "pIntR", "pIntL",
  "pBifR", "pBifL",
  "pMulR", "pMulL",
  "pHighR", "pHighL",
  "ppdDistR", "ppdDistL",
  "ppdReadR", "ppdReadL",
  "ppdDistA", "ppdReadA",
  "pjr", "pjl",
  "csr", "csl",
  "extPrisR", "extPrisL",
  "extBaseR", "legacyExtBaseR",
  "extBaseL", "legacyExtBaseL",
  "addExtPrisR", "addExtPrisL",
  "addExtBaseR", "legacyAddExtBaseR",
  "addExtBaseL", "legacyAddExtBaseL",
  "readDR", "readDL",
  "intDR", "intDL",
  "bifDR", "bifDL",
  "ctd", "ctn",
  "ccd", "ccn",
  "hidCom",
  "amslerR", "amslerL",
  "npcr", "npal", "npar",
  "glassCId",
  "createdAt", "updatedAt",
];

async function migrateCrdGlassCheck(tenantId = "tenant_1", branchId = null) {
  const mysql = await getMySQLConnection();
  const pg = await getPostgresConnection();

  let offset = 0;
  let total = 0;

  try {
    const buildMap = async (table, legacyField) => {
      const map = new Map();
      const { rows } = await pg.query(
        `SELECT id, "${legacyField}" FROM "${table}" WHERE "tenantId"=$1 AND "branchId"=$2`,
        [tenantId, branchId]
      );

      for (const r of rows) {
        const legacy = normalizeInt(r[legacyField]);
        if (legacy !== null) map.set(legacy, r.id);
      }
      return map;
    };

    const perMap = await buildMap("PerData", "perId");
    const userMap = await buildMap("User", "userId");
    const iopInstMap = await buildMap("CrdGlassIOPInst", "iOPInstId");
    const baseMap = await buildMap("OpticalBase", "baseId");

    while (true) {
      const [rows] = await mysql.query(
        `SELECT * FROM tblCrdGlassChecks ORDER BY PerId, CheckDate LIMIT ? OFFSET ?`,
        [WINDOW_SIZE, offset]
      );
      if (!rows.length) break;

      for (let i = 0; i < rows.length; i += BATCH_SIZE) {
        const chunk = rows.slice(i, i + BATCH_SIZE);

        const now = new Date();
        const values = [];
        const params = [];
        let paramIndex = 1;

        for (const row of chunk) {
          const legacyPerId = normalizeInt(row.PerId);
          const legacyUserId = normalizeInt(row.UserId);
          const legacyIopInstId = normalizeInt(row.IOPInstId);

          const perId = perMap.get(legacyPerId) || null;
          const userId = userMap.get(legacyUserId) || null;
          const iopInstId = iopInstMap.get(legacyIopInstId) || null;

          const baseR = baseMap.get(normalizeInt(row.BaseR)) || null;
          const baseL = baseMap.get(normalizeInt(row.BaseL)) || null;
          const addBaseR = baseMap.get(normalizeInt(row.AddBaseR)) || null;
          const addBaseL = baseMap.get(normalizeInt(row.AddBaseL)) || null;
          const pBaseR = baseMap.get(normalizeInt(row.PBaseR)) || null;
          const pBaseL = baseMap.get(normalizeInt(row.PBaseL)) || null;
          const pAddBaseR = baseMap.get(normalizeInt(row.PAddBaseR)) || null;
          const pAddBaseL = baseMap.get(normalizeInt(row.PAddBaseL)) || null;
          const extBaseR = baseMap.get(normalizeInt(row.ExtBaseR)) || null;
          const extBaseL = baseMap.get(normalizeInt(row.ExtBaseL)) || null;
          const addExtBaseR = baseMap.get(normalizeInt(row.AddExtBaseR)) || null;
          const addExtBaseL = baseMap.get(normalizeInt(row.AddExtBaseL)) || null;

          const rowValues = [
            createId(), tenantId, branchId,
            perId, legacyPerId,
            row.CheckDate ? new Date(row.CheckDate) : null,
            userId, legacyUserId,
            row.ReCheckDate ? new Date(row.ReCheckDate) : null,
            cleanText(row.FVR), cleanText(row.FVL),
            cleanText(row.SphR), cleanText(row.SphL),
            normalizeDecimal(row.CylR), normalizeDecimal(row.CylL),
            normalizeInt(row.AxR), normalizeInt(row.AxL),
            normalizeDecimal(row.PrisR), normalizeDecimal(row.PrisL),
            baseR, normalizeInt(row.BaseR),
            baseL, normalizeInt(row.BaseL),
            cleanText(row.VarR), cleanText(row.VarL),
            cleanText(row.VA),
            cleanText(row.PHR), cleanText(row.PHL),
            normalizeDecimal(row.ReadR), normalizeDecimal(row.ReadL),
            addBaseR, normalizeInt(row.AddBaseR),
            addBaseL, normalizeInt(row.AddBaseL),
            normalizeDecimal(row.AddPrisR), normalizeDecimal(row.AddPrisL),
            normalizeDecimal(row.IntR), normalizeDecimal(row.IntL),
            normalizeDecimal(row.BifR), normalizeDecimal(row.BifL),
            normalizeDecimal(row.MulR), normalizeDecimal(row.MulL),
            normalizeDecimal(row.HighR), normalizeDecimal(row.HighL),
            normalizeDecimal(row.PDDistR), normalizeDecimal(row.PDDistL),
            normalizeDecimal(row.PDReadR), normalizeDecimal(row.PDReadL),
            cleanText(row.DominEye),
            normalizeInt(row.IOPL), normalizeInt(row.IOPR),
            iopInstId, legacyIopInstId,
            row.IOPTime ? new Date(row.IOPTime) : null,
            cleanText(row.JR), cleanText(row.JL),
            cleanText(row.Comments),
            normalizeDecimal(row.PDDistA), normalizeDecimal(row.PDReadA),
            cleanText(row.PFVR), cleanText(row.PFVL),
            cleanText(row.PSphR), cleanText(row.PSphL),
            normalizeDecimal(row.PCylR), normalizeDecimal(row.PCylL),
            normalizeInt(row.PAxR), normalizeInt(row.PAxL),
            normalizeDecimal(row.PPrisR), normalizeDecimal(row.PPrisL),
            pBaseR, normalizeInt(row.PBaseR),
            pBaseL, normalizeInt(row.PBaseL),
            cleanText(row.PVarR), cleanText(row.PVarL),
            cleanText(row.PVA),
            cleanText(row.PPHR), cleanText(row.PPHL),
            normalizeDecimal(row.PReadR), normalizeDecimal(row.PReadL),
            pAddBaseR, normalizeInt(row.PAddBaseR),
            pAddBaseL, normalizeInt(row.PAddBaseL),
            normalizeDecimal(row.PAddPrisR), normalizeDecimal(row.PAddPrisL),
            normalizeDecimal(row.PIntR), normalizeDecimal(row.PIntL),
            normalizeDecimal(row.PBifR), normalizeDecimal(row.PBifL),
            normalizeDecimal(row.PMulR), normalizeDecimal(row.PMulL),
            normalizeDecimal(row.PHighR), normalizeDecimal(row.PHighL),
            normalizeDecimal(row.PPDDistR), normalizeDecimal(row.PPDDistL),
            normalizeDecimal(row.PPDReadR), normalizeDecimal(row.PPDReadL),
            normalizeDecimal(row.PPDDistA), normalizeDecimal(row.PPDReadA),
            cleanText(row.PJR), cleanText(row.PJL),
            cleanText(row.CSR), cleanText(row.CSL),
            normalizeDecimal(row.ExtPrisR), normalizeDecimal(row.ExtPrisL),
            extBaseR, normalizeInt(row.ExtBaseR),
            extBaseL, normalizeInt(row.ExtBaseL),
            normalizeDecimal(row.AddExtPrisR), normalizeDecimal(row.AddExtPrisL),
            addExtBaseR, normalizeInt(row.AddExtBaseR),
            addExtBaseL, normalizeInt(row.AddExtBaseL),
            cleanText(row.ReadDR), cleanText(row.ReadDL),
            cleanText(row.IntDR), cleanText(row.IntDL),
            cleanText(row.BifDR), cleanText(row.BifDL),
            cleanText(row.CTD), cleanText(row.CTN),
            cleanText(row.CCD), cleanText(row.CCN),
            cleanText(row.HidCom),
            cleanText(row.AmslerR), cleanText(row.AmslerL),
            cleanText(row.NPCR),
            normalizeDecimal(row.NPAL), normalizeDecimal(row.NPAR),
            normalizeInt(row.GlassCId),
            now, now
          ];

          const placeholders = rowValues.map(() => `$${paramIndex++}`);
          values.push(`(${placeholders.join(',')})`);
          params.push(...rowValues);
        }

        if (!values.length) continue;

        await pg.query("BEGIN");
        try {
          const queryText = `
            INSERT INTO "CrdGlassCheck"
              (${COLUMNS.map(c => `"${c}"`).join(",")})
            VALUES ${values.join(",")}
            ON CONFLICT ("tenantId", "branchId", "legacyPerId", "checkDate")
            DO UPDATE SET
              ${COLUMNS
                .filter(c =>
                  ![
                    "id", "tenantId", "legacyPerId", "checkDate",
                    "createdAt", "updatedAt"
                  ].includes(c)
                )
                .map(c => `"${c}" = EXCLUDED."${c}"`)
                .join(",")},
              "updatedAt" = NOW();
          `;
          await pg.query(queryText, params);
          await pg.query("COMMIT");
          total += values.length;
        } catch (err) {
          await pg.query("ROLLBACK");
          throw err;
        }
      }

      offset += rows.length;
    }
  } finally {
    await mysql.end();
    await pg.end();
  }

  console.log("CrdGlassCheck migration completed:", total);
}

module.exports = migrateCrdGlassCheck;
