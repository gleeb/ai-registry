#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# add-skill.sh
#
# Symlinks a specific skill from the AI Registry into a target project for
# a given IDE/provider.
#
# Usage:
#   ./add-skill.sh <skill-name> <project-path> <provider>
#   ./add-skill.sh scaffold-project /path/to/my-app cursor
#   ./add-skill.sh scaffold-project . all
#
# Providers:
#   cursor    → .cursor/skills/<skill>
#   claude    → .claude/skills/<skill>
#   codex     → .codex/skills/<skill>
#   roo       → .roo/skills/<skill>
#   windsurf  → .windsurf/skills/<skill>
#   kilo      → .kilocode/skills/<skill>
#   all       → symlinks into every provider directory above
#
# The skill must exist as a folder under common-skills/ in the registry.
# =============================================================================

REGISTRY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REGISTRY_DIR/common-skills"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
  echo ""
  echo "Usage: $(basename "$0") <skill-name> <project-path> <provider>"
  echo ""
  echo "Arguments:"
  echo "  skill-name     Name of the skill folder under common-skills/ (e.g. scaffold-project)"
  echo "  project-path   Path to the target project root (use . for current directory)"
  echo "  provider       One of: cursor, claude, codex, roo, windsurf, kilo, all"
  echo ""
  echo "Available skills:"
  for dir in "$SKILLS_DIR"/*/; do
    [ -f "$dir/SKILL.md" ] && echo "  $(basename "$dir")"
  done
  echo ""
  echo "Examples:"
  echo "  $(basename "$0") scaffold-project ./my-app cursor"
  echo "  $(basename "$0") scaffold-project . all"
  echo ""
}

log_ok()   { echo -e "  ${GREEN}[OK]${NC} $1"; }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
log_fail() { echo -e "  ${RED}[FAIL]${NC} $1"; }

# Maps a provider name to its project-level skills directory (relative to project root)
provider_skills_dir() {
  case "$1" in
    cursor)   echo ".cursor/skills" ;;
    claude)   echo ".claude/skills" ;;
    codex)    echo ".codex/skills" ;;
    roo)      echo ".roo/skills" ;;
    windsurf) echo ".windsurf/skills" ;;
    kilo)     echo ".kilocode/skills" ;;
    *) return 1 ;;
  esac
}

create_link() {
  local source="$1"
  local dest="$2"
  local label="$3"

  if [ -L "$dest" ]; then
    local existing_target
    existing_target="$(readlink "$dest")"
    if [ "$existing_target" = "$source" ]; then
      log_skip "$label — already linked"
      return 0
    else
      log_fail "$label — symlink exists but points elsewhere: $existing_target"
      return 1
    fi
  fi

  if [ -e "$dest" ]; then
    log_fail "$label — path already exists (not a symlink). Back it up and retry."
    return 1
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$source" "$dest"
  log_ok "$label"
}

link_skill_for_provider() {
  local skill_source="$1"
  local skill_name="$2"
  local target_dir="$3"
  local provider="$4"

  local rel_dir
  rel_dir="$(provider_skills_dir "$provider")" || {
    log_fail "Unknown provider: $provider"
    return 1
  }

  local dest="$target_dir/$rel_dir/$skill_name"
  local label="$provider → $rel_dir/$skill_name"

  create_link "$skill_source" "$dest" "$label"
}

# --- Argument validation ---

if [ $# -lt 3 ]; then
  usage
  exit 1
fi

SKILL_NAME="$1"
PROJECT_PATH="$2"
PROVIDER="$3"

SKILL_SOURCE="$SKILLS_DIR/$SKILL_NAME"
ALL_PROVIDERS=(cursor claude codex roo windsurf kilo)

if [ ! -d "$SKILL_SOURCE" ] || [ ! -f "$SKILL_SOURCE/SKILL.md" ]; then
  echo -e "${RED}Error:${NC} Skill '$SKILL_NAME' not found in $SKILLS_DIR"
  echo ""
  echo "Available skills:"
  for dir in "$SKILLS_DIR"/*/; do
    [ -f "$dir/SKILL.md" ] && echo "  $(basename "$dir")"
  done
  exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
  echo -e "${RED}Error:${NC} Project path does not exist: $PROJECT_PATH"
  exit 1
fi

TARGET_DIR="$(cd "$PROJECT_PATH" && pwd)"

if [ "$PROVIDER" != "all" ]; then
  provider_skills_dir "$PROVIDER" > /dev/null 2>&1 || {
    echo -e "${RED}Error:${NC} Unknown provider '$PROVIDER'"
    echo "Valid providers: ${ALL_PROVIDERS[*]} all"
    exit 1
  }
fi

# --- Execute ---

echo ""
echo -e "${CYAN}Add Skill — AI Registry${NC}"
echo "========================"
echo "  Skill    : $SKILL_NAME"
echo "  Source   : $SKILL_SOURCE"
echo "  Target   : $TARGET_DIR"
echo "  Provider : $PROVIDER"
echo ""

ERRORS=0

if [ "$PROVIDER" = "all" ]; then
  for p in "${ALL_PROVIDERS[@]}"; do
    link_skill_for_provider "$SKILL_SOURCE" "$SKILL_NAME" "$TARGET_DIR" "$p" || ((ERRORS++))
  done
else
  link_skill_for_provider "$SKILL_SOURCE" "$SKILL_NAME" "$TARGET_DIR" "$PROVIDER" || ((ERRORS++))
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo -e "${GREEN}Done.${NC} Skill '$SKILL_NAME' linked successfully."
else
  echo -e "${YELLOW}Completed with $ERRORS issue(s). Review the output above.${NC}"
fi
echo ""
