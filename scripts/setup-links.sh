#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# setup-links.sh
#
# Creates symbolic links from the AI Registry into the current working
# directory (or a specified target project directory).
#
# Usage:
#   ./setup-links.sh                  # Interactive menu to select IDEs
#   ./setup-links.sh --all            # Install all IDEs (non-interactive)
#   ./setup-links.sh --force          # Remove all registry symlinks, then recreate
#   ./setup-links.sh [ide1 ide2 ...]  # Install specific IDEs (non-interactive)
#
# IDEs: cursor, roo, kilo, claude, codex, opencode, all
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
MODE="menu"
SELECTED_IDES=()

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --all) MODE="all" ;;
    --menu) MODE="menu" ;;
    cursor|roo|kilo|claude|codex|opencode)
      SELECTED_IDES+=("$arg")
      ;;
    *)
      POSITIONAL+=("$arg")
      ;;
  esac
done

if [ ${#SELECTED_IDES[@]} -gt 0 ]; then
  MODE="specific"
fi

REGISTRY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${POSITIONAL[0]:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

log_ok()    { echo -e "  ${GREEN}[OK]${NC} $1"; }
log_skip()  { echo -e "${YELLOW}[SKIP]${NC} $1"; }
log_fail()  { echo -e "  ${RED}[FAIL]${NC} $1"; }
log_clean() { echo -e " ${CYAN}[DEL]${NC} $1"; }
log_info()  { echo -e "  ${BLUE}[INFO]${NC} $1"; }

declare -A IDE_LINKS
IDE_LINKS["cursor"]="cursor"
IDE_LINKS["roo"]="roo"
IDE_LINKS["kilo"]="kilo"
IDE_LINKS["claude"]="claude"
IDE_LINKS["codex"]="codex"
IDE_LINKS["opencode"]="opencode"

clean_registry_links() {
  local candidates=(
    "$TARGET_DIR/.cursor/rules"
    "$TARGET_DIR/.cursor/agents"
    "$TARGET_DIR/.cursor/skills"
    "$TARGET_DIR/.roomodes"
    "$TARGET_DIR/.roo"
    "$TARGET_DIR/.kilocodemodes"
    "$TARGET_DIR/.kilo"
    "$TARGET_DIR/.kilocode"
    "$TARGET_DIR/kilo.jsonc"
    "$TARGET_DIR/CLAUDE.md"
    "$TARGET_DIR/AGENTS.md"
    "$TARGET_DIR/.opencode/AGENTS.md"
    "$TARGET_DIR/.opencode"
    "$TARGET_DIR/opencode.json"
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
        removed=$((removed + 1))
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

install_cursor() {
  local errors=0
  echo ""
  echo "Installing Cursor links..."
  create_link "$REGISTRY_DIR/cursor/.cursor/rules" "$TARGET_DIR/.cursor/rules" ".cursor/rules/" || ((errors++))
  create_link "$REGISTRY_DIR/cursor/.cursor/agents" "$TARGET_DIR/.cursor/agents" ".cursor/agents/" || ((errors++))
  create_link "$REGISTRY_DIR/common-skills" "$TARGET_DIR/.cursor/skills" ".cursor/skills/" || ((errors++))
  return $errors
}

install_roo() {
  local errors=0
  echo ""
  echo "Installing Roo Code links..."
  create_link "$REGISTRY_DIR/roo-code/.roomodes" "$TARGET_DIR/.roomodes" ".roomodes" || ((errors++))
  create_link "$REGISTRY_DIR/roo-code/.roo" "$TARGET_DIR/.roo" ".roo/" || ((errors++))
  return $errors
}

install_kilo() {
  local errors=0
  echo ""
  echo "Installing Kilo Code links..."
  create_link "$REGISTRY_DIR/kilo-code/.kilo" "$TARGET_DIR/.kilo" ".kilo/" || ((errors++))
  create_link "$REGISTRY_DIR/kilo-code/.kilocodemodes" "$TARGET_DIR/.kilocodemodes" ".kilocodemodes" || ((errors++))
  create_link "$REGISTRY_DIR/kilo-code/kilo.jsonc" "$TARGET_DIR/kilo.jsonc" "kilo.jsonc" || ((errors++))
  create_link "$REGISTRY_DIR/kilo-code/AGENTS.md" "$TARGET_DIR/AGENTS.md" "AGENTS.md (Kilo)" || ((errors++))
  return $errors
}

install_claude() {
  local errors=0
  echo ""
  echo "Installing Claude links..."
  create_link "$REGISTRY_DIR/claude/CLAUDE.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md" || ((errors++))
  return $errors
}

install_codex() {
  local errors=0
  echo ""
  echo "Installing Codex links..."
  create_link "$REGISTRY_DIR/codex/AGENTS.md" "$TARGET_DIR/AGENTS.md" "AGENTS.md" || ((errors++))
  return $errors
}

install_opencode() {
  local errors=0
  echo ""
  echo "Installing OpenCode links..."
  create_link "$REGISTRY_DIR/opencode/.opencode" "$TARGET_DIR/.opencode" ".opencode/" || ((errors++))
  create_link "$REGISTRY_DIR/opencode/opencode.json" "$TARGET_DIR/opencode.json" "opencode.json" || ((errors++))
  create_link "$REGISTRY_DIR/opencode/AGENTS.md" "$TARGET_DIR/.opencode/AGENTS.md" ".opencode/AGENTS.md" || ((errors++))
  return $errors
}

show_menu() {
  local selected=()
  local done=false

  echo ""
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║          AI Registry — Symlink Setup (Interactive)            ║"
  echo "╠════════════════════════════════════════════════════════════════╣"
  echo "║  Registry : $REGISTRY_DIR"
  echo "║  Target   : $TARGET_DIR"
  echo "╠════════════════════════════════════════════════════════════════╣"
  echo "║  Select IDEs to install (toggle with number key):              ║"
  echo "║                                                                ║"
  echo "║  [1] Cursor   - .cursor/rules, .cursor/agents, .cursor/skills  ║"
  echo "║  [2] Roo Code - .roomodes, .roo                               ║"
  echo "║  [3] Kilo     - .kilo/, kilo.jsonc, AGENTS.md                  ║"
  echo "║  [4] Claude   - CLAUDE.md                                     ║"
  echo "║  [5] Codex    - AGENTS.md                                     ║"
  echo "║  [6] OpenCode - .opencode/, opencode.json, .opencode/AGENTS.md  ║"
  echo "║                                                                ║"
  echo "║  [A] Select All                                               ║"
  echo "║  [N] Deselect All                                             ║"
  echo "║                                                                ║"
  echo "║  [ENTER] Install selected                                     ║"
  echo "║  [Q] Quit                                                     ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""

  for i in {1..6}; do
    selected+=("off")
  done

  while ! $done; do
    echo "Selected IDEs: $(echo "${selected[@]}" | tr ' ' '\n' | grep -c on) / 6"
    echo ""
    for i in {1..6}; do
      local name
      name=$(echo "Cursor Roo Kilo Claude Codex OpenCode" | cut -d' ' -f$i)
      local status="[ ]"
      if [ "${selected[$((i-1))]}" = "on" ]; then
        status="${GREEN}[*]${NC}"
      fi
      printf "  %s %s\n" "$status" "$name"
    done
    echo ""
    echo -n "Enter choice (1-6, A, N, Enter, or Q): "
    read -n 1 -r key
    echo ""

    case "$key" in
      1|2|3|4|5|6)
        idx=$((key-1))
        if [ "${selected[$idx]}" = "on" ]; then
          selected[$idx]="off"
        else
          selected[$idx]="on"
        fi
        ;;
      a|A)
        for i in {0..5}; do selected[$i]="on"; done
        ;;
      n|N)
        for i in {0..5}; do selected[$i]="off"; done
        ;;
      "")
        done=true
        ;;
      q|Q)
        echo "Aborted."
        exit 0
        ;;
    esac
  done

  for i in {1..6}; do
    if [ "${selected[$((i-1))]}" = "on" ]; then
      case $i in
        1) SELECTED_IDES+=("cursor") ;;
        2) SELECTED_IDES+=("roo") ;;
        3) SELECTED_IDES+=("kilo") ;;
        4) SELECTED_IDES+=("claude") ;;
        5) SELECTED_IDES+=("codex") ;;
        6) SELECTED_IDES+=("opencode") ;;
      esac
    fi
  done
}

