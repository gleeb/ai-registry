#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# checkpoint.sh — SDLC Checkpoint Writer
#
# Maintains .sdlc/*.yaml state files for crash-safe workflow resumption.
# Auto-creates .sdlc/ directory on first invocation.
#
# Usage:
#   checkpoint.sh coordinator [flags]
#   checkpoint.sh planning [flags]
#   checkpoint.sh execution [flags]
#   checkpoint.sh init
# =============================================================================

SDLC_DIR=".sdlc"
HISTORY_LOG="$SDLC_DIR/history.log"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

ensure_sdlc_dir() {
  if [ ! -d "$SDLC_DIR" ]; then
    mkdir -p "$SDLC_DIR"
  fi
}

append_history() {
  local hub="$1"
  local detail="$2"
  echo "${TIMESTAMP}|${hub}|${detail}" >> "$HISTORY_LOG"
}

# ---------------------------------------------------------------------------
# YAML read helpers — lightweight parsing without external deps
# ---------------------------------------------------------------------------

yaml_read() {
  local file="$1"
  local key="$2"
  if [ -f "$file" ]; then
    grep "^${key}:" "$file" 2>/dev/null | sed "s/^${key}: *//" | sed 's/^"//' | sed 's/"$//' || echo ""
  else
    echo ""
  fi
}

yaml_read_list() {
  local file="$1"
  local key="$2"
  if [ -f "$file" ]; then
    local line
    line="$(grep "^${key}:" "$file" 2>/dev/null | sed "s/^${key}: *//" || echo "[]")"
    echo "$line" | sed 's/^\[//' | sed 's/\]$//' | sed 's/,/ /g' | tr -d '"' | tr -d "'"
  else
    echo ""
  fi
}

# ---------------------------------------------------------------------------
# COORDINATOR subcommand
# ---------------------------------------------------------------------------

cmd_coordinator() {
  local file="$SDLC_DIR/coordinator.yaml"
  ensure_sdlc_dir

  local hub="" story="" story_done=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --hub) hub="$2"; shift 2 ;;
      --story) story="$2"; shift 2 ;;
      --story-done) story_done="$2"; shift 2 ;;
      *) echo "Unknown coordinator flag: $1" >&2; exit 1 ;;
    esac
  done

  # Read existing values
  local cur_hub cur_story cur_done cur_remaining
  cur_hub="$(yaml_read "$file" "active_hub")"
  cur_story="$(yaml_read "$file" "current_story")"
  cur_done="$(yaml_read_list "$file" "stories_done")"
  cur_remaining="$(yaml_read_list "$file" "stories_remaining")"

  # Apply patches
  [ -n "$hub" ] && cur_hub="$hub"
  [ -n "$story" ] && cur_story="$story"

  if [ -n "$story_done" ]; then
    # Add to done list if not already there
    if ! echo " $cur_done " | grep -q " $story_done "; then
      cur_done="$cur_done $story_done"
    fi
    # Remove from remaining list
    cur_remaining="$(echo "$cur_remaining" | tr ' ' '\n' | grep -v "^${story_done}$" | tr '\n' ' ')"
    cur_remaining="$(echo "$cur_remaining" | xargs)"
  fi

  cur_done="$(echo "$cur_done" | xargs)"
  cur_remaining="$(echo "$cur_remaining" | xargs)"

  # Generate resume hint
  local hint="No active work."
  if [ -n "$cur_hub" ] && [ -n "$cur_story" ]; then
    hint="${cur_hub^} active, story ${cur_story}. Route to sdlc-$([ "$cur_hub" = "planning" ] && echo "planner" || echo "architect")."
  elif [ -n "$cur_hub" ]; then
    hint="${cur_hub^} active. Route to sdlc-$([ "$cur_hub" = "planning" ] && echo "planner" || echo "architect")."
  fi

  # Format lists for YAML
  local done_yaml="[]"
  if [ -n "$cur_done" ]; then
    done_yaml="[$(echo "$cur_done" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
  fi
  local remaining_yaml="[]"
  if [ -n "$cur_remaining" ]; then
    remaining_yaml="[$(echo "$cur_remaining" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
  fi

  cat > "$file" <<EOF
