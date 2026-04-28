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
#   checkpoint.sh git [flags]
#   checkpoint.sh init
#   checkpoint.sh sync-planning
#
# Story Queue Management:
#   The 'sync-planning' subcommand is a standalone bootstrap tool that builds
#   the story queue from existing plan artifacts. Use it to:
#
#   • Bootstrap existing projects onto the new explicit story tracking system
#   • Repair checkpoint state after manual edits or crashes
#   • Verify story queue integrity at any time
#
#   It scans plan/user-stories/*/story.md files, extracts execution_order,
#   builds a sorted story_queue, detects completed stories (via hld.md presence),
#   and prints a human-readable status summary.
#
#   Example:
#     $ ./checkpoint.sh sync-planning
#     Story queue built from disk (12 stories):
#       1. US-001-scaffolding              [DONE]
#       2. US-002-local-persistence        [DONE]  
#       3. US-003-pwa-shell-baseline       [PENDING] <-- current
#       ...
#     Phase: 3 | Completed: 2/12 | Next: US-003-pwa-shell-baseline
#
#   Safe to run anytime — idempotent operation that only reads plan/ and
#   writes .sdlc/planning.yaml. No agent involvement required.
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

  local hub="" story="" story_done="" sync_flag=""
  local pause_after_flag="" clear_pause_after_flag=""
  local plan_change_open="" plan_change_close=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --hub) hub="$2"; shift 2 ;;
      --story) story="$2"; shift 2 ;;
      --story-done) story_done="$2"; shift 2 ;;
      --sync) sync_flag="true"; shift ;;
      --pause-after) pause_after_flag="$2"; shift 2 ;;
      --clear-pause-after) clear_pause_after_flag="true"; shift ;;
      --plan-change-open) plan_change_open="$2"; shift 2 ;;
      --plan-change-close) plan_change_close="$2"; shift 2 ;;
      *) echo "Unknown coordinator flag: $1" >&2; exit 1 ;;
    esac
  done

  # Read existing values (normalize "null" scalars to empty string for downstream checks)
  local cur_hub cur_story cur_done cur_remaining cur_pause_after cur_plan_changes
  cur_hub="$(yaml_read "$file" "active_hub")"
  cur_story="$(yaml_read "$file" "current_story")"
  cur_done="$(yaml_read_list "$file" "stories_done")"
  cur_remaining="$(yaml_read_list "$file" "stories_remaining")"
  cur_pause_after="$(yaml_read "$file" "pause_after")"
  cur_plan_changes="$(yaml_read_list "$file" "plan_changes")"
  [ "$cur_hub" = "null" ] && cur_hub=""
  [ "$cur_story" = "null" ] && cur_story=""
  [ "$cur_pause_after" = "null" ] && cur_pause_after=""

  # Apply patches
  [ -n "$hub" ] && cur_hub="$hub"
  [ -n "$story" ] && cur_story="$story"
  [ -n "$pause_after_flag" ] && cur_pause_after="$pause_after_flag"
  [ "$clear_pause_after_flag" = "true" ] && cur_pause_after=""

  # Plan-change index (P22 dispatch lock): flat list of open PC-NNN ids.
  if [ -n "$plan_change_open" ]; then
    if ! echo " $cur_plan_changes " | grep -q " $plan_change_open "; then
      cur_plan_changes="$cur_plan_changes $plan_change_open"
    fi
  fi
  if [ -n "$plan_change_close" ]; then
    cur_plan_changes="$({ echo "$cur_plan_changes" | tr ' ' '\n' | grep -v "^${plan_change_close}$" || true; } | tr '\n' ' ')"
  fi
  cur_plan_changes="$(echo "$cur_plan_changes" | sed 's/^ *//;s/ *$//;s/  */ /g')"

  # --sync: rebuild stories_remaining from disk (plan/user-stories/*/story.md)
  # sorted by execution_order, filtering out anything already in stories_done.
  # Idempotent — safe to run any number of times.
  if [ "$sync_flag" = "true" ]; then
    if [ -d "plan/user-stories" ]; then
      local sorted_names
      sorted_names="$(coordinator_build_sorted_story_names)"
      local rebuilt=""
      while IFS= read -r name; do
        [ -z "$name" ] && continue
        if ! echo " $cur_done " | grep -q " $name "; then
          rebuilt="${rebuilt}${name} "
        fi
      done <<< "$sorted_names"
      cur_remaining="$(echo "$rebuilt" | sed 's/^ *//;s/ *$//;s/  */ /g')"
      # Set current_story to the head of the queue if unset or stale
      if [ -n "$cur_remaining" ]; then
        local head_story
        head_story="$(echo "$cur_remaining" | awk '{print $1}')"
        if [ -z "$cur_story" ] || [ "$cur_story" = "null" ] \
            || ! echo " $cur_remaining " | grep -q " $cur_story "; then
          cur_story="$head_story"
        fi
      fi
    fi
  fi

  if [ -n "$story_done" ]; then
    # Add to done list if not already there
    if ! echo " $cur_done " | grep -q " $story_done "; then
      cur_done="$cur_done $story_done"
    fi
    # Remove from remaining list (|| true: grep exits 1 when all lines match the -v pattern)
    cur_remaining="$({ echo "$cur_remaining" | tr ' ' '\n' | grep -v "^${story_done}$" || true; } | tr '\n' ' ')"
    cur_remaining="$(echo "$cur_remaining" | sed 's/^ *//;s/ *$//;s/  */ /g')"

    # Re-sync from disk before advancing so newly-planned stories are picked up.
    if [ -d "plan/user-stories" ]; then
      local sorted_names_sd
      sorted_names_sd="$(coordinator_build_sorted_story_names)"
      local rebuilt_sd=""
      while IFS= read -r name; do
        [ -z "$name" ] && continue
        if ! echo " $cur_done " | grep -q " $name "; then
          rebuilt_sd="${rebuilt_sd}${name} "
        fi
      done <<< "$sorted_names_sd"
      cur_remaining="$(echo "$rebuilt_sd" | sed 's/^ *//;s/ *$//;s/  */ /g')"
    fi

    # Honor pause_after: if the just-completed story matches pause_after,
    # clear active_hub but preserve stories_remaining and pause_after.
    # verify.sh surfaces this as status: PAUSED.
    if [ -n "$cur_pause_after" ] && [ "$story_done" = "$cur_pause_after" ]; then
      cur_story=""
      cur_hub=""
    elif [ -n "$cur_remaining" ]; then
      # Auto-transition: advance to next story
      cur_story="$(echo "$cur_remaining" | awk '{print $1}')"
    else
      # Queue genuinely empty — go idle
      cur_story=""
      cur_hub=""
    fi
  fi

  # After --clear-pause-after (and any other state patch), if we now have an
  # active hub, a non-empty queue, and no current story, advance to the head.
  # This is how a paused coordinator resumes after the user clears pause_after.
  if [ -n "$cur_hub" ] && [ -n "$cur_remaining" ]; then
    if [ -z "$cur_story" ] || [ "$cur_story" = "null" ] \
        || ! echo " $cur_remaining " | grep -q " $cur_story "; then
      cur_story="$(echo "$cur_remaining" | awk '{print $1}')"
    fi
  fi

  cur_done="$(echo "$cur_done" | sed 's/^ *//;s/ *$//;s/  */ /g')"
  cur_remaining="$(echo "$cur_remaining" | sed 's/^ *//;s/ *$//;s/  */ /g')"

  # Generate resume hint
  local hint="No active work."
  if [ -n "$cur_hub" ] && [ -n "$cur_story" ]; then
    hint="${cur_hub^} active, story ${cur_story}. Route to sdlc-$([ "$cur_hub" = "planning" ] && echo "planner" || echo "architect")."
  elif [ -n "$cur_hub" ]; then
    hint="${cur_hub^} active. Route to sdlc-$([ "$cur_hub" = "planning" ] && echo "planner" || echo "architect")."
  elif [ -n "$cur_pause_after" ] && [ -n "$cur_remaining" ]; then
    hint="Paused after ${cur_pause_after}. Stories remain: ${cur_remaining}. Clear pause_after to resume."
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
  local plan_changes_yaml="[]"
  if [ -n "$cur_plan_changes" ]; then
    plan_changes_yaml="[$(echo "$cur_plan_changes" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
  fi

  cat > "$file" <<EOF
