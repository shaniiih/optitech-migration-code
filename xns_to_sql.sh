#!/bin/bash

# XNS (Access) -> SQL export using mdbtools (Ubuntu/Linux/Mac)
# This script generates:
#  - schema.sql (DB schema)
#  - data/<table>.sql (INSERT statements per table)
#  - data.sql (combined INSERT statements)
#  - full.sql (schema + data)
#
# Requirements:
#  - mdbtools (Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y mdbtools)
#  - bash, coreutils
#
# Usage:
#   ./xns_to_sql.sh <path-to-db.xns> [mysql|postgres] [output_dir]
# Examples:
#   ./xns_to_sql.sh ../optData-ash.xns                 # default: mysql dialect
#   ./xns_to_sql.sh ../optData-sde.xns postgres ./out  # postgres dialect to ./out

set -euo pipefail

if ! command -v mdb-tables >/dev/null 2>&1; then
  echo "Error: mdbtools is not installed. Install it first:" >&2
  echo "  Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y mdbtools" >&2
  echo "  macOS (brew):  brew install mdbtools" >&2
  exit 1
fi

PYTHON_BIN="python3"
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  if command -v python >/dev/null 2>&1; then
    PYTHON_BIN="python"
  else
    echo "Error: python3 (or python) is required for post-processing." >&2
    exit 1
  fi
fi

if ! "$PYTHON_BIN" -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)'; then
  echo "Error: Python 3.x is required for post-processing (found $($PYTHON_BIN --version 2>/dev/null || echo unknown))." >&2
  exit 1
fi

patch_glass_ids() {
  local target="$1"
  [ -f "$target" ] || return 0
  "$PYTHON_BIN" - "$target" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    text = fh.read()

orig = text

# We only want to touch the GlassId / GlassPId definitions
# inside tblCrdGlassChecksGlasses / tblCrdGlassChecksGlassesP.
def patch_table(text, table_name, col_name):
    # Regex to match the whole CREATE TABLE block.
    # Non-greedy to stop at the first closing parenthesis+semicolon.
    tbl_re = re.compile(
        rf"(CREATE TABLE\s+`{re.escape(table_name)}`\s*\(\s*)(.*?)(\)\s*;)",
        re.IGNORECASE | re.DOTALL,
    )

    def repl(match):
        prefix, body, suffix = match.groups()
        col_re = re.compile(
            rf"(`{col_name}`\s+int)\s+not\s+null\s+auto_increment\s+unique",
            re.IGNORECASE,
        )
        new_body, n = col_re.subn(r"\1 not null", body)
        if n:
            sys.stderr.write(
                f"    ~ normalized {col_name} definition in table {table_name} ({path})\n"
            )
        return prefix + new_body + suffix

    return tbl_re.sub(repl, text)

# Apply to the two specific tables only
text = patch_table(text, "tblCrdGlassChecksGlasses", "GlassId")
text = patch_table(text, "tblCrdGlassChecksGlassesP", "GlassPId")

if text != orig:
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(text)
PY
}

normalize_dates_sql() {
  local target="$1"
  [ -f "$target" ] || return 0
  "$PYTHON_BIN" - "$target" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    text = fh.read()

pattern = re.compile(
    r"(?P<q>['\"#])(\d{1,2})/(\d{1,2})/(\d{2,4})([ T](?:[01]?\d|2[0-3]):[0-5]\d:[0-5]\d(?:\.\d+)?)?(?P=q)"
)

def expand(match):
    quote, month, day, year, time_part = match.groups()
    if len(year) == 2:
        two = int(year)
        full = 1900 + two
        if two <= 29:
            full += 100
    else:
        full = int(year)
    time_part = time_part or ""
    return "{q}{:04d}-{m:02d}-{d:02d}{t}{q}".format(
        full,
        m=int(month),
        d=int(day),
        t=time_part,
        q=quote,
    )

converted = pattern.sub(expand, text)
if converted != text:
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(converted)
    sys.stderr.write("    ~ normalized 2-digit year values in {}\n".format(path))
PY
}