last_updated: "${TIMESTAMP}"
active_hub: ${cur_hub:-null}
current_story: ${cur_story:-null}
stories_done: ${done_yaml}
stories_remaining: ${remaining_yaml}
resume_hint: "${hint}"
EOF

  local detail="hub:${cur_hub:-none}|story:${cur_story:-none}"
  [ -n "$story_done" ] && detail="story-done:${story_done}"
  append_history "coordinator" "$detail"
}

# ---------------------------------------------------------------------------
# PLANNING subcommand
# ---------------------------------------------------------------------------

cmd_planning() {
  local file="$SDLC_DIR/planning.yaml"
  ensure_sdlc_dir

  local phase="" story="" agents_done="" agents_pending=""
  local dispatch="" completed="" story_done=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --phase) phase="$2"; shift 2 ;;
      --story) story="$2"; shift 2 ;;
      --agents-done) agents_done="$2"; shift 2 ;;
      --agents-pending) agents_pending="$2"; shift 2 ;;
      --dispatch) dispatch="$2"; shift 2 ;;
      --completed) completed="$2"; shift 2 ;;
      --story-done) story_done="$2"; shift 2 ;;
      *) echo "Unknown planning flag: $1" >&2; exit 1 ;;
    esac
  done

  # Read existing values
  local cur_phase cur_story cur_done cur_pending cur_in_progress
  cur_phase="$(yaml_read "$file" "phase")"
  cur_story="$(yaml_read "$file" "current_story")"
  cur_done="$(yaml_read_list "$file" "agents_done")"
  cur_pending="$(yaml_read_list "$file" "agents_pending")"
  cur_in_progress="$(yaml_read "$file" "agent_in_progress")"
  local cur_completed_phases
  cur_completed_phases="$(yaml_read_list "$file" "completed_phases")"
  local cur_total_stories
  cur_total_stories="$(yaml_read "$file" "total_stories")"

  # Apply patches
  if [ -n "$phase" ]; then
    # Moving to a new phase — record old phase as completed
    if [ -n "$cur_phase" ] && [ "$cur_phase" != "$phase" ]; then
      if ! echo " $cur_completed_phases " | grep -q " $cur_phase "; then
        cur_completed_phases="$cur_completed_phases $cur_phase"
      fi
    fi
    cur_phase="$phase"
  fi
  [ -n "$story" ] && cur_story="$story"

  # Override agent lists if explicitly provided
  if [ -n "$agents_done" ]; then
    cur_done="$(echo "$agents_done" | tr ',' ' ')"
  fi
  if [ -n "$agents_pending" ]; then
    cur_pending="$(echo "$agents_pending" | tr ',' ' ')"
  fi

  # Handle dispatch — move target domain to in_progress
  if [ -n "$dispatch" ]; then
    # Extract domain from agent slug: sdlc-planner-hld -> hld, sdlc-plan-validator -> validator
    local domain
    domain="$(echo "$dispatch" | sed 's/sdlc-planner-//' | sed 's/sdlc-plan-//')"
    cur_in_progress="$domain"
    # Remove from pending if present
    cur_pending="$(echo "$cur_pending" | tr ' ' '\n' | grep -v "^${domain}$" | tr '\n' ' ')"
  fi

  # Handle completed — move domain from in_progress to done
  if [ -n "$completed" ]; then
    cur_in_progress=""
    if ! echo " $cur_done " | grep -q " $completed "; then
      cur_done="$cur_done $completed"
    fi
    # Remove from pending if still there
    cur_pending="$(echo "$cur_pending" | tr ' ' '\n' | grep -v "^${completed}$" | tr '\n' ' ')"
  fi

  # Handle story-done — clear story progress
  if [ -n "$story_done" ]; then
    cur_done=""
    cur_pending=""
    cur_in_progress=""
  fi

  cur_done="$(echo "$cur_done" | xargs)"
  cur_pending="$(echo "$cur_pending" | xargs)"
  cur_completed_phases="$(echo "$cur_completed_phases" | xargs)"

  # Generate resume hint
  local hint="Planning not started."
  if [ -n "$cur_phase" ] && [ -n "$cur_story" ]; then
    local next_agent=""
    if [ -n "$cur_in_progress" ]; then
      next_agent="$cur_in_progress in progress."
    elif [ -n "$cur_pending" ]; then
      next_agent="Next: dispatch $(echo "$cur_pending" | awk '{print $1}') agent."
    else
      next_agent="All agents complete for this story. Run per-story validation."
    fi
    hint="Phase ${cur_phase}, story ${cur_story}. Done: [${cur_done}]. ${next_agent}"
  elif [ -n "$cur_phase" ]; then
    hint="Phase ${cur_phase} active."
  fi

  # Format lists
  local done_yaml="[]"
  [ -n "$cur_done" ] && done_yaml="[$(echo "$cur_done" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
  local pending_yaml="[]"
  [ -n "$cur_pending" ] && pending_yaml="[$(echo "$cur_pending" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
  local completed_phases_yaml="[]"
  [ -n "$cur_completed_phases" ] && completed_phases_yaml="[$(echo "$cur_completed_phases" | tr ' ' '\n' | paste -sd, -)]"

  cat > "$file" <<EOF
