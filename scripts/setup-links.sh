#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# setup-links.sh
#
# Creates symbolic links from the AI Registry into the current working
# directory (or a specified target project directory).
#
# Usage:
#   ./setup-links.sh                  # Links into current directory
#   ./setup-links.sh /path/to/project # Links into specified directory
#   ./setup-links.sh --force          # Remove all registry symlinks, then recreate
#   ./setup-links.sh --force /path    # Same, with explicit target
#
# Note for Windows users:
#   This script uses POSIX symlinks (ln -s) and requires a Unix-like shell.
#   On Windows, use one of the following:
#     - Git Bash or WSL (Windows Subsystem for Linux) to run this script as-is
#     - PowerShell: New-Item -ItemType SymbolicLink -Path <link> -Target <target>
#       (requires Administrator privileges or Developer Mode enabled)
# =============================================================================

FORCE=false
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    *) POSITIONAL+=("$arg") ;;
  esac
done

REGISTRY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${POSITIONAL[0]:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

log_ok()    { echo -e "  ${GREEN}[OK]${NC} $1"; }
log_skip()  { echo -e "${YELLOW}[SKIP]${NC} $1"; }
log_fail()  { echo -e "  ${RED}[FAIL]${NC} $1"; }
log_clean() { echo -e " ${CYAN}[DEL]${NC} $1"; }

# Remove all symlinks in TARGET_DIR that resolve into REGISTRY_DIR.
# Walks one level deep + known nested paths. Handles stale links from
# entries that were removed from the script (e.g. .cursorrules, .clinerules).
clean_registry_links() {
  local candidates=(
    "$TARGET_DIR/.cursor/rules"
    "$TARGET_DIR/.cursor/agents"
    "$TARGET_DIR/.cursor/skills"
    "$TARGET_DIR/.roomodes"
    "$TARGET_DIR/.roo"
    "$TARGET_DIR/CLAUDE.md"
    "$TARGET_DIR/AGENTS.md"
    # Legacy / previously created — cleaned up even if no longer in the script
    "$TARGET_DIR/.cursorrules"
    "$TARGET_DIR/.clinerules"
    "$TARGET_DIR/.skills"
  )

  local removed=0
  for candidate in "${candidates[@]}"; do
    if [ -L "$candidate" ]; then
      local target
      target="$(readlink "$candidate")"
      if [[ "$target" == "$REGISTRY_DIR"* ]]; then
        rm "$candidate"
        log_clean "$(basename "$candidate") (was → $target)"
        ((removed++))
      fi
    fi
  done

  if [ "$removed" -eq 0 ]; then
    echo "  (no stale registry links found)"
  fi
  echo ""
}

create_link() {
  local source="$1"
  local dest="$2"
  local label="$3"

  if [ ! -e "$source" ]; then
    log_fail "$label — source does not exist: $source"
    return 1
  fi

  if [ -L "$dest" ]; then
    local existing_target
    existing_target="$(readlink "$dest")"
    if [ "$existing_target" = "$source" ]; then
      log_skip "$label — symlink already points to registry"
      return 0
    else
      log_fail "$label — symlink exists but points elsewhere: $existing_target"
      return 1
    fi
  fi

  if [ -e "$dest" ]; then
    log_fail "$label — file already exists (not a symlink). Back it up and retry."
    return 1
  fi

  local dest_parent
  dest_parent="$(dirname "$dest")"
  mkdir -p "$dest_parent"

  ln -s "$source" "$dest"
  log_ok "$label"
}

echo ""
echo "AI Registry — Symlink Setup"
echo "============================"
echo "  Registry : $REGISTRY_DIR"
echo "  Target   : $TARGET_DIR"
echo "  Force    : $FORCE"
echo ""

if [ "$FORCE" = true ]; then
  echo "Cleaning existing registry links..."
  clean_registry_links
fi

ERRORS=0

create_link \
  "$REGISTRY_DIR/cursor/.cursor/rules" \
  "$TARGET_DIR/.cursor/rules" \
  ".cursor/rules/" \
  || ((ERRORS++))

create_link \
  "$REGISTRY_DIR/cursor/.cursor/agents" \
  "$TARGET_DIR/.cursor/agents" \
  ".cursor/agents/" \
  || ((ERRORS++))

create_link \
  "$REGISTRY_DIR/common-skills" \
  "$TARGET_DIR/.cursor/skills" \
  ".cursor/skills/" \
  || ((ERRORS++))

create_link \
  "$REGISTRY_DIR/roo-code/.roomodes" \
  "$TARGET_DIR/.roomodes" \
  ".roomodes" \
  || ((ERRORS++))

create_link \
  "$REGISTRY_DIR/roo-code" \
  "$TARGET_DIR/.roo" \
  ".roo/" \
  || ((ERRORS++))

create_link \
  "$REGISTRY_DIR/claude/CLAUDE.md" \
  "$TARGET_DIR/CLAUDE.md" \
  "CLAUDE.md" \
  || ((ERRORS++))

create_link \
  "$REGISTRY_DIR/codex/AGENTS.md" \
  "$TARGET_DIR/AGENTS.md" \
  "AGENTS.md" \
  || ((ERRORS++))

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo -e "${GREEN}All links created successfully.${NC}"
else
  echo -e "${YELLOW}Completed with $ERRORS issue(s). Review the output above.${NC}"
fi

echo ""
echo "Tip: Add these to your global gitignore so they never leak into project repos."
echo "     See the README for instructions."
echo ""
