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
#   checkpoint.sh dispatch-log [flags]
#   checkpoint.sh init
# =============================================================================

SDLC_DIR=".sdlc"
HISTORY_LOG="$SDLC_DIR/history.log"
DISPATCH_LOG="$SDLC_DIR/dispatch-log.jsonl"
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
    cur_remaining="$(echo "$cur_remaining" | sed 's/^ *//;s/ *$//;s/  */ /g')"
  fi

  cur_done="$(echo "$cur_done" | sed 's/^ *//;s/ *$//;s/  */ /g')"
  cur_remaining="$(echo "$cur_remaining" | sed 's/^ *//;s/ *$//;s/  */ /g')"

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

  cur_done="$(echo "$cur_done" | sed 's/^ *//;s/ *$//;s/  */ /g')"
  cur_pending="$(echo "$cur_pending" | sed 's/^ *//;s/ *$//;s/  */ /g')"
  cur_completed_phases="$(echo "$cur_completed_phases" | sed 's/^ *//;s/ *$//;s/  */ /g')"

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

  cur_completed_phases="$(echo "$cur_completed_phases" | sed 's/^ *//;s/ *$//;s/  */ /g')"

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
# CONTINUE subcommand — provide actionable resume instructions
# ---------------------------------------------------------------------------

cmd_continue() {
  local script_dir="$(dirname "$0")"
  local verify_script="$script_dir/verify.sh"
  
  if [ ! -f "$verify_script" ]; then
    echo "ERROR: verify.sh not found at $verify_script" >&2
    exit 1
  fi

  echo "SDLC Checkpoint Resume Instructions"
  echo "=================================="
  echo

  # Get coordinator state first
  local coord_output
  coord_output="$("$verify_script" 2>&1)"
  
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to read checkpoint state"
    echo "INSTRUCTION: Run 'checkpoint.sh init' to bootstrap from existing artifacts"
    return 1
  fi

  # Parse coordinator output
  local hub status recommendation
  hub="$(echo "$coord_output" | grep "^hub:" | cut -d' ' -f2- || echo "none")"
  status="$(echo "$coord_output" | grep "^status:" | cut -d' ' -f2- || echo "unknown")"
  recommendation="$(echo "$coord_output" | grep "^recommendation:" | cut -d' ' -f2- || echo "none")"

  case "$status" in
    "NO_CHECKPOINT"|"NO_CHECKPOINT_DIR")
      echo "Status: No checkpoint found"
      echo "INSTRUCTION: Run 'checkpoint.sh init' to scan existing artifacts and bootstrap state"
      echo "             OR start a new SDLC workflow from the beginning"
      return 0
      ;;
    "IDLE")
      echo "Status: No active work"
      echo "INSTRUCTION: Ask user what work to start, or check project status"
      return 0
      ;;
    "ACTIVE")
      ;;
    *)
      echo "Status: Unknown ($status)"
      echo "INSTRUCTION: Check .sdlc/ directory manually or re-run checkpoint.sh init"
      return 0
      ;;
  esac

  # Get detailed hub state
  if [ "$hub" != "none" ] && [ "$hub" != "null" ]; then
    echo "Status: ${hub^} Hub Active"
    
    # Get detailed verification
    local hub_output
    hub_output="$("$verify_script" "$hub" 2>&1)"
    
    if [ $? -eq 0 ]; then
      # Parse hub-specific output
      local phase story current_story tasks recommendation_detail
      phase="$(echo "$hub_output" | grep "^phase:" | cut -d' ' -f2- || echo "unknown")"
      story="$(echo "$hub_output" | grep "^story:" | cut -d' ' -f2- || echo "none")"
      current_story="$(echo "$coord_output" | grep "^current_story:" | cut -d' ' -f2- || echo "none")"
      tasks="$(echo "$hub_output" | grep "^tasks:" | cut -d' ' -f2- || echo "")"
      recommendation_detail="$(echo "$hub_output" | grep "^recommendation:" | cut -d' ' -f2- || echo "$recommendation")"

      echo "Phase: $phase"
      [ "$story" != "none" ] && echo "Story: $story"
      [ -n "$tasks" ] && echo "Tasks: $tasks"
      echo

      # Show verification details if available
      local verification_section=""
      if echo "$hub_output" | grep -q "^verification:"; then
        verification_section="$(echo "$hub_output" | sed -n '/^verification:/,/^recommendation:/p' | sed '$d')"
        if [ -n "$verification_section" ]; then
          echo "$verification_section"
          echo
        fi
      fi

      # Provide actionable instruction
      echo "INSTRUCTION: $recommendation_detail"
      echo

      # Convert recommendation to specific dispatch instructions
      if echo "$recommendation_detail" | grep -q "route to sdlc-planner"; then
        echo "Context: Load sdlc-checkpoint skill and run verify.sh planning for detailed planning state"
        echo "After routing: Planning hub will run verify.sh planning and act on specific agent dispatch"
        echo
        echo "READY TO EXECUTE: Use Task tool with subagent_type=\"generalPurpose\" and prompt:"
        echo "\"You are the SDLC Planning Hub. Load the sdlc-checkpoint skill immediately and run verify.sh planning to get current state, then follow the specific recommendation for dispatching planning agents.\""
      elif echo "$recommendation_detail" | grep -q "route to sdlc-architect"; then
        echo "Context: Load sdlc-checkpoint skill and run verify.sh execution for detailed execution state"
        echo "After routing: Execution hub will run verify.sh execution and act on specific task dispatch"
        echo
        echo "READY TO EXECUTE: Use Task tool with subagent_type=\"generalPurpose\" and prompt:"
        echo "\"You are the SDLC Execution Hub (Architect). Load the sdlc-checkpoint skill immediately and run verify.sh execution to get current state, then follow the specific recommendation for dispatching execution agents.\""
      elif echo "$recommendation_detail" | grep -q "dispatch sdlc-planner-"; then
        local agent_type
        agent_type="$(echo "$recommendation_detail" | sed -n 's/.*dispatch sdlc-planner-\([^ ]*\).*/\1/p')"
        local target_story
        target_story="$(echo "$recommendation_detail" | sed -n 's/.* for \([^ ]*\).*/\1/p')"
        echo "Context: ${agent_type^} planning agent needed for story $target_story"
        echo "After completion: Update checkpoint with 'checkpoint.sh planning --completed $agent_type'"
        echo
        echo "READY TO EXECUTE: Use Task tool with subagent_type=\"generalPurpose\" and prompt:"
        echo "\"You are the ${agent_type^} Planning agent for story $target_story. Load the sdlc-checkpoint skill and run verify.sh planning to get current context. Then proceed with ${agent_type} planning for this story.\""
      elif echo "$recommendation_detail" | grep -q "dispatch sdlc-implementer"; then
        local task_info
        task_info="$(echo "$recommendation_detail" | sed -n 's/.*dispatch sdlc-implementer for task \([^"]*\) "\([^"]*\)".*/\1 "\2"/p')"
        echo "Context: Implementation needed for task $task_info"
        echo "After completion: Update checkpoint accordingly"
        echo
        echo "READY TO EXECUTE: Use Task tool with subagent_type=\"generalPurpose\" and prompt:"
        echo "\"You are the SDLC Implementer for task $task_info. Load the sdlc-checkpoint skill and run verify.sh execution to get current context. Then proceed with implementation.\""
      elif echo "$recommendation_detail" | grep -q "dispatch.*validator"; then
        echo "Context: Validation step required"
        echo "After completion: Update checkpoint with next phase or story completion"
        echo
        echo "READY TO EXECUTE: Use Task tool with subagent_type=\"generalPurpose\" and prompt:"
        echo "\"You are the SDLC Validator. Load the sdlc-checkpoint skill and run verify.sh to get current context. Then proceed with validation according to the recommendation.\""
      else
        echo "Context: Custom action required - see recommendation above"
        echo "After action: Update checkpoint as appropriate"
        echo
        echo "READY TO EXECUTE: Review recommendation and take action accordingly"
      fi
    else
      echo "Status: Active but unable to get detailed state"
      echo "INSTRUCTION: $recommendation"
      echo "Context: Try running verify.sh $hub manually for more details"
    fi
  else
    echo "Status: No active hub"
    echo "INSTRUCTION: Ask user what work to start, or run checkpoint.sh init"
  fi
}