last_updated: "${TIMESTAMP}"
active_hub: ${cur_hub:-null}
current_story: ${cur_story:-null}
stories_done: ${done_yaml}
stories_remaining: ${remaining_yaml}
pause_after: ${cur_pause_after:-null}
plan_changes: ${plan_changes_yaml}
resume_hint: "${hint}"
EOF

  local detail="hub:${cur_hub:-none}|story:${cur_story:-none}"
  [ -n "$story_done" ] && detail="story-done:${story_done}"
  [ "$sync_flag" = "true" ] && detail="${detail}|sync"
  [ -n "$pause_after_flag" ] && detail="${detail}|pause-after:${pause_after_flag}"
  [ "$clear_pause_after_flag" = "true" ] && detail="${detail}|clear-pause-after"
  [ -n "$plan_change_open" ] && detail="${detail}|plan-change-open:${plan_change_open}"
  [ -n "$plan_change_close" ] && detail="${detail}|plan-change-close:${plan_change_close}"
  append_history "coordinator" "$detail"
}

# Emit newline-separated story directory names from plan/user-stories/
# sorted by `execution_order` (ascending). Stories missing the field default
# to 999, effectively sent to the tail in alphabetical order.
# Used by cmd_coordinator --sync and --story-done to rebuild stories_remaining.
coordinator_build_sorted_story_names() {
  local queue_raw=""
  for story_file in plan/user-stories/*/story.md; do
    [ -f "$story_file" ] || continue
    local dir_name order
    dir_name="$(basename "$(dirname "$story_file")")"
    order="$(grep '^- execution_order:' "$story_file" 2>/dev/null | sed 's/.*: *//' | tr -d ' ')"
    [ -z "$order" ] && order="999"
    queue_raw="${queue_raw}${order} ${dir_name}"$'\n'
  done
  printf '%s' "$queue_raw" | sort -n -k1 -s | awk 'NF{print $2}'
}