last_updated: "${TIMESTAMP}"
phase: ${cur_phase:-null}
completed_phases: ${completed_phases_yaml}
total_stories: ${cur_total_stories:-null}
current_story: ${cur_story:-null}
agents_done: ${done_yaml}
agent_in_progress: ${cur_in_progress:-null}
agents_pending: ${pending_yaml}
last_dispatch: ${dispatch:-null}
last_completed: ${completed:-null}
resume_hint: "${hint}"
EOF

  # Build history detail
  local detail="phase:${cur_phase:-?}|story:${cur_story:-?}"
  [ -n "$dispatch" ] && detail="${detail}|dispatch:${dispatch}"
  [ -n "$completed" ] && detail="${detail}|completed:${completed}"
  [ -n "$story_done" ] && detail="${detail}|story-done:${story_done}"
  append_history "planning" "$detail"
}

# ---------------------------------------------------------------------------
# EXECUTION subcommand
# ---------------------------------------------------------------------------

cmd_execution() {
  local file="$SDLC_DIR/execution.yaml"
  ensure_sdlc_dir

  local story="" phase="" tasks_total="" task="" step="" iteration=""
  local task_done="" staging_doc=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --story) story="$2"; shift 2 ;;
      --phase) phase="$2"; shift 2 ;;
      --tasks-total) tasks_total="$2"; shift 2 ;;
      --task) task="$2"; shift 2 ;;
      --step) step="$2"; shift 2 ;;
      --iteration) iteration="$2"; shift 2 ;;
      --task-done) task_done="$2"; shift 2 ;;
      --staging-doc) staging_doc="$2"; shift 2 ;;
      *) echo "Unknown execution flag: $1" >&2; exit 1 ;;
    esac
  done

  # Read existing values
  local cur_story cur_phase cur_tasks_total cur_tasks_completed
  local cur_task_id cur_task_name cur_step cur_iteration cur_staging_doc
  cur_story="$(yaml_read "$file" "story")"
  cur_phase="$(yaml_read "$file" "phase")"
  cur_tasks_total="$(yaml_read "$file" "tasks_total")"
  cur_tasks_completed="$(yaml_read "$file" "tasks_completed")"
  cur_task_id="$(yaml_read "$file" "current_task_id")"
  cur_task_name="$(yaml_read "$file" "current_task_name")"
  cur_step="$(yaml_read "$file" "current_step")"
  cur_iteration="$(yaml_read "$file" "current_iteration")"
  cur_staging_doc="$(yaml_read "$file" "staging_doc")"
  local cur_completed_phases
  cur_completed_phases="$(yaml_read_list "$file" "completed_phases")"

  # Apply patches
  [ -n "$story" ] && cur_story="$story"
  [ -n "$staging_doc" ] && cur_staging_doc="$staging_doc"
  [ -n "$tasks_total" ] && cur_tasks_total="$tasks_total"

  if [ -n "$phase" ]; then
    if [ -n "$cur_phase" ] && [ "$cur_phase" != "$phase" ]; then
      if ! echo " $cur_completed_phases " | grep -q " $cur_phase "; then
        cur_completed_phases="$cur_completed_phases $cur_phase"
      fi
    fi
    cur_phase="$phase"
  fi

  # Parse task flag: "4:Implement session store"
  if [ -n "$task" ]; then
    cur_task_id="$(echo "$task" | cut -d: -f1)"
    cur_task_name="$(echo "$task" | cut -d: -f2-)"
  fi

  [ -n "$step" ] && cur_step="$step"
  [ -n "$iteration" ] && cur_iteration="$iteration"

  # Handle task-done — increment completed count
  if [ -n "$task_done" ]; then
    cur_tasks_completed=$(( ${cur_tasks_completed:-0} + 1 ))
    cur_task_id=""
    cur_task_name=""
    cur_step=""
    cur_iteration=""
  fi

  cur_completed_phases="$(echo "$cur_completed_phases" | xargs)"

  # Generate resume hint
  local hint="Execution not started."
  if [ -n "$cur_phase" ] && [ -n "$cur_task_name" ]; then
    hint="Phase ${cur_phase}, task ${cur_task_id} (${cur_task_name}), step: ${cur_step:-implement}. Staging: ${cur_staging_doc:-unknown}."
  elif [ -n "$cur_phase" ] && [ -n "$cur_story" ]; then
    hint="Phase ${cur_phase}, story ${cur_story}. ${cur_tasks_completed:-0}/${cur_tasks_total:-?} tasks done."
  fi

  local completed_phases_yaml="[]"
  [ -n "$cur_completed_phases" ] && completed_phases_yaml="[$(echo "$cur_completed_phases" | tr ' ' '\n' | paste -sd, -)]"

  cat > "$file" <<EOF