echo ""
echo "AI Registry — Symlink Setup"
echo "============================"

if [ "$MODE" = "menu" ] && [ ${#SELECTED_IDES[@]} -eq 0 ]; then
  show_menu
fi

if [ ${#SELECTED_IDES[@]} -eq 0 ] && [ "$MODE" != "menu" ]; then
  echo "No IDEs selected. Use --all or specify IDEs."
  echo "Usage: $0 [--all] [cursor] [roo] [kilo] [claude] [codex] [opencode]"
  exit 1
fi

if [ "$FORCE" = true ]; then
  echo ""
  echo "Cleaning existing registry links..."
  clean_registry_links
fi

ERRORS=0

for ide in "${SELECTED_IDES[@]}"; do
  case "$ide" in
    cursor)  install_cursor  || ERRORS=$((ERRORS + 1)) ;;
    roo)    install_roo     || ERRORS=$((ERRORS + 1)) ;;
    kilo)   install_kilo    || ERRORS=$((ERRORS + 1)) ;;
    claude) install_claude  || ERRORS=$((ERRORS + 1)) ;;
    codex)  install_codex  || ERRORS=$((ERRORS + 1)) ;;
    opencode) install_opencode || ERRORS=$((ERRORS + 1)) ;;
    all)
      install_cursor  || ERRORS=$((ERRORS + 1))
      install_roo     || ERRORS=$((ERRORS + 1))
      install_kilo    || ERRORS=$((ERRORS + 1))
      install_claude  || ERRORS=$((ERRORS + 1))
      install_codex   || ERRORS=$((ERRORS + 1))
      install_opencode || ERRORS=$((ERRORS + 1))
      ;;
  esac
done

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
