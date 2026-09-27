#!/usr/bin/env bash
# Runs the integration tests against `dre` on the PATH (or $DRE): the reports tagged `ok` must
# produce exactly the files in expected/, and each report tagged `error` must fail with the
# message listed in errors.txt.
set -euo pipefail
cd "$(dirname "$0")"
dre="${DRE:-dre}"
export DRE_RUN_DATE=2026-03-18
# An in-memory DuckDB: each report creates the tables it needs.
profiles="$(mktemp -d)"
trap 'rm -rf "$profiles"' EXIT
printf 'sources:\n  memory:\n    target: dev\n    targets:\n      dev: {type: duckdb, path: ":memory:"}\n' > "$profiles/profiles.yml"
rm -rf target
"$dre" run -s tag:ok --profiles-dir "$profiles"
status=0
for f in expected/*.csv; do
  name="$(basename "$f")"
  report="${name%%__*}"
  tab="${name#*__}"
  got="target/run/$report/default/$tab"
  if ! diff -u "$f" "$got"; then
    echo "FAIL: $got differs from $f"
    status=1
  fi
done
while IFS=$'\t' read -r report message; do
  [[ -z "$report" ]] && continue
  if out="$("$dre" run -s "$report" --profiles-dir "$profiles" 2>&1)"; then
    echo "FAIL: $report ran, but should fail with: $message"
    status=1
  elif [[ "$out" != *"$message"* ]]; then
    echo "FAIL: $report failed without: $message"
    echo "$out"
    status=1
  fi
done < errors.txt
[[ $status == 0 ]] && echo "All integration tests passed."
exit $status
