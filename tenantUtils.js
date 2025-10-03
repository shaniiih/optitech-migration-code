function cleanTenantId(value) {
  if (value === undefined || value === null) {
    return "";
  }
  return String(value).split("#")[0].trim();
}

function ensureTenantId(value, fallback) {
  const primary = cleanTenantId(value);
  if (primary) {
    return primary;
  }

  const secondary = cleanTenantId(fallback);
  if (secondary) {
    return secondary;
  }

  throw new Error("tenantId is required (set TENANT_ID in your environment)");
}

module.exports = { cleanTenantId, ensureTenantId };