if [ $# -lt 1 ]; then
  echo "Usage: $0 <database_path> [mysql|postgres] [output_dir]" >&2
  exit 1
fi

DB_PATH="$1"
DIALECT="${2:-mysql}"   # mysql | postgres
OUT_DIR="${3:-./xns_sql_export_$(date +%Y%m%d_%H%M%S)}"

# Resolve common path mistakes if the provided path doesn't exist
if [ ! -f "$DB_PATH" ]; then
  ORIG_DB_PATH="$DB_PATH"
  BASENAME="$(basename -- "$DB_PATH")"
  CWD_ALT="$(pwd)/$BASENAME"
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

  # Try current working directory
  if [ -f "$CWD_ALT" ]; then
    DB_PATH="$CWD_ALT"
  # Try repository root (parent of migration-tools)
  elif [ -f "$REPO_ROOT/$BASENAME" ]; then
    DB_PATH="$REPO_ROOT/$BASENAME"
  # Try migration-tools directory
  elif [ -f "$SCRIPT_DIR/$BASENAME" ]; then
    DB_PATH="$SCRIPT_DIR/$BASENAME"
  fi
fi

if [ ! -f "$DB_PATH" ]; then
  echo "Error: database file not found: $ORIG_DB_PATH" >&2
  echo "Hints:" >&2
  echo "  - From REPO ROOT:           ./xns_to_sql.sh ./optData-ash.xns mysql" >&2
  echo "  - From migration-tools/:     ./xns_to_sql.sh ../optData-ash.xns mysql" >&2
  echo "  - Make sure the file exists and the path is correct relative to your current directory." >&2
  # Show nearby *.xns files if any
  XNS_GLOB=$(ls -1 "$REPO_ROOT"/*.xns 2>/dev/null || true)
  if [ -n "$XNS_GLOB" ]; then
    echo "  - Detected .xns files in repo root:" >&2
    echo "$XNS_GLOB" >&2
  fi
  exit 1
fi

# Normalize dialect for mdbtools
case "$DIALECT" in
  mysql|my|maria|mariadb)
    SCHEMA_DIALECT="mysql"
    EXPORT_DIALECT="mysql"
    ;;
  postgres|pgsql|pg)
    SCHEMA_DIALECT="postgres"
    EXPORT_DIALECT="postgres"
    ;;
  *)
    echo "Warning: unknown dialect '$DIALECT', falling back to 'mysql'" >&2
    SCHEMA_DIALECT="mysql"
    EXPORT_DIALECT="mysql"
    ;;
esac

mkdir -p "$OUT_DIR/data"

echo "==> Database: $DB_PATH"
echo "==> Output:   $OUT_DIR"
echo "==> Dialect:  $SCHEMA_DIALECT"

# 1) List tables
TABLE_LIST_FILE="$OUT_DIR/tables.txt"
echo "Listing tables..."
mdb-tables -1 "$DB_PATH" | sed '/^$/d' > "$TABLE_LIST_FILE"
TABLE_COUNT=$(wc -l < "$TABLE_LIST_FILE" | tr -d ' ')
echo "  Found $TABLE_COUNT tables"

# 2) Export schema
SCHEMA_FILE="$OUT_DIR/schema.sql"
echo "Exporting schema to $SCHEMA_FILE ..."
# mdb-schema prints to stdout; pass backend
mdb-schema "$DB_PATH" "$SCHEMA_DIALECT" > "$SCHEMA_FILE"
# Force all YEAR columns to YEAR(4)
sed -i 's/YEAR(2)/YEAR(4)/g' "$SCHEMA_FILE"

# 2.1) Post-process schema: remove UNIQUE indexes that duplicate PRIMARY KEY columns
# This avoids errors like creating a UNIQUE index on the same column(s) as the PK (e.g., WrkId)
# Handles MySQL-style and Postgres-style outputs from mdb-schema
CLEAN_SCHEMA_FILE="$OUT_DIR/schema.cleaned.sql"
awk '
  # Normalize columns to a lowercase, quote/space-free string
  function normcols_str(s){
    gsub(/[`\"\n\r]/, "", s)
    gsub(/[[:space:]]+/, "", s)
    s=tolower(s)
    return s
  }
  BEGIN{
    current_table=""
  }
  {
    line=$0
    lower=tolower(line)

    # Track current table from CREATE TABLE lines (MySQL backticks or Postgres quotes)
    if(line ~ /^CREATE[ ]+TABLE[ ]+[`\"]/){
      tmp=line
      # Remove leading CREATE TABLE and opening quote/backtick
      sub(/^CREATE[ ]+TABLE[ ]+[`\"]/ , "", tmp)
      # Table name ends at next quote/backtick
      tbl=tmp
      sub(/[`\"].*/, "", tbl)
      current_table=tbl
    }

    # Within CREATE TABLE: detect column-level UNIQUE constraints
    if(current_table != "" && line ~ /^[[:space:]]*[`\"]/){
      tcol=line
      sub(/^[[:space:]]*[`\"]/, "", tcol)
      sub(/[`\"].*/, "", tcol)
      if(index(lower, " unique") || match(lower, /[[:space:]]unique([[:space:]]|,|\))/)){
        key=current_table "|" tolower(tcol)
        uniq_col[key]=1
      }
      # do not next; still print line
    }

    # End of CREATE TABLE block (best-effort)
    if(current_table != "" && line ~ /^\);/){
      current_table=""
    }

    # Capture PK from MySQL-style: ALTER TABLE `tbl` ADD PRIMARY KEY (...)
    if(line ~ /^ALTER[ ]+TABLE[ ]+`/ && line ~ /ADD[ ]+PRIMARY[ ]+KEY[ ]*\(/){
      t=line
      sub(/^ALTER[ ]+TABLE[ ]+`/, "", t)
      sub(/`.*/, "", t)
      cols=line
      sub(/.*PRIMARY[ ]+KEY[ ]*\(/, "", cols)
      sub(/\).*/, "", cols)
      pkcols_str[t]=normcols_str(cols)
      pk_seen[t]=1
      print $0
      next
    }

    # Capture PK from Postgres-style inline in CREATE TABLE: PRIMARY KEY (...)
    if(current_table != "" && line ~ /PRIMARY[ ]+KEY[ ]*\(/){
      cols=line
      sub(/.*PRIMARY[ ]+KEY[ ]*\(/, "", cols)
      sub(/\).*/, "", cols)
      pkcols_str[current_table]=normcols_str(cols)
      pk_seen[current_table]=1
      # fall through and print line
    }

    # Skip MySQL-style UNIQUE index that duplicates PK or a column-level UNIQUE
    if(line ~ /^ALTER[ ]+TABLE[ ]+`/ && line ~ /ADD[ ]+UNIQUE[ ]+INDEX[ ]+`/){
      t=line
      sub(/^ALTER[ ]+TABLE[ ]+`/, "", t)
      sub(/`.*/, "", t)
      ucols=line
      sub(/.*UNIQUE[ ]+INDEX[ ]+`[^`]*`[ ]*\(/, "", ucols)
      sub(/\).*/, "", ucols)
      norm=normcols_str(ucols)
      # If duplicates PK
      if(pk_seen[t] && norm == pkcols_str[t]){
        next
      }
      # If duplicates a column-level UNIQUE (single-column only)
      if(index(norm, ",") == 0){
        key=t "|" norm
        if(uniq_col[key]){
          next
        }
      }
    }

    # Skip Postgres-style UNIQUE index that duplicates PK or column-level UNIQUE
    if(line ~ /^CREATE[ ]+UNIQUE[ ]+INDEX[ ]+/ && line ~ /[ ]+ON[ ]+\"/){
      t=line
      sub(/^.*[ ]+ON[ ]+\"/, "", t)
      sub(/\".*/, "", t)
      ucols=line
      sub(/^.*\(/, "", ucols)
      sub(/\).*/, "", ucols)
      norm=normcols_str(ucols)
      if(pk_seen[t] && norm == pkcols_str[t]){
        next
      }
      if(index(norm, ",") == 0){
        key=t "|" norm
        if(uniq_col[key]){
          next
        }
      }
    }

    print $0
  }
' "$SCHEMA_FILE" > "$CLEAN_SCHEMA_FILE"

# Replace schema with cleaned version
mv "$CLEAN_SCHEMA_FILE" "$SCHEMA_FILE"

# Normalize specific GlassId / GlassPId definitions that should not be AUTO_INCREMENT UNIQUE
patch_glass_ids "$SCHEMA_FILE"

# 3) Export data as INSERT statements per table
COMBINED_DATA_FILE="$OUT_DIR/data.sql"
: > "$COMBINED_DATA_FILE"

echo "Exporting table data as INSERT statements..."

# Force stable date/time formatting to avoid locale/version differences (e.g. 2-digit years)
MDB_EXPORT_ARGS=("-I" "$EXPORT_DIALECT")
MDB_EXPORT_USAGE=$(mdb-export 2>&1 || true)
if grep -Eq '(^|[[:space:]])-D[[:space:]]' <<<"$MDB_EXPORT_USAGE"; then
  MDB_EXPORT_ARGS+=("-D" "%m/%d/%Y")
fi
if grep -Eq '(^|[[:space:]])-T[[:space:]]' <<<"$MDB_EXPORT_USAGE"; then
  MDB_EXPORT_ARGS+=("-T" "%m/%d/%Y %H:%M:%S")
fi

idx=0
while IFS= read -r TABLE; do
  [ -z "$TABLE" ] && continue
  idx=$((idx+1))
  TABLE_SQL_FILE="$OUT_DIR/data/${TABLE}.sql"
  echo "  [$idx/$TABLE_COUNT] $TABLE"
  # mdb-export with -I backend outputs INSERT statements
  # Some tables/columns may have problematic names; wrap with quotes via --no-quote? Not available; rely on backend quoting.
  if ! mdb-export "${MDB_EXPORT_ARGS[@]}" "$DB_PATH" "$TABLE" > "$TABLE_SQL_FILE"; then
    echo "    ! Failed to export $TABLE, skipping" >&2
    continue
  fi
  # Normalize any two-digit years that older mdbtools may emit (Access defaults to 1930-2029 window)
  normalize_dates_sql "$TABLE_SQL_FILE"
  # Append to combined
  echo -e "\n-- ===== $TABLE =====" >> "$COMBINED_DATA_FILE"
  cat "$TABLE_SQL_FILE" >> "$COMBINED_DATA_FILE"

done < "$TABLE_LIST_FILE"

# Ensure combined file has normalized dates (defensive in case of future changes)
normalize_dates_sql "$COMBINED_DATA_FILE"

# Compose full.sql different for postgres to improve importability
if [ "$SCHEMA_DIALECT" = "postgres" ]; then
  DROPS_FILE="$OUT_DIR/drops.sql"
  HEADER_FILE="$OUT_DIR/header.sql"
  FOOTER_FILE="$OUT_DIR/footer.sql"

  : > "$DROPS_FILE"
  while IFS= read -r T; do
    [ -z "$T" ] && continue
    ESCAPED=${T//\"/\"\"}
    echo "DROP TABLE IF EXISTS \"$ESCAPED\" CASCADE;" >> "$DROPS_FILE"
  done < "$TABLE_LIST_FILE"

  cat > "$HEADER_FILE" <<'PGHDR'
-- Postgres import helper header generated by xns_to_sql.sh
\set ON_ERROR_STOP on
BEGIN;
SET client_min_messages = warning;
SET standard_conforming_strings = on;
SET session_replication_role = replica; -- disable FKs/triggers during bulk load
SET client_encoding = 'UTF8';
PGHDR

  cat > "$FOOTER_FILE" <<'PGFTR'
-- Restore defaults after bulk load
SET session_replication_role = DEFAULT;
COMMIT;
PGFTR

  echo "Composing PostgreSQL-friendly full.sql -> $OUT_DIR/full.sql"
  cat "$HEADER_FILE" "$DROPS_FILE" "$SCHEMA_FILE" "$COMBINED_DATA_FILE" "$FOOTER_FILE" > "$OUT_DIR/full.sql"
  normalize_dates_sql "$OUT_DIR/full.sql"
else
  # MySQL: move FK constraints to the end and create missing supporting indexes on referenced columns
  SCHEMA_NO_FK="$OUT_DIR/schema.no_fk.sql"
  FK_CONSTRAINTS_FILE="$OUT_DIR/fk_constraints.sql"
  FK_SUPPORT_INDEXES_FILE="$OUT_DIR/fk_support_indexes.sql"

  : > "$SCHEMA_NO_FK"
  : > "$FK_CONSTRAINTS_FILE"
  : > "$FK_SUPPORT_INDEXES_FILE"

  # Parse schema to extract FKs and detect existing PK/UNIQUE/INDEX for referenced columns
  awk '
    function norm(s){ gsub(/[`\"\n\r]/, "", s); gsub(/[[:space:]]+/, "", s); return tolower(s) }
    BEGIN{ }
    {
      line=$0
      lower=tolower(line)

      # Track PK columns per table (MySQL-style ALTER TABLE `tbl` ADD PRIMARY KEY (...))
      if(line ~ /^ALTER[ ]+TABLE[ ]+`/ && line ~ /ADD[ ]+PRIMARY[ ]+KEY[ ]*\(/){
        t=line; sub(/^ALTER[ ]+TABLE[ ]+`/, "", t); sub(/`.*/, "", t)
        cols=line; sub(/.*PRIMARY[ ]+KEY[ ]*\(/, "", cols); sub(/\).*/, "", cols)
        n=split(cols, arr, /,/) ;
        for(i=1;i<=n;i++){ c=norm(arr[i]); pk[t "|" c]=1 }
      }

      # Track existing UNIQUE/INDEX single-column definitions
      if(line ~ /^ALTER[ ]+TABLE[ ]+`/ && (line ~ /ADD[ ]+UNIQUE[ ]+INDEX/ || line ~ /ADD[ ]+INDEX/)){
        t=line; sub(/^ALTER[ ]+TABLE[ ]+`/, "", t); sub(/`.*/, "", t)
        cols=line; sub(/^.*\(/, "", cols); sub(/\).*/, "", cols)
        n=split(cols, a2, /,/) ;
        if(n==1){ c=norm(a2[1]); has_index[t "|" c]=1 }
      }

      # Detect FK lines and move them to FK_CONSTRAINTS_FILE; collect referenced columns
      if(line ~ /^ALTER[ ]+TABLE[ ]+`/ && line ~ /ADD[ ]+CONSTRAINT[ ]+`/ && line ~ /FOREIGN[ ]+KEY/ && line ~ /REFERENCES[ ]+`/){
        # Extract referenced table and columns
        rt=line; sub(/^.*REFERENCES[ ]+`/, "", rt); sub(/`.*/, "", rt)
        rcols=line; sub(/^.*REFERENCES[ ]+`[^`]*`\(/, "", rcols); sub(/\).*/, "", rcols)
        n=split(rcols, ra, /,/) ;
        if(n==1){ rc=norm(ra[1]); need[rt "|" rc]=1 }
        print line >> fkfile
        next
      }

      # Otherwise, write back to schema-without-FKs
      print line >> schemafile
    }
    END{
      # Emit supporting indexes for referenced single columns (always add to guarantee existence)
      for(k in need){
        split(k, parts, "|")
        t=parts[1]; c=parts[2]
        idxname = "idx_" t "_" c
        # sanitize index name to avoid problematic chars
        gsub(/[^a-zA-Z0-9_]/, "_", idxname)
        printf("ALTER TABLE `%s` ADD INDEX `%s` (`%s`);\n", t, idxname, c) >> idxfile
      }
    }
  ' schemafile="$SCHEMA_NO_FK" fkfile="$FK_CONSTRAINTS_FILE" idxfile="$FK_SUPPORT_INDEXES_FILE" "$SCHEMA_FILE"

  echo "Composing MySQL-friendly full.sql -> $OUT_DIR/full.sql"
  cat "$SCHEMA_NO_FK" "$COMBINED_DATA_FILE" "$FK_SUPPORT_INDEXES_FILE" "$FK_CONSTRAINTS_FILE" > "$OUT_DIR/full.sql"
  normalize_dates_sql "$OUT_DIR/full.sql"
fi

# 4) Summary
{
  echo "=== XNS -> SQL Export Summary ==="
  echo "Date: $(date)"
  echo "DB:   $DB_PATH"
  echo "Out:  $OUT_DIR"
  echo "Dialect: $SCHEMA_DIALECT"
  echo "Tables: $TABLE_COUNT"
} | tee "$OUT_DIR/summary.txt"

echo "\nDone. Files:"
echo "  - $SCHEMA_FILE"
echo "  - $COMBINED_DATA_FILE"
echo "  - $OUT_DIR/full.sql"
echo "  - $OUT_DIR/data/*.sql (per table)"

echo "\nNext steps:"
echo "  - Create your SQL database (MySQL or PostgreSQL)."
echo "  - Apply schema:   psql -f '$SCHEMA_FILE' ...  OR  mysql < '$SCHEMA_FILE'"
echo "  - Load the data:  psql -f '$COMBINED_DATA_FILE' ...  OR  mysql < '$COMBINED_DATA_FILE'"
