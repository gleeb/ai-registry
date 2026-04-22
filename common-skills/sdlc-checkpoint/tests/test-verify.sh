#!/usr/bin/env bash
# =============================================================================
# test-verify.sh — Smoke test for verify.sh staging-doc drift detection (P12)
#
# Runs verify.sh against each fixture and asserts the staging-doc drift line
# matches the expected pattern.
#
# Usage:
#   bash tests/test-verify.sh
#
# Exit 0 if all cases pass, 1 otherwise.
# =============================================================================

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERIFY_SH="$SCRIPT_DIR/../scripts/verify.sh"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

if [ ! -x "$VERIFY_SH" ]; then
  echo "FATAL: verify.sh not found or not executable at $VERIFY_SH" >&2
  exit 2
fi

pass=0
fail=0
failures=()

# run_case <name> <cp_tasks_completed_path> <staging_path> <mode> <pattern>
#   mode:
#     must-match      -> expect output to contain <pattern>
#     must-not-match  -> expect output to NOT contain <pattern>
run_case() {
  local name="$1" fixture_dir="$2" mode="$3" pattern="$4"

  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  mkdir -p "$tmp/.sdlc"
  # Copy staging doc first so we can reference its absolute path
  cp "$fixture_dir/staging.md" "$tmp/staging.md"
  # Substitute the FIXTURE_STAGING_DOC placeholder in execution.yaml
  sed "s|FIXTURE_STAGING_DOC|$tmp/staging.md|g" \
      "$fixture_dir/execution.yaml" > "$tmp/.sdlc/execution.yaml"

  local output
  output="$(cd "$tmp" && "$VERIFY_SH" execution 2>&1)"

  local matched=0
  if echo "$output" | grep -qE "$pattern"; then
    matched=1
  fi

  local ok=0
  case "$mode" in
    must-match)     [ "$matched" = 1 ] && ok=1 ;;
    must-not-match) [ "$matched" = 0 ] && ok=1 ;;
    *) echo "FATAL: unknown mode $mode" >&2; rm -rf "$tmp"; return 2 ;;
  esac

  if [ "$ok" = 1 ]; then
    echo "PASS: $name"
    pass=$((pass + 1))
  else
    echo "FAIL: $name"
    echo "  mode:     $mode"
    echo "  pattern:  $pattern"
    echo "  ----- verify.sh output -----"
    echo "$output" | sed 's/^/  /'
    echo "  ----- end output -----"
    fail=$((fail + 1))
    failures+=("$name")
  fi

  rm -rf "$tmp"
  trap - RETURN
}

# -----------------------------------------------------------------------------
# Cases
# -----------------------------------------------------------------------------

# 1. Agreement: counts match -> no drift warning
run_case "agreement (no drift line)" \
  "$FIXTURES_DIR/agreement" \
  must-not-match \
  '^verification: (staging ahead|checkpoint ahead|staging doc shows)'

# 2. Staging ahead: staging doc shows more done than checkpoint
run_case "staging ahead (2/3 vs 0)" \
  "$FIXTURES_DIR/staging-ahead" \
  must-match \
  'verification: staging ahead of checkpoint \(staging: 2/3, checkpoint: 0\) -- trusting staging doc'

# 3. Checkpoint ahead: checkpoint claims more done than staging
run_case "checkpoint ahead (3 vs 1/3)" \
  "$FIXTURES_DIR/checkpoint-ahead" \
  must-match \
  'verification: checkpoint ahead of staging \(checkpoint: 3, staging: 1/3\) -- counts differ; inspect staging doc manually'

# 4. Legacy checkbox convention: counts match -> no drift warning
run_case "legacy checkbox (no drift line)" \
  "$FIXTURES_DIR/legacy-checkbox" \
  must-not-match \
  '^verification: (staging ahead|checkpoint ahead|staging doc shows)'

# 5. Assert the old hardcoded 'staging doc is more current' phrasing is gone
#    in all scenarios (this catches any regression where the old warning
#    template sneaks back in).
run_case "no stale 'more current' phrasing (agreement)" \
  "$FIXTURES_DIR/agreement" \
  must-not-match \
  'staging doc is more current'
run_case "no stale 'more current' phrasing (staging-ahead)" \
  "$FIXTURES_DIR/staging-ahead" \
  must-not-match \
  'staging doc is more current'
run_case "no stale 'more current' phrasing (checkpoint-ahead)" \
  "$FIXTURES_DIR/checkpoint-ahead" \
  must-not-match \
  'staging doc is more current'

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

echo ""
echo "===================="
echo "Results: $pass passed, $fail failed"
echo "===================="

if [ "$fail" -gt 0 ]; then
  echo "Failed cases:"
  for f in "${failures[@]}"; do
    echo "  - $f"
  done
  exit 1
fi
exit 0