# ---------------------------------------------------------------------------
# DISPATCH-LOG subcommand — structured dispatch/response audit trail
# ---------------------------------------------------------------------------

json_escape() {
  local str="$1"
  str="${str//\\/\\\\}"
  str="${str//\"/\\\"}"
  str="${str//$'\n'/\\n}"
  str="${str//$'\r'/}"
  str="${str//$'\t'/\\t}"
  printf '%s' "$str"
}

cmd_dispatch_log() {
  ensure_sdlc_dir

  local event="" story="" hub="" phase="" task="" agent="" model_profile=""
  local dispatch_id="" iteration="" verdict="" duration="" summary=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --event)         event="$2"; shift 2 ;;
      --story)         story="$2"; shift 2 ;;
      --hub)           hub="$2"; shift 2 ;;
      --phase)         phase="$2"; shift 2 ;;
      --task)          task="$2"; shift 2 ;;
      --agent)         agent="$2"; shift 2 ;;
      --model-profile) model_profile="$2"; shift 2 ;;
      --dispatch-id)   dispatch_id="$2"; shift 2 ;;
      --iteration)     iteration="$2"; shift 2 ;;
      --verdict)       verdict="$2"; shift 2 ;;
      --duration)      duration="$2"; shift 2 ;;
      --summary)       summary="$2"; shift 2 ;;
      *) echo "Unknown dispatch-log flag: $1" >&2; exit 1 ;;
    esac
  done

  if [ -z "$event" ]; then
    echo "dispatch-log requires --event (dispatch|response)" >&2
    exit 1
  fi

  local json="{"
  json="$json\"timestamp\":\"${TIMESTAMP}\""
  json="$json,\"event\":\"$(json_escape "$event")\""

  [ -n "$dispatch_id" ]   && json="$json,\"dispatch_id\":\"$(json_escape "$dispatch_id")\""
  [ -n "$agent" ]         && json="$json,\"agent\":\"$(json_escape "$agent")\""

  if [ "$event" = "dispatch" ]; then
    [ -n "$story" ]         && json="$json,\"story\":\"$(json_escape "$story")\""
    [ -n "$hub" ]           && json="$json,\"hub\":\"$(json_escape "$hub")\""
    [ -n "$phase" ]         && json="$json,\"phase\":\"$(json_escape "$phase")\""
    [ -n "$task" ]          && json="$json,\"task\":\"$(json_escape "$task")\""
    [ -n "$model_profile" ] && json="$json,\"model_profile\":\"$(json_escape "$model_profile")\""
    [ -n "$iteration" ]     && json="$json,\"iteration\":${iteration}"
  fi

  if [ "$event" = "response" ]; then
    [ -n "$verdict" ]  && json="$json,\"verdict\":\"$(json_escape "$verdict")\""
    [ -n "$duration" ] && json="$json,\"duration_seconds\":${duration}"
    if [ -n "$summary" ]; then
      local excerpt
      excerpt="$(printf '%.200s' "$summary")"
      json="$json,\"summary_excerpt\":\"$(json_escape "$excerpt")\""
    fi
  fi

  json="$json}"

  echo "$json" >> "$DISPATCH_LOG"
  append_history "dispatch-log" "event:${event}|agent:${agent:-?}|id:${dispatch_id:-?}"
}

# ---------------------------------------------------------------------------
# Main dispatch
# ---------------------------------------------------------------------------

if [ $# -lt 1 ]; then
  echo "Usage: checkpoint.sh <coordinator|planning|execution|dispatch-log|init|continue> [flags]" >&2
  exit 1
fi

SUBCMD="$1"
shift

case "$SUBCMD" in
  coordinator)  cmd_coordinator "$@" ;;
  planning)     cmd_planning "$@" ;;
  execution)    cmd_execution "$@" ;;
  dispatch-log) cmd_dispatch_log "$@" ;;
  init)         cmd_init "$@" ;;
  continue)     cmd_continue "$@" ;;
  *)            echo "Unknown subcommand: $SUBCMD" >&2; exit 1 ;;
esac