# ---------------------------------------------------------------------------
# Story queue helper — builds ordered queue from plan/user-stories/*/story.md
# Used by --build-queue flag, sync-planning subcommand, and cmd_init.
# ---------------------------------------------------------------------------

build_story_queue() {
  local file="$SDLC_DIR/planning.yaml"
  local queue_raw=""

  for story_file in plan/user-stories/*/story.md; do
    [ -f "$story_file" ] || continue
    local dir_name order
    dir_name="$(basename "$(dirname "$story_file")")"
    order="$(grep '^- execution_order:' "$story_file" 2>/dev/null | sed 's/.*: *//' | tr -d ' ')"
    [ -z "$order" ] && order="999"
    queue_raw="${queue_raw}${order} ${dir_name}"$'\n'
  done

  local sorted_names
  sorted_names="$(printf '%s' "$queue_raw" | sort -n -k1 -s | awk 'NF{print $2}')"

  local count=0
  local queue_yaml=""
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    [ -n "$queue_yaml" ] && queue_yaml="${queue_yaml},"
    queue_yaml="${queue_yaml}\"${name}\""
    count=$((count + 1))
  done <<< "$sorted_names"

  # Write story_queue and total_stories into the existing YAML
  # These are read back by cmd_planning on subsequent calls
  local cur_story_queue="[${queue_yaml}]"
  local cur_total_stories="$count"

  # Read existing stories_completed or default to empty
  local cur_stories_completed
  cur_stories_completed="$(yaml_read_list "$file" "stories_completed")"

  # Persist queue fields by re-reading and rewriting the full file
  local cur_phase cur_story cur_done cur_pending cur_in_progress
  local cur_completed_phases cur_last_dispatch cur_last_completed
  cur_phase="$(yaml_read "$file" "phase")"
  cur_story="$(yaml_read "$file" "current_story")"
  cur_done="$(yaml_read_list "$file" "agents_done")"
  cur_pending="$(yaml_read_list "$file" "agents_pending")"
  cur_in_progress="$(yaml_read "$file" "agent_in_progress")"
  cur_completed_phases="$(yaml_read_list "$file" "completed_phases")"
  cur_last_dispatch="$(yaml_read "$file" "last_dispatch")"
  cur_last_completed="$(yaml_read "$file" "last_completed")"

  # Format existing lists back to YAML
  local done_yaml="[]"
  [ -n "$cur_done" ] && done_yaml="[$(echo "$cur_done" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
  local pending_yaml="[]"
  [ -n "$cur_pending" ] && pending_yaml="[$(echo "$cur_pending" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
  local completed_phases_yaml="[]"
  [ -n "$cur_completed_phases" ] && completed_phases_yaml="[$(echo "$cur_completed_phases" | tr ' ' '\n' | paste -sd, -)]"
  local stories_completed_yaml="[]"
  [ -n "$cur_stories_completed" ] && stories_completed_yaml="[$(echo "$cur_stories_completed" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"

  # Derive current_story from queue if not set
  if [ -z "$cur_story" ] || [ "$cur_story" = "null" ]; then
    cur_story="$(next_story_from_queue "$sorted_names" "$cur_stories_completed")"
  fi

  local hint
  hint="$(build_planning_hint "$cur_phase" "$cur_story" "$cur_done" "$cur_in_progress" "$cur_pending" "$cur_total_stories" "$cur_stories_completed")"

  cat > "$file" <<EOF
last_updated: "${TIMESTAMP}"
phase: ${cur_phase:-null}
completed_phases: ${completed_phases_yaml}
total_stories: ${cur_total_stories:-null}
current_story: ${cur_story:-null}
story_queue: ${cur_story_queue}
stories_completed: ${stories_completed_yaml}
agents_done: ${done_yaml}
agent_in_progress: ${cur_in_progress:-null}
agents_pending: ${pending_yaml}
last_dispatch: ${cur_last_dispatch:-null}
last_completed: ${cur_last_completed:-null}
resume_hint: "${hint}"
EOF

  append_history "planning" "build-queue:${count}-stories"
}

# Returns the next unplanned story from queue, or empty string if all done.
next_story_from_queue() {
  local sorted_names="$1"
  local completed="$2"
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    if ! echo " $completed " | grep -q " $name "; then
      echo "$name"
      return
    fi
  done <<< "$sorted_names"
  echo ""
}

# Generates a resume hint string for planning.yaml
build_planning_hint() {
  local phase="$1" story="$2" done="$3" in_progress="$4" pending="$5"
  local total="$6" completed_list="$7"

  local hint="Planning not started."
  if [ -n "$phase" ] && [ "$phase" != "null" ] && [ -n "$story" ] && [ "$story" != "null" ]; then
    local next_agent=""
    if [ -n "$in_progress" ] && [ "$in_progress" != "null" ]; then
      next_agent="$in_progress in progress."
    elif [ -n "$pending" ]; then
      next_agent="Next: dispatch $(echo "$pending" | awk '{print $1}') agent."
    else
      next_agent="All agents complete for this story. Run per-story validation."
    fi
    local completed_count=0
    if [ -n "$completed_list" ]; then
      completed_count="$(echo "$completed_list" | wc -w | tr -d ' ')"
    fi
    if [ -n "$total" ] && [ "$total" != "null" ]; then
      hint="Phase ${phase}, story ${story} (${completed_count}/${total} done). Done: [${done}]. ${next_agent}"
    else
      hint="Phase ${phase}, story ${story}. Done: [${done}]. ${next_agent}"
    fi
  elif [ -n "$phase" ] && [ "$phase" != "null" ]; then
    hint="Phase ${phase} active."
  fi
  echo "$hint"
}

