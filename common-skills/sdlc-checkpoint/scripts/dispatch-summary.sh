#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# dispatch-summary.sh — SDLC Dispatch Log Analyzer
#
# Reads .sdlc/dispatch-log.jsonl and produces a human-readable summary of
# dispatch activity: counts by agent/profile, duration stats, iteration counts,
# pass/fail ratios, and a chronological timeline.
#
# Usage:
#   dispatch-summary.sh                  # Full summary
#   dispatch-summary.sh --story US-001   # Filter to one story
#   dispatch-summary.sh --timeline       # Timeline only
# =============================================================================

SDLC_DIR=".sdlc"
DISPATCH_LOG="$SDLC_DIR/dispatch-log.jsonl"

story_filter=""
timeline_only=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --story)    story_filter="$2"; shift 2 ;;
    --timeline) timeline_only=true; shift ;;
    *)          echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
done

if [ ! -f "$DISPATCH_LOG" ]; then
  echo "No dispatch log found at $DISPATCH_LOG"
  echo "Run checkpoint.sh dispatch-log to start logging dispatches."
  exit 0
fi

log_content="$(cat "$DISPATCH_LOG")"
if [ -n "$story_filter" ]; then
  log_content="$(echo "$log_content" | grep "\"story\":\"${story_filter}\"" || true)"
  if [ -z "$log_content" ]; then
    echo "No dispatches found for story: $story_filter"
    exit 0
  fi
fi

dispatches="$(echo "$log_content" | grep '"event":"dispatch"' || true)"
responses="$(echo "$log_content" | grep '"event":"response"' || true)"

dispatch_count=0
[ -n "$dispatches" ] && dispatch_count="$(echo "$dispatches" | wc -l | tr -d ' ')"
response_count=0
[ -n "$responses" ] && response_count="$(echo "$responses" | wc -l | tr -d ' ')"

# --- Timeline ---

print_timeline() {
  echo "=== Dispatch Timeline ==="
  echo ""
  if [ -z "$dispatches" ] && [ -z "$responses" ]; then
    echo "  (no entries)"
    return
  fi
  echo "$log_content" | while IFS= read -r line; do
    local evt="" ts="" agent="" did="" verdict="" dur=""
    evt="$(echo "$line" | sed -n 's/.*"event":"\([^"]*\)".*/\1/p')"
    ts="$(echo "$line" | sed -n 's/.*"timestamp":"\([^"]*\)".*/\1/p')"
    agent="$(echo "$line" | sed -n 's/.*"agent":"\([^"]*\)".*/\1/p')"
    did="$(echo "$line" | sed -n 's/.*"dispatch_id":"\([^"]*\)".*/\1/p')"

    if [ "$evt" = "dispatch" ]; then
      local phase="" task=""
      phase="$(echo "$line" | sed -n 's/.*"phase":"\([^"]*\)".*/\1/p')"
      task="$(echo "$line" | sed -n 's/.*"task":"\([^"]*\)".*/\1/p')"
      printf "  %s  DISPATCH  %-28s  phase:%s  task:%s\n" "$ts" "$agent" "${phase:--}" "${task:--}"
    elif [ "$evt" = "response" ]; then
      verdict="$(echo "$line" | sed -n 's/.*"verdict":"\([^"]*\)".*/\1/p')"
      dur="$(echo "$line" | sed -n 's/.*"duration_seconds":\([0-9]*\).*/\1/p')"
      printf "  %s  RESPONSE  %-28s  verdict:%s  duration:%ss\n" "$ts" "$agent" "${verdict:--}" "${dur:--}"
    fi
  done
  echo ""
}

if [ "$timeline_only" = true ]; then
  print_timeline
  exit 0
fi

# --- Summary ---

echo "=== SDLC Dispatch Summary ==="
[ -n "$story_filter" ] && echo "  Story filter: $story_filter"
echo ""
echo "Total dispatches: $dispatch_count"
echo "Total responses:  $response_count"
echo ""

# --- By Agent ---

echo "--- Dispatches by Agent ---"
if [ -n "$dispatches" ]; then
  echo "$dispatches" \
    | sed -n 's/.*"agent":"\([^"]*\)".*/\1/p' \
    | sort | uniq -c | sort -rn \
    | while read -r count name; do
        printf "  %-32s %s\n" "$name" "$count"
      done
else
  echo "  (none)"
fi
echo ""

# --- By Model Profile ---

echo "--- Dispatches by Model Profile ---"
if [ -n "$dispatches" ]; then
  echo "$dispatches" \
    | sed -n 's/.*"model_profile":"\([^"]*\)".*/\1/p' \
    | sort | uniq -c | sort -rn \
    | while read -r count name; do
        printf "  %-32s %s\n" "$name" "$count"
      done
  local no_profile
  no_profile="$(echo "$dispatches" | grep -cv '"model_profile"' || true)"
  [ "$no_profile" -gt 0 ] && printf "  %-32s %s\n" "(not specified)" "$no_profile"
else
  echo "  (none)"
fi
echo ""

# --- Verdicts ---

echo "--- Response Verdicts ---"
if [ -n "$responses" ]; then
  echo "$responses" \
    | sed -n 's/.*"verdict":"\([^"]*\)".*/\1/p' \
    | sort | uniq -c | sort -rn \
    | while read -r count name; do
        printf "  %-32s %s\n" "$name" "$count"
      done
  local no_verdict
  no_verdict="$(echo "$responses" | grep -cv '"verdict"' || true)"
  [ "$no_verdict" -gt 0 ] && printf "  %-32s %s\n" "(no verdict)" "$no_verdict"
else
  echo "  (none)"
fi
echo ""

# --- Duration Stats ---

echo "--- Duration (seconds) ---"
if [ -n "$responses" ]; then
  local durations
  durations="$(echo "$responses" | sed -n 's/.*"duration_seconds":\([0-9]*\).*/\1/p')"
  if [ -n "$durations" ]; then
    local count_dur total min max
    count_dur="$(echo "$durations" | wc -l | tr -d ' ')"
    total="$(echo "$durations" | paste -sd+ - | bc 2>/dev/null || echo 0)"
    min="$(echo "$durations" | sort -n | head -1)"
    max="$(echo "$durations" | sort -n | tail -1)"
    local avg=0
    [ "$count_dur" -gt 0 ] && avg=$(( total / count_dur ))
    echo "  Responses with duration: $count_dur"
    echo "  Total:   ${total}s"
    echo "  Average: ${avg}s"
    echo "  Min:     ${min}s"
    echo "  Max:     ${max}s"
  else
    echo "  (no duration data)"
  fi
else
  echo "  (no responses)"
fi
echo ""

# --- Iteration Counts ---

echo "--- Review Iterations (dispatches with iteration > 1) ---"
if [ -n "$dispatches" ]; then
  local retries
  retries="$(echo "$dispatches" | grep '"iteration":[2-9]' || true)"
  if [ -n "$retries" ]; then
    echo "$retries" \
      | sed -n 's/.*"agent":"\([^"]*\)".*"iteration":\([0-9]*\).*/\1 iteration:\2/p' \
      | while IFS= read -r line; do
          echo "  $line"
        done
  else
    echo "  (no retries — all first-attempt)"
  fi
else
  echo "  (none)"
fi
echo ""

# --- Timeline ---

print_timeline
