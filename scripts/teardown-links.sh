#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# teardown-links.sh
#
# Removes all symbolic links created by the AI Registry (setup-links.sh and
# add-skill.sh) from a target project directory, then optionally re-installs
# for a single IDE.
#
# Usage:
#   ./teardown-links.sh                       # Remove all, no reinstall
#   ./teardown-links.sh --reinstall cursor     # Remove all, then setup cursor
#   ./teardown-links.sh --reinstall roo .      # Remove all from ., setup roo
#   ./teardown-links.sh --dry-run              # Show what would be removed
#   ./teardown-links.sh /path/to/project       # Remove all from specific dir
#
# IDEs: cursor, roo, kilo, claude, codex, opencode
# =============================================================================

REGISTRY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DRY_RUN=false
REINSTALL_IDE=""
POSITIONAL=()

for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=true ;;
    --reinstall) REINSTALL_IDE="__NEXT__" ;;
    cursor|roo|kilo|claude|codex|opencode)
      if [ "$REINSTALL_IDE" = "__NEXT__" ]; then
        REINSTALL_IDE="$arg"
      else
        POSITIONAL+=("$arg")
      fi
      ;;
    *)
      if [ "$REINSTALL_IDE" = "__NEXT__" ]; then
        echo "Error: --reinstall requires an IDE name (cursor, roo, kilo, claude, codex, opencode)"
        exit 1
      fi
      POSITIONAL+=("$arg")
      ;;
  esac
done

if [ "$REINSTALL_IDE" = "__NEXT__" ]; then
  echo "Error: --reinstall requires an IDE name (cursor, roo, kilo, claude, codex, opencode)"
  exit 1
fi

TARGET_DIR="${POSITIONAL[0]:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
DIM='\033[2m'
NC='\033[0m'

log_del()  { echo -e " ${CYAN}[DEL]${NC} $1"; }
log_dry()  { echo -e " ${DIM}[DRY]${NC} $1"; }
log_ok()   { echo -e "  ${GREEN}[OK]${NC} $1"; }
log_info() { echo -e "  ${BLUE}[INFO]${NC} $1"; }

# Known paths that setup-links.sh creates (checked explicitly)
KNOWN_LINK_PATHS=(
  ".cursor/rules"
  ".cursor/agents"
  ".cursor/skills"
  ".roomodes"
  ".roo"
  ".kilocodemodes"
  ".kilo"
  ".kilocode"
  "kilo.jsonc"
  "CLAUDE.md"
  "AGENTS.md"
  ".opencode/AGENTS.md"
  ".opencode"
  "opencode.json"
  ".cursorrules"
  ".clinerules"
  ".skills"
)

# Skill directories where add-skill.sh may have placed per-skill symlinks
SKILL_DIRS=(
  ".cursor/skills"
  ".claude/skills"
  ".codex/skills"
  ".roo/skills"
  ".windsurf/skills"
  ".kilocode/skills"
)

removed=0
errors=0

remove_link() {
  local path="$1"
  local rel="${path#"$TARGET_DIR"/}"
  local target
  target="$(readlink "$path" 2>/dev/null || echo '?')"

  if $DRY_RUN; then
    log_dry "would remove $rel → $target"
  else
    rm -f "$path"
    log_del "$rel → $target"
  fi
  removed=$((removed + 1))
}

is_registry_link() {
  local path="$1"
  [ -L "$path" ] || return 1
  local target
  target="$(readlink "$path")"
  [[ "$target" == "$REGISTRY_DIR"* ]]
}

remove_if_registry_link() {
  local path="$1"
  if is_registry_link "$path"; then
    remove_link "$path"
  fi
}

cleanup_empty_dir() {
  local dir="$1"
  if [ -d "$dir" ] && [ -z "$(ls -A "$dir" 2>/dev/null)" ]; then
    if $DRY_RUN; then
      log_dry "would remove empty dir ${dir#"$TARGET_DIR"/}"
    else
      rmdir "$dir" 2>/dev/null && log_del "empty dir ${dir#"$TARGET_DIR"/}" || true
    fi
  fi
}

# ─── Banner ──────────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}AI Registry — Teardown${NC}"
echo "======================"
echo "  Registry : $REGISTRY_DIR"
echo "  Target   : $TARGET_DIR"
if $DRY_RUN; then
  echo -e "  Mode     : ${YELLOW}dry-run (no changes)${NC}"
fi
if [ -n "$REINSTALL_IDE" ]; then
  echo -e "  Reinstall: ${GREEN}$REINSTALL_IDE${NC}"
fi
echo ""

# ─── Phase 1: Remove known top-level links ───────────────────────────────────

echo "Scanning known link paths..."

for rel in "${KNOWN_LINK_PATHS[@]}"; do
  remove_if_registry_link "$TARGET_DIR/$rel"
done

# ─── Phase 2: Remove per-skill symlinks from skill directories ───────────────

echo ""
echo "Scanning skill directories for per-skill links..."

for skill_rel in "${SKILL_DIRS[@]}"; do
  skill_dir="$TARGET_DIR/$skill_rel"
  [ -d "$skill_dir" ] || continue

  for entry in "$skill_dir"/*/; do
    [ -e "$entry" ] || continue
    entry="${entry%/}"
    remove_if_registry_link "$entry"
  done
done

# ─── Phase 3: Deep scan for any remaining registry symlinks ──────────────────

echo ""
echo "Deep scanning for any remaining registry symlinks..."

while IFS= read -r -d '' link; do
  if is_registry_link "$link"; then
    remove_link "$link"
  fi
done < <(find "$TARGET_DIR" -maxdepth 4 -type l -print0 2>/dev/null || true)

# ─── Phase 4: Clean up empty directories ─────────────────────────────────────

echo ""
echo "Cleaning up empty directories..."

for skill_rel in "${SKILL_DIRS[@]}"; do
  cleanup_empty_dir "$TARGET_DIR/$skill_rel"
done

for dir in ".cursor" ".claude" ".codex" ".roo" ".windsurf" ".kilocode" ".opencode"; do
  cleanup_empty_dir "$TARGET_DIR/$dir"
done

# ─── Summary ──────────────────────────────────────────────────────────────────

echo ""
if [ "$removed" -eq 0 ]; then
  echo -e "${YELLOW}No registry symlinks found in $TARGET_DIR${NC}"
else
  if $DRY_RUN; then
    echo -e "${YELLOW}Would remove $removed symlink(s). Run without --dry-run to apply.${NC}"
  else
    echo -e "${GREEN}Removed $removed symlink(s) from $TARGET_DIR${NC}"
  fi
fi

# ─── Phase 5: Reinstall for a single IDE ─────────────────────────────────────

if [ -n "$REINSTALL_IDE" ]; then
  echo ""
  echo -e "${CYAN}Re-installing for ${GREEN}$REINSTALL_IDE${CYAN}...${NC}"

  if $DRY_RUN; then
    echo -e "${YELLOW}Skipping reinstall (dry-run mode).${NC}"
  else
    "$REGISTRY_DIR/scripts/setup-links.sh" "$REINSTALL_IDE"
  fi
fi

echo ""