# ---------------------------------------------------------------------------
# PLANNING subcommand
# ---------------------------------------------------------------------------

cmd_planning() {
  local file="$SDLC_DIR/planning.yaml"
  ensure_sdlc_dir

  local phase="" story="" agents_done="" agents_pending=""
  local dispatch="" completed="" story_done="" build_queue=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --phase) phase="$2"; shift 2 ;;
      --story) story="$2"; shift 2 ;;
      --agents-done) agents_done="$2"; shift 2 ;;
      --agents-pending) agents_pending="$2"; shift 2 ;;
      --dispatch) dispatch="$2"; shift 2 ;;
      --completed) completed="$2"; shift 2 ;;
      --story-done) story_done="$2"; shift 2 ;;
      --build-queue) build_queue="true"; shift ;;
      *) echo "Unknown planning flag: $1" >&2; exit 1 ;;
    esac
  done

  # Handle --build-queue: scan disk and write story_queue, then return
  if [ "$build_queue" = "true" ]; then
    build_story_queue
    return
  fi

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
  local cur_story_queue cur_stories_completed
  cur_story_queue="$(yaml_read "$file" "story_queue")"
  cur_stories_completed="$(yaml_read_list "$file" "stories_completed")"

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

  # Handle story-done — add to stories_completed and auto-advance
  if [ -n "$story_done" ]; then
    cur_done=""
    cur_pending=""
    cur_in_progress=""
    # Add to stories_completed if not already there
    if ! echo " $cur_stories_completed " | grep -q " $story_done "; then
      cur_stories_completed="$cur_stories_completed $story_done"
    fi
    cur_stories_completed="$(echo "$cur_stories_completed" | sed 's/^ *//;s/ *$//;s/  */ /g')"
    # Auto-advance current_story from queue
    local queue_names
    queue_names="$(echo "$cur_story_queue" | sed 's/^\[//;s/\]$//;s/,/ /g' | tr -d '"' | tr -d "'")"
    cur_story=""
    for qname in $queue_names; do
      if ! echo " $cur_stories_completed " | grep -q " $qname "; then
        cur_story="$qname"
        break
      fi
    done
  fi

  cur_done="$(echo "$cur_done" | sed 's/^ *//;s/ *$//;s/  */ /g')"
  cur_pending="$(echo "$cur_pending" | sed 's/^ *//;s/ *$//;s/  */ /g')"
  cur_completed_phases="$(echo "$cur_completed_phases" | sed 's/^ *//;s/ *$//;s/  */ /g')"

  # Generate resume hint
  local hint
  hint="$(build_planning_hint "$cur_phase" "$cur_story" "$cur_done" "$cur_in_progress" "$cur_pending" "$cur_total_stories" "$cur_stories_completed")"

  # Format lists
  local done_yaml="[]"
  [ -n "$cur_done" ] && done_yaml="[$(echo "$cur_done" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
  local pending_yaml="[]"
  [ -n "$cur_pending" ] && pending_yaml="[$(echo "$cur_pending" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
  local completed_phases_yaml="[]"
  [ -n "$cur_completed_phases" ] && completed_phases_yaml="[$(echo "$cur_completed_phases" | tr ' ' '\n' | paste -sd, -)]"
  local stories_completed_yaml="[]"
  [ -n "$cur_stories_completed" ] && stories_completed_yaml="[$(echo "$cur_stories_completed" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"

  # Preserve story_queue if it exists; use raw value from file
  local story_queue_yaml="${cur_story_queue:-[]}"

  cat > "$file" <<EOF
