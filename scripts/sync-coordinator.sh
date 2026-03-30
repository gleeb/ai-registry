#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# sync-coordinator.sh — Derive stories_remaining from planning artifacts
#
# Scans plan/user-stories/*/story.md, extracts execution_order from each,
# sorts by that order, diffs against stories_done in .sdlc/coordinator.yaml,
# and writes the result back as stories_remaining.
#
# Usage:
#   sync-coordinator.sh [project-root]
#
# If project-root is provided, operates on that directory.
# Otherwise operates on the current working directory.
# =============================================================================

PROJECT_ROOT="${1:-.}"
cd "$PROJECT_ROOT"

SDLC_DIR=".sdlc"
COORD_FILE="$SDLC_DIR/coordinator.yaml"
STORIES_DIR="plan/user-stories"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

yaml_read() {
  local file="$1" key="$2"
  if [ -f "$file" ]; then
    grep "^${key}:" "$file" 2>/dev/null | sed "s/^${key}: *//" | sed 's/^"//' | sed 's/"$//' || echo ""
  else
    echo ""
  fi
}

yaml_read_list() {
  local file="$1" key="$2"
  if [ -f "$file" ]; then
    local line
    line="$(grep "^${key}:" "$file" 2>/dev/null | sed "s/^${key}: *//" || echo "[]")"
    echo "$line" | sed 's/^\[//' | sed 's/\]$//' | sed 's/,/ /g' | tr -d '"' | tr -d "'"
  else
    echo ""
  fi
}

# --- Preflight checks ---

if [ ! -d "$STORIES_DIR" ]; then
  echo "ERROR: $STORIES_DIR not found in $(pwd)." >&2
  echo "Usage: sync-coordinator.sh [project-root]" >&2
  exit 1
fi

if [ ! -d "$SDLC_DIR" ]; then
  mkdir -p "$SDLC_DIR"
fi

# --- Read current coordinator state ---

cur_hub="$(yaml_read "$COORD_FILE" "active_hub")"
cur_story="$(yaml_read "$COORD_FILE" "current_story")"
cur_done="$(yaml_read_list "$COORD_FILE" "stories_done")"
cur_hint="$(yaml_read "$COORD_FILE" "resume_hint")"

# --- Scan stories and extract execution_order ---

echo "Scanning ${STORIES_DIR}/..."
echo

# Build "order slug" pairs, one per story
story_pairs=""
for story_file in "$STORIES_DIR"/*/story.md; do
  [ -f "$story_file" ] || continue
  slug="$(basename "$(dirname "$story_file")")"
  order="$(grep -E "^-?\s*execution_order:" "$story_file" 2>/dev/null | head -1 | sed 's/.*execution_order: *//' | tr -d ' ' || true)"
  if [ -z "$order" ]; then
    order="999"
  fi
  story_pairs="${story_pairs}${order} ${slug}\n"
done

if [ -z "$story_pairs" ]; then
  echo "No stories found in ${STORIES_DIR}/*/story.md"
  exit 0
fi

# Sort by execution_order (numeric)
sorted="$(printf '%b' "$story_pairs" | sort -n -k1)"

# --- Diff against stories_done ---

remaining=""
while IFS=' ' read -r order slug; do
  [ -z "$slug" ] && continue
  if echo " $cur_done " | grep -q " $slug "; then
    printf "  %-40s (order: %s) -- DONE\n" "$slug" "$order"
  else
    printf "  %-40s (order: %s) -- REMAINING\n" "$slug" "$order"
    remaining="${remaining} ${slug}"
  fi
done <<< "$sorted"

remaining="$(echo "$remaining" | sed 's/^ *//;s/ *$//;s/  */ /g')"

# --- Determine current_story ---

old_story="$cur_story"
if { [ -z "$cur_story" ] || [ "$cur_story" = "null" ]; } && [ -n "$remaining" ]; then
  cur_story="$(echo "$remaining" | awk '{print $1}')"
fi

# --- Write back to coordinator.yaml ---

done_yaml="[]"
if [ -n "$cur_done" ]; then
  done_yaml="[$(echo "$cur_done" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
fi

remaining_yaml="[]"
if [ -n "$remaining" ]; then
  remaining_yaml="[$(echo "$remaining" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
fi

hint="No active work."
if [ -n "$cur_hub" ] && [ "$cur_hub" != "null" ] && [ -n "$cur_story" ] && [ "$cur_story" != "null" ]; then
  hint="${cur_hub} active, story ${cur_story}."
elif [ -n "$remaining" ]; then
  hint="Stories remaining. Next: $(echo "$remaining" | awk '{print $1}')."
fi

cat > "$COORD_FILE" <<EOF
last_updated: "${TIMESTAMP}"
active_hub: ${cur_hub:-null}
current_story: ${cur_story:-null}
stories_done: ${done_yaml}
stories_remaining: ${remaining_yaml}
resume_hint: "${hint}"
EOF

# --- Summary ---

echo
echo "Updated ${COORD_FILE}:"
echo "  stories_remaining: ${remaining_yaml}"
if [ "$old_story" != "$cur_story" ]; then
  echo "  current_story: ${cur_story} (was: ${old_story:-null})"
else
  echo "  current_story: ${cur_story:-null} (unchanged)"
fi