last_updated: "${TIMESTAMP}"
story: ${cur_story:-null}
staging_doc: ${cur_staging_doc:-null}
phase: ${cur_phase:-null}
completed_phases: ${completed_phases_yaml}
tasks_total: ${cur_tasks_total:-null}
tasks_completed: ${cur_tasks_completed:-0}
current_task_id: ${cur_task_id:-null}
current_task_name: ${cur_task_name:-null}
current_step: ${cur_step:-null}
current_iteration: ${cur_iteration:-null}
resume_hint: "${hint}"
EOF

  # Build history detail
  local detail="phase:${cur_phase:-?}|story:${cur_story:-?}"
  [ -n "$task" ] && detail="${detail}|task:${task}"
  [ -n "$step" ] && detail="${detail}|step:${step}"
  [ -n "$task_done" ] && detail="${detail}|task-done:${task_done}"
  append_history "execution" "$detail"
}

# ---------------------------------------------------------------------------
# INIT subcommand — derive state from existing artifacts
# ---------------------------------------------------------------------------

cmd_init() {
  ensure_sdlc_dir
  echo "Scanning existing artifacts to bootstrap checkpoint state..."

  local hub="null"
  local current_story="null"

  # Detect planning state
  if [ -d "plan" ]; then
    hub="planning"
    local planning_phase=0

    # Phase 1 check
    if [ -f "plan/prd.md" ]; then
      planning_phase=1
    fi

    # Phase 2 check
    if [ -f "plan/system-architecture.md" ]; then
      planning_phase=2
    fi

    # Phase 3 check — look for story folders and their artifacts
    local stories_dir="plan/user-stories"
    if [ -d "$stories_dir" ]; then
      local all_stories_planned=true
      local found_incomplete_story=""

      for story_dir in "$stories_dir"/*/; do
        [ -d "$story_dir" ] || continue
        local story_name
        story_name="$(basename "$story_dir")"
        local story_file="${story_dir}story.md"

        if [ ! -f "$story_file" ]; then
          continue
        fi

        # Check what artifacts exist for this story
        local has_hld=false has_api=false has_data=false has_security=false has_design=false
        [ -f "${story_dir}hld.md" ] && has_hld=true
        [ -f "${story_dir}api.md" ] && has_api=true
        [ -f "${story_dir}data.md" ] && has_data=true
        [ -f "${story_dir}security.md" ] && has_security=true
        [ -f "${story_dir}design/design.md" ] && has_design=true

        # HLD is always required; if missing, story is incomplete
        if [ "$has_hld" = false ]; then
          all_stories_planned=false
          if [ -z "$found_incomplete_story" ]; then
            found_incomplete_story="$story_name"
            planning_phase=3
          fi
        fi
      done

      if [ "$all_stories_planned" = true ]; then
        planning_phase=3
        # Check phase 4
        if [ -d "plan/cross-cutting" ]; then
          [ -f "plan/cross-cutting/security-overview.md" ] || [ -f "plan/cross-cutting/devops.md" ] || [ -f "plan/cross-cutting/testing-strategy.md" ] && planning_phase=4
        fi
        # Check phase 5
        if [ -d "plan/validation" ] && ls plan/validation/full-chain-* 2>/dev/null | head -1 > /dev/null 2>&1; then
          planning_phase=5
        fi
      fi

      [ -n "$found_incomplete_story" ] && current_story="$found_incomplete_story"
    fi

    # Write planning checkpoint
    cmd_planning --phase "$planning_phase" ${current_story:+--story "$current_story"}
  fi

  # Detect execution state
  if [ -d "docs/staging" ]; then
    local active_staging=""
    for staging_file in docs/staging/*.md; do
      [ -f "$staging_file" ] || continue
      [ "$(basename "$staging_file")" = "README.md" ] && continue
      # Check if this staging doc has incomplete tasks
      if grep -q "\- \[ \]" "$staging_file" 2>/dev/null; then
        active_staging="$staging_file"
        break
      fi
    done

    if [ -n "$active_staging" ]; then
      hub="execution"
      local exec_story
      exec_story="$(basename "$active_staging" .md)"
      local total
      total="$(grep -c "\- \[.\]" "$active_staging" 2>/dev/null || echo 0)"
      local done_count
      done_count="$(grep -c "\- \[x\]" "$active_staging" 2>/dev/null || echo 0)"

      cmd_execution --story "$exec_story" --phase 2 --tasks-total "$total" --staging-doc "$active_staging"
    fi
  fi

  # Write coordinator checkpoint
  cmd_coordinator --hub "${hub:-planning}" ${current_story:+--story "$current_story"}

  echo "Checkpoint initialized. State written to .sdlc/"
  echo "  coordinator.yaml: hub=${hub}"
  [ -n "$current_story" ] && echo "  current_story: ${current_story}"
}

# ---------------------------------------------------------------------------
# Main dispatch
# ---------------------------------------------------------------------------

if [ $# -lt 1 ]; then
  echo "Usage: checkpoint.sh <coordinator|planning|execution|init> [flags]" >&2
  exit 1
fi

SUBCMD="$1"
shift

case "$SUBCMD" in
  coordinator) cmd_coordinator "$@" ;;
  planning)    cmd_planning "$@" ;;
  execution)   cmd_execution "$@" ;;
  init)        cmd_init "$@" ;;
  *)           echo "Unknown subcommand: $SUBCMD" >&2; exit 1 ;;
esac