last_updated: "${TIMESTAMP}"
phase: ${cur_phase:-null}
completed_phases: ${completed_phases_yaml}
total_stories: ${cur_total_stories:-null}
current_story: ${cur_story:-null}
story_queue: ${story_queue_yaml}
stories_completed: ${stories_completed_yaml}
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
  local task_done="" staging_doc="" status=""
  # Compound dispatch-log flags (optional — writes dispatch-log.jsonl entry alongside state)
  local d_event="" d_agent="" d_dispatch_id="" d_model="" d_verdict="" d_duration="" d_summary=""
  # Oracle-escalation compound dispatch-log fields
  local d_counters="" d_scope="" d_decline=""
  # Compound commit flag (optional — stages + commits after state update)
  local do_commit_flag=""

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
      --status) status="$2"; shift 2 ;;
      --dispatch-event)   d_event="$2"; shift 2 ;;
      --dispatch-agent)   d_agent="$2"; shift 2 ;;
      --dispatch-id)      d_dispatch_id="$2"; shift 2 ;;
      --dispatch-model)   d_model="$2"; shift 2 ;;
      --dispatch-verdict) d_verdict="$2"; shift 2 ;;
      --dispatch-duration) d_duration="$2"; shift 2 ;;
      --dispatch-summary) d_summary="$2"; shift 2 ;;
      --dispatch-counters)        d_counters="$2"; shift 2 ;;
      --dispatch-scope)           d_scope="$2"; shift 2 ;;
      --dispatch-decline-reason)  d_decline="$2"; shift 2 ;;
      --commit) do_commit_flag="true"; shift ;;
      *) echo "Unknown execution flag: $1" >&2; exit 1 ;;
    esac
  done

  # Oracle-escalation validation: --dispatch-counters must be a JSON object, --dispatch-scope must be a JSON array.
  if [ -n "$d_counters" ] && [ "${d_counters:0:1}" != "{" ]; then
    echo "execution --dispatch-counters must be a JSON object (e.g. '{\"doc_queries\":9}')" >&2
    exit 1
  fi
  if [ -n "$d_scope" ] && [ "${d_scope:0:1}" != "[" ]; then
    echo "execution --dispatch-scope must be a JSON array (e.g. '[\"src/foo.ts\"]')" >&2
    exit 1
  fi

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
  local cur_completed_phases cur_status
  cur_completed_phases="$(yaml_read_list "$file" "completed_phases")"
  cur_status="$(yaml_read "$file" "status")"

  # Apply patches
  [ -n "$status" ] && cur_status="$status"
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

  # Handle task-done — increment completed count (capped at tasks_total)
  if [ -n "$task_done" ]; then
    cur_tasks_completed=$(( ${cur_tasks_completed:-0} + 1 ))
    if [ -n "$cur_tasks_total" ] && [ "$cur_tasks_completed" -gt "$cur_tasks_total" ] 2>/dev/null; then
      cur_tasks_completed="$cur_tasks_total"
    fi
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
status: ${cur_status:-IN_PROGRESS}
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
  [ -n "$status" ] && detail="${detail}|status:${status}"
  append_history "execution" "$detail"

  # --- Compound dispatch-log (optional) ---
  if [ -n "$d_event" ]; then
    build_and_append_dispatch_json "$d_event" "$d_agent" "$d_dispatch_id" \
      "${cur_story:-}" "execution" "${cur_phase:-}" "${task:-}" \
      "$d_model" "${iteration:-}" "$d_verdict" "$d_duration" "$d_summary" \
      "$d_counters" "$d_scope" "$d_decline"
  fi

  # --- Compound commit (optional) ---
  if [ "$do_commit_flag" = "true" ]; then
    do_commit "${cur_story:-}" "${task:-}" "" "${cur_phase:-}"
  fi
}

# ---------------------------------------------------------------------------
# GIT subcommand — branch lifecycle operations
# ---------------------------------------------------------------------------

cmd_git() {
  local exec_file="$SDLC_DIR/execution.yaml"
  ensure_sdlc_dir

  local branch_create="" commit="" merge=""
  local story="" base="main" task="" message="" phase="" target="main"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch-create) branch_create="true"; shift ;;
      --commit)        commit="true"; shift ;;
      --merge)         merge="true"; shift ;;
      --story)         story="$2"; shift 2 ;;
      --base)          base="$2"; shift 2 ;;
      --task)          task="$2"; shift 2 ;;
      --message)       message="$2"; shift 2 ;;
      --phase)         phase="$2"; shift 2 ;;
      --target)        target="$2"; shift 2 ;;
      *) echo "Unknown git flag: $1" >&2; exit 1 ;;
    esac
  done

  # Exactly one operation must be specified
  local op_count=0
  [ "$branch_create" = "true" ] && op_count=$((op_count + 1))
  [ "$commit" = "true" ] && op_count=$((op_count + 1))
  [ "$merge" = "true" ] && op_count=$((op_count + 1))
  if [ "$op_count" -ne 1 ]; then
    echo "git subcommand requires exactly one of --branch-create, --commit, --merge" >&2
    exit 1
  fi

  # --- BRANCH CREATE ---
  if [ "$branch_create" = "true" ]; then
    if [ -z "$story" ]; then
      echo "git --branch-create requires --story" >&2
      exit 1
    fi

    local branch_name="story/${story}"

    # Check if branch already exists (resume scenario)
    if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
      echo "Branch ${branch_name} already exists — checking out for resume"
      git checkout "$branch_name"
    else
      # Ensure we're on the base branch
      git checkout "$base"
      git checkout -b "$branch_name"
    fi

    local base_commit
    base_commit="$(git rev-parse "$base")"

    # Write branch metadata to execution.yaml
    if [ -f "$exec_file" ]; then
      # Remove existing branch fields if present, then append
      local tmpfile="${exec_file}.tmp"
      grep -v "^branch_name:" "$exec_file" | grep -v "^base_branch:" | grep -v "^base_commit:" > "$tmpfile" || true
      {
        cat "$tmpfile"
        echo "branch_name: ${branch_name}"
        echo "base_branch: ${base}"
        echo "base_commit: ${base_commit}"
      } > "$exec_file"
      rm -f "$tmpfile"
    else
      cat > "$exec_file" <<EOF
last_updated: "${TIMESTAMP}"
story: ${story}
branch_name: ${branch_name}
base_branch: ${base}
base_commit: ${base_commit}
phase: null
EOF
    fi

    append_history "git" "branch-create:${branch_name}|base:${base}|base_commit:${base_commit}"
    echo "Created branch ${branch_name} from ${base} (${base_commit})"
    return
  fi

  # --- COMMIT ---
  if [ "$commit" = "true" ]; then
    do_commit "$story" "$task" "$message" "$phase"
    return
  fi

  # --- MERGE ---
  if [ "$merge" = "true" ]; then
    if [ -z "$story" ]; then
      echo "git --merge requires --story" >&2
      exit 1
    fi

    local branch_name="story/${story}"

    # Stash any dirty checkpoint state (e.g. .sdlc/history.log) before switching branches
    local stashed=false
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
      git stash push -m "checkpoint-merge-autostash" -- . 2>/dev/null && stashed=true
    fi

    # Switch to target branch and merge
    git checkout "$target"
    git merge --no-ff "$branch_name" -m "merge(${story}): integrate story branch into ${target}"

    # Delete story branch
    git branch -d "$branch_name"

    # Restore stashed checkpoint state if we stashed earlier
    if [ "$stashed" = true ]; then
      git stash pop 2>/dev/null || true
    fi

    # Clear branch fields from execution.yaml
    if [ -f "$exec_file" ]; then
      local tmpfile="${exec_file}.tmp"
      grep -v "^branch_name:" "$exec_file" | grep -v "^base_branch:" | grep -v "^base_commit:" > "$tmpfile" || true
      mv "$tmpfile" "$exec_file"
    fi

    append_history "git" "merge:${branch_name}|target:${target}"
    echo "Merged ${branch_name} into ${target} and deleted branch"
    return
  fi
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

    # Build story queue from disk if user-stories exist
    if [ -d "plan/user-stories" ]; then
      build_story_queue
    fi
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

  # Sync stories_remaining from plan/user-stories/ into coordinator.yaml.
  # This replaces the legacy sync-coordinator.sh lookup.
  if [ -d "plan/user-stories" ]; then
    cmd_coordinator --sync
  fi

  echo "Checkpoint initialized. State written to .sdlc/"
  echo "  coordinator.yaml: hub=${hub}"
  [ -n "$current_story" ] && echo "  current_story: ${current_story}"
}

# ---------------------------------------------------------------------------
# SYNC-PLANNING subcommand — standalone bootstrap for story queue
# ---------------------------------------------------------------------------

cmd_sync_planning() {
  local file="$SDLC_DIR/planning.yaml"
  ensure_sdlc_dir

  if [ ! -d "plan/user-stories" ]; then
    echo "No plan/user-stories/ directory found. Nothing to sync." >&2
    exit 1
  fi

  # Build the ordered story queue from disk
  build_story_queue

  # Scan for completed stories (hld.md present = completed)
  local stories_completed=""
  local queue_raw
  queue_raw="$(yaml_read "$file" "story_queue")"
  local queue_names
  queue_names="$(echo "$queue_raw" | sed 's/^\[//;s/\]$//;s/,/ /g' | tr -d '"' | tr -d "'")"

  for qname in $queue_names; do
    [ -z "$qname" ] && continue
    if [ -f "plan/user-stories/${qname}/hld.md" ]; then
      stories_completed="${stories_completed} ${qname}"
    fi
  done
  stories_completed="$(echo "$stories_completed" | sed 's/^ *//;s/ *$//;s/  */ /g')"

  # Write stories_completed and derive current_story
  local cur_story=""
  for qname in $queue_names; do
    [ -z "$qname" ] && continue
    if ! echo " $stories_completed " | grep -q " $qname "; then
      cur_story="$qname"
      break
    fi
  done

  # Update planning.yaml with completed stories and current_story
  local stories_completed_yaml="[]"
  [ -n "$stories_completed" ] && stories_completed_yaml="[$(echo "$stories_completed" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"

  # Re-read full state to preserve other fields
  local cur_phase cur_done cur_pending cur_in_progress
  local cur_completed_phases cur_total_stories cur_last_dispatch cur_last_completed
  cur_phase="$(yaml_read "$file" "phase")"
  cur_done="$(yaml_read_list "$file" "agents_done")"
  cur_pending="$(yaml_read_list "$file" "agents_pending")"
  cur_in_progress="$(yaml_read "$file" "agent_in_progress")"
  cur_completed_phases="$(yaml_read_list "$file" "completed_phases")"
  cur_total_stories="$(yaml_read "$file" "total_stories")"
  cur_last_dispatch="$(yaml_read "$file" "last_dispatch")"
  cur_last_completed="$(yaml_read "$file" "last_completed")"

  # Detect phase if not set
  if [ -z "$cur_phase" ] || [ "$cur_phase" = "null" ]; then
    cur_phase=3
  fi

  # Format lists
  local done_yaml="[]"
  [ -n "$cur_done" ] && done_yaml="[$(echo "$cur_done" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
  local pending_yaml="[]"
  [ -n "$cur_pending" ] && pending_yaml="[$(echo "$cur_pending" | tr ' ' '\n' | sed 's/.*/"&"/' | paste -sd, -)]"
  local completed_phases_yaml="[]"
  [ -n "$cur_completed_phases" ] && completed_phases_yaml="[$(echo "$cur_completed_phases" | tr ' ' '\n' | paste -sd, -)]"

  local hint
  hint="$(build_planning_hint "$cur_phase" "$cur_story" "$cur_done" "$cur_in_progress" "$cur_pending" "$cur_total_stories" "$stories_completed")"

  # Re-read story_queue (was just written by build_story_queue)
  local story_queue_yaml
  story_queue_yaml="$(yaml_read "$file" "story_queue")"

  cat > "$file" <<EOF
last_updated: "${TIMESTAMP}"
phase: ${cur_phase:-null}
completed_phases: ${completed_phases_yaml}
total_stories: ${cur_total_stories:-null}
current_story: ${cur_story:-null}
story_queue: ${story_queue_yaml:-[]}
stories_completed: ${stories_completed_yaml}
agents_done: ${done_yaml}
agent_in_progress: ${cur_in_progress:-null}
agents_pending: ${pending_yaml}
last_dispatch: ${cur_last_dispatch:-null}
last_completed: ${cur_last_completed:-null}
resume_hint: "${hint}"
EOF

  append_history "planning" "sync-planning"

  # Print human-readable summary
  local completed_count=0
  [ -n "$stories_completed" ] && completed_count="$(echo "$stories_completed" | wc -w | tr -d ' ')"
  local total_count="${cur_total_stories:-0}"

  echo "Story queue built from disk (${total_count} stories):"
  local idx=0
  for qname in $queue_names; do
    [ -z "$qname" ] && continue
    idx=$((idx + 1))
    local status_label="PENDING"
    if echo " $stories_completed " | grep -q " $qname "; then
      status_label="DONE"
    fi
    local marker=""
    [ "$qname" = "$cur_story" ] && marker=" <-- current"
    printf "  %2d. %-35s [%s]%s\n" "$idx" "$qname" "$status_label" "$marker"
  done
  echo "Phase: ${cur_phase:-?} | Completed: ${completed_count}/${total_count} | Next: ${cur_story:-none}"
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

# ---------------------------------------------------------------------------
# Shared helpers — used by both standalone subcommands and compound execution
# ---------------------------------------------------------------------------

# Build a dispatch-log JSON entry and append to dispatch-log.jsonl.
# Args: event agent dispatch_id [story hub phase task model_profile iteration verdict duration summary
#                                counters_json scope_json decline_reason]
#
# Oracle-escalation extension:
# - counters_json: raw JSON object string (e.g. '{"doc_queries":9,"implementer_attempts":2,"reviewer_iterations":3}').
#   Embedded as "counters":<raw>. Must start with '{' or it is silently ignored.
# - scope_json: raw JSON array string (e.g. '["src/foo.ts","src/bar.ts"]').
#   Embedded as "scope":<raw>. Must start with '[' or it is silently ignored.
# - decline_reason: regular string. Embedded as "decline_reason":"<escaped>".
#   Used when an escalation trigger fired but the hub elected NOT to dispatch Oracle (no subagent run occurs).
build_and_append_dispatch_json() {
  local d_event="$1" d_agent="$2" d_dispatch_id="$3"
  local d_story="${4:-}" d_hub="${5:-}" d_phase="${6:-}" d_task="${7:-}"
  local d_model="${8:-}" d_iteration="${9:-}" d_verdict="${10:-}"
  local d_duration="${11:-}" d_summary="${12:-}"
  local d_counters="${13:-}" d_scope="${14:-}" d_decline="${15:-}"

  local json="{"
  json="$json\"timestamp\":\"${TIMESTAMP}\""
  json="$json,\"event\":\"$(json_escape "$d_event")\""

  [ -n "$d_dispatch_id" ] && json="$json,\"dispatch_id\":\"$(json_escape "$d_dispatch_id")\""
  [ -n "$d_agent" ]       && json="$json,\"agent\":\"$(json_escape "$d_agent")\""

  if [ "$d_event" = "dispatch" ]; then
    [ -n "$d_story" ]  && json="$json,\"story\":\"$(json_escape "$d_story")\""
    [ -n "$d_hub" ]    && json="$json,\"hub\":\"$(json_escape "$d_hub")\""
    [ -n "$d_phase" ]  && json="$json,\"phase\":\"$(json_escape "$d_phase")\""
    [ -n "$d_task" ]   && json="$json,\"task\":\"$(json_escape "$d_task")\""
    [ -n "$d_model" ]  && json="$json,\"model_profile\":\"$(json_escape "$d_model")\""
    [ -n "$d_iteration" ] && json="$json,\"iteration\":${d_iteration}"

    # Oracle-escalation dispatch metadata. Embedded raw (caller is responsible for valid JSON).
    if [ -n "$d_counters" ] && [ "${d_counters:0:1}" = "{" ]; then
      json="$json,\"counters\":${d_counters}"
    fi
    if [ -n "$d_scope" ] && [ "${d_scope:0:1}" = "[" ]; then
      json="$json,\"scope\":${d_scope}"
    fi
    if [ -n "$d_decline" ]; then
      json="$json,\"decline_reason\":\"$(json_escape "$d_decline")\""
    fi
  fi

  if [ "$d_event" = "response" ]; then
    [ -n "$d_verdict" ]  && json="$json,\"verdict\":\"$(json_escape "$d_verdict")\""
    [ -n "$d_duration" ] && json="$json,\"duration_seconds\":${d_duration}"
    if [ -n "$d_summary" ]; then
      local excerpt
      excerpt="$(printf '%.200s' "$d_summary")"
      json="$json,\"summary_excerpt\":\"$(json_escape "$excerpt")\""
    fi
  fi

  json="$json}"

  echo "$json" >> "$DISPATCH_LOG"
  append_history "dispatch-log" "event:${d_event}|agent:${d_agent:-?}|id:${d_dispatch_id:-?}"
}

# Stage all changes and commit with an auto-generated message.
# Args: story [task] [message] [phase]
# task format: "id:name" — if provided, generates task() prefix.
# message — if provided (and no task), generates docs() or fix() prefix.
# Falls back to chore() prefix.
do_commit() {
  local c_story="$1" c_task="${2:-}" c_message="${3:-}" c_phase="${4:-}"

  local commit_msg=""
  if [ -n "$c_task" ]; then
    local task_id task_name
    task_id="$(echo "$c_task" | cut -d: -f1)"
    task_name="$(echo "$c_task" | cut -d: -f2-)"
    commit_msg="task(${c_story}/${task_id}): ${task_name}"
  elif [ -n "$c_message" ]; then
    if echo "$c_message" | grep -qi "staging doc\|documentation\|doc integration"; then
      commit_msg="docs(${c_story}): ${c_message}"
    else
      commit_msg="fix(${c_story}): ${c_message}"
    fi
  else
    commit_msg="chore(${c_story}): checkpoint commit (phase ${c_phase:-unknown})"
  fi

  git add -A
  if git diff --cached --quiet 2>/dev/null; then
    echo "No changes to commit"
    append_history "git" "commit-skip:no-changes|phase:${c_phase:-?}"
    return
  fi
  git commit -m "$commit_msg"

  append_history "git" "commit:${commit_msg}|phase:${c_phase:-?}"
  echo "Committed: ${commit_msg}"
}

# ---------------------------------------------------------------------------
# DISPATCH-LOG subcommand — structured dispatch/response audit trail
# ---------------------------------------------------------------------------

cmd_dispatch_log() {
  ensure_sdlc_dir

  local event="" story="" hub="" phase="" task="" agent="" model_profile=""
  local dispatch_id="" iteration="" verdict="" duration="" summary=""
  # Oracle-escalation fields
  local counters="" scope="" decline_reason=""

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
      --counters)        counters="$2"; shift 2 ;;
      --scope)           scope="$2"; shift 2 ;;
      --decline-reason)  decline_reason="$2"; shift 2 ;;
      *) echo "Unknown dispatch-log flag: $1" >&2; exit 1 ;;
    esac
  done

  if [ -z "$event" ]; then
    echo "dispatch-log requires --event (dispatch|response)" >&2
    exit 1
  fi

  # Oracle-escalation validation: --counters must be a JSON object, --scope must be a JSON array.
  if [ -n "$counters" ] && [ "${counters:0:1}" != "{" ]; then
    echo "dispatch-log --counters must be a JSON object (e.g. '{\"doc_queries\":9}')" >&2
    exit 1
  fi
  if [ -n "$scope" ] && [ "${scope:0:1}" != "[" ]; then
    echo "dispatch-log --scope must be a JSON array (e.g. '[\"src/foo.ts\"]')" >&2
    exit 1
  fi

  build_and_append_dispatch_json "$event" "$agent" "$dispatch_id" \
    "$story" "$hub" "$phase" "$task" "$model_profile" "$iteration" \
    "$verdict" "$duration" "$summary" \
    "$counters" "$scope" "$decline_reason"
}

# ---------------------------------------------------------------------------
# Main dispatch
# ---------------------------------------------------------------------------

if [ $# -lt 1 ]; then
  echo "Usage: checkpoint.sh <coordinator|planning|execution|dispatch-log|git|init|continue> [flags]" >&2
  exit 1
fi

SUBCMD="$1"
shift

case "$SUBCMD" in
  coordinator)     cmd_coordinator "$@" ;;
  planning)        cmd_planning "$@" ;;
  execution)       cmd_execution "$@" ;;
  dispatch-log)    cmd_dispatch_log "$@" ;;
  git)             cmd_git "$@" ;;
  init)            cmd_init "$@" ;;
  continue)        cmd_continue "$@" ;;
  sync-planning)   cmd_sync_planning "$@" ;;
  *)               echo "Unknown subcommand: $SUBCMD" >&2; exit 1 ;;
esac
