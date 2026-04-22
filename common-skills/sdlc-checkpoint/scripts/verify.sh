#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# verify.sh — SDLC Checkpoint Verifier
#
# Reads checkpoint YAML, cross-references against actual artifacts on disk,
# and outputs a structured recommendation for the next action.
#
# Usage:
#   verify.sh              # Top-level: read coordinator.yaml, recommend routing
#   verify.sh planning     # Read planning.yaml, verify plan artifacts
#   verify.sh execution    # Read execution.yaml, verify staging doc state
# =============================================================================

SDLC_DIR=".sdlc"

# ---------------------------------------------------------------------------
# YAML read helpers (same as checkpoint.sh)
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
# Artifact mapping: agent domain -> expected file path
# ---------------------------------------------------------------------------

# Planning: per-story artifacts
plan_artifact_path() {
  local story="$1"
  local domain="$2"
  case "$domain" in
    hld)      echo "plan/user-stories/${story}/hld.md" ;;
    api)      echo "plan/user-stories/${story}/api.md" ;;
    data)     echo "plan/user-stories/${story}/data.md" ;;
    security) echo "plan/user-stories/${story}/security.md" ;;
    design)   echo "plan/user-stories/${story}/design/design.md" ;;
    *)        echo "" ;;
  esac
}

# Planning: phase-level artifacts
plan_phase_artifact() {
  local phase="$1"
  case "$phase" in
    1) echo "plan/prd.md" ;;
    2) echo "plan/system-architecture.md" ;;
    4) echo "plan/cross-cutting/security-overview.md plan/cross-cutting/devops.md plan/cross-cutting/testing-strategy.md" ;;
    5) echo "plan/validation/" ;;
    *) echo "" ;;
  esac
}

# ---------------------------------------------------------------------------
# VERIFY: top-level (coordinator)
# ---------------------------------------------------------------------------

verify_coordinator() {
  local file="$SDLC_DIR/coordinator.yaml"

  if [ ! -f "$file" ]; then
    echo "status: NO_CHECKPOINT"
    echo "recommendation: no checkpoint found -- start fresh or run checkpoint.sh init"
    return
  fi

  local hub story pause_after remaining hint
  hub="$(yaml_read "$file" "active_hub")"
  story="$(yaml_read "$file" "current_story")"
  pause_after="$(yaml_read "$file" "pause_after")"
  remaining="$(yaml_read_list "$file" "stories_remaining")"
  hint="$(yaml_read "$file" "resume_hint")"
  [ "$hub" = "null" ] && hub=""
  [ "$story" = "null" ] && story=""
  [ "$pause_after" = "null" ] && pause_after=""
  remaining="$(echo "$remaining" | sed 's/^ *//;s/ *$//;s/  */ /g')"

  echo "hub: ${hub:-none}"
  echo "current_story: ${story:-none}"
  [ -n "$pause_after" ] && echo "pause_after: ${pause_after}"

  # Status classification:
  #   ACTIVE  — a hub is active
  #   PAUSED  — hub cleared, pause_after set, queue still has work (user-requested review gate)
  #   IDLE    — no active hub, no pause, queue empty or no work
  local status
  if [ -n "$hub" ]; then
    status="ACTIVE"
  elif [ -n "$pause_after" ] && [ -n "$remaining" ]; then
    status="PAUSED"
  else
    status="IDLE"
  fi
  echo "status: ${status}"

  if [ "$status" = "ACTIVE" ]; then
    # Check if execution hub has already signaled completion
    if [ "$hub" = "execution" ] && [ -f "$SDLC_DIR/execution.yaml" ]; then
      local exec_status exec_story
      exec_status="$(yaml_read "$SDLC_DIR/execution.yaml" "status")"
      exec_story="$(yaml_read "$SDLC_DIR/execution.yaml" "story")"
      if [ "$exec_status" = "COMPLETE" ]; then
        echo "recommendation: story complete -- run checkpoint.sh coordinator --story-done ${exec_story:-${story:-unknown}} to transition"
        echo "detail: execution hub signaled COMPLETE but coordinator has not transitioned yet"
        return
      fi
    fi

    local target_mode="sdlc-planner"
    [ "$hub" = "execution" ] && target_mode="sdlc-architect"
    echo "recommendation: route to ${target_mode}, story ${story:-unknown}"
    echo "detail: run verify.sh ${hub} for specific resume action"
  elif [ "$status" = "PAUSED" ]; then
    echo "remaining: ${remaining}"
    echo "recommendation: paused at user review gate (pause_after=${pause_after}) -- resume with checkpoint.sh coordinator --clear-pause-after --hub execution"
    echo "detail: ${remaining%% *} is next; update pause_after to set a new gate, or clear to auto-advance"
  else
    # IDLE: if plan/user-stories/ has stories not in stories_done AND not in stories_remaining,
    # flag them as ungated_on_disk — the queue is out of sync with disk and needs --sync.
    if [ -d "plan/user-stories" ]; then
      local stories_done ungated
      stories_done="$(yaml_read_list "$file" "stories_done")"
      ungated=""
      for d in plan/user-stories/*/; do
        [ -d "$d" ] || continue
        local name
        name="$(basename "$d")"
        if echo " $stories_done " | grep -q " $name "; then continue; fi
        if echo " $remaining " | grep -q " $name "; then continue; fi
        ungated="${ungated}${name} "
      done
      ungated="$(echo "$ungated" | sed 's/ *$//')"
      if [ -n "$ungated" ]; then
        echo "ungated_on_disk: ${ungated}"
        echo "recommendation: stories on disk are not in stories_remaining or stories_done -- run checkpoint.sh coordinator --sync to repopulate, then retry"
        echo "detail: ${ungated%% *} (and possibly others) are ungated"
        return
      fi
      # If queue has pending stories but no active hub, the planner likely just handed off
      # but the coordinator hasn't routed yet. Prompt the coordinator to activate execution.
      if [ -n "$remaining" ]; then
        echo "remaining: ${remaining}"
        echo "recommendation: queue ready but no active hub -- run checkpoint.sh coordinator --hub execution to start"
        echo "detail: ${remaining%% *} is queued; set active_hub=execution to begin the story"
        return
      fi
    fi
    echo "recommendation: no active hub -- ask user what to do"
  fi
}

# ---------------------------------------------------------------------------
# VERIFY: planning
# ---------------------------------------------------------------------------

verify_planning() {
  local file="$SDLC_DIR/planning.yaml"

  if [ ! -f "$file" ]; then
    echo "hub: planning"
    echo "status: NO_CHECKPOINT"
    echo "recommendation: no planning checkpoint -- start planning from Phase 1"
    return
  fi

  local phase story agents_done agent_in_progress agents_pending
  phase="$(yaml_read "$file" "phase")"
  story="$(yaml_read "$file" "current_story")"
  agents_done="$(yaml_read_list "$file" "agents_done")"
  agent_in_progress="$(yaml_read "$file" "agent_in_progress")"
  agents_pending="$(yaml_read_list "$file" "agents_pending")"

  echo "hub: planning"
  echo "phase: ${phase:-unknown}"
  echo "story: ${story:-none}"
  echo "status: IN_PROGRESS"

  # Phase 1 or 2: check if phase artifacts exist
  if [ "${phase:-0}" -le 2 ] 2>/dev/null; then
    local artifacts
    artifacts="$(plan_phase_artifact "$phase")"
    if [ -n "$artifacts" ]; then
      local all_exist=true
      for art in $artifacts; do
        if [ -e "$art" ]; then
          echo "verification: $(basename "$art") DONE ($art exists)"
        else
          echo "verification: $(basename "$art") MISSING ($art)"
          all_exist=false
        fi
      done
      if [ "$all_exist" = true ]; then
        echo "recommendation: phase ${phase} artifacts complete -- run validator then advance to phase $(( phase + 1 ))"
      else
        echo "recommendation: re-dispatch phase ${phase} agents for missing artifacts"
      fi
      return
    fi
  fi

  # Phase 3: per-story agent verification
  if [ "${phase:-0}" = "3" ] && [ -n "$story" ] && [ "$story" != "null" ]; then
    echo "verification:"

    # Check in_progress agent first
    if [ -n "$agent_in_progress" ] && [ "$agent_in_progress" != "null" ]; then
      local art_path
      art_path="$(plan_artifact_path "$story" "$agent_in_progress")"
      if [ -n "$art_path" ] && [ -e "$art_path" ]; then
        echo "  ${agent_in_progress}: DONE ($art_path exists) -- advanced from checkpoint"
        # Agent completed after checkpoint was written; move to done
        agents_done="$agents_done $agent_in_progress"
        agent_in_progress=""
      else
        echo "  ${agent_in_progress}: IN_PROGRESS ($art_path missing)"
      fi
    fi

    # Check done agents
    for agent in $agents_done; do
      local art_path
      art_path="$(plan_artifact_path "$story" "$agent")"
      if [ -n "$art_path" ]; then
        if [ -e "$art_path" ]; then
          echo "  ${agent}: DONE ($art_path exists)"
        else
          echo "  ${agent}: CLAIMED_DONE_BUT_MISSING ($art_path)"
        fi
      fi
    done

    # Check pending agents
    for agent in $agents_pending; do
      local art_path
      art_path="$(plan_artifact_path "$story" "$agent")"
      if [ -n "$art_path" ]; then
        if [ -e "$art_path" ]; then
          echo "  ${agent}: DONE ($art_path exists) -- advanced from checkpoint"
        else
          echo "  ${agent}: PENDING"
        fi
      fi
    done

    # Determine recommendation
    if [ -n "$agent_in_progress" ] && [ "$agent_in_progress" != "null" ]; then
      echo "recommendation: re-dispatch sdlc-planner-${agent_in_progress} for ${story}"
    else
      # Find first truly pending agent (artifact doesn't exist)
      local next_agent=""
      for agent in $agents_pending; do
        local art_path
        art_path="$(plan_artifact_path "$story" "$agent")"
        if [ -n "$art_path" ] && [ ! -e "$art_path" ]; then
          next_agent="$agent"
          break
        fi
      done

      if [ -n "$next_agent" ]; then
        echo "recommendation: dispatch sdlc-planner-${next_agent} for ${story}"
        echo "next_after: continue remaining agents then per-story-validation for ${story}"
      else
        echo "recommendation: all agents complete for ${story} -- dispatch per-story validator"
      fi
    fi
    return
  fi

  # Phase 4: cross-cutting
  if [ "${phase:-0}" = "4" ]; then
    echo "verification:"
    local missing=""
    for art in "plan/cross-cutting/security-overview.md" "plan/cross-cutting/devops.md" "plan/cross-cutting/testing-strategy.md"; do
      if [ -e "$art" ]; then
        echo "  $(basename "$art"): DONE"
      else
        echo "  $(basename "$art"): MISSING"
        missing="$missing $(basename "$art" .md)"
      fi
    done
    if [ -z "$missing" ]; then
      echo "recommendation: all cross-cutting artifacts complete -- dispatch cross-story validator"
    else
      echo "recommendation: dispatch agents for missing cross-cutting:${missing}"
    fi
    return
  fi

  # Phase 5+: late phases
  echo "recommendation: continue phase ${phase:-unknown} -- check validation reports in plan/validation/"
}

# ---------------------------------------------------------------------------
# Staging-doc task counter — convention-aware
# ---------------------------------------------------------------------------
#
# Counts task sections (headers matching `^### Task `) in the staging doc and
# determines how many are complete. A section counts as done if ANY of:
#   1. The heading line contains ✓, ✅, or a case-insensitive "complete"/"done"
#      marker after the first colon.
#   2. The section body contains a `**Status:**` line whose value (before any
#      pipe) matches complete/done (case-insensitive).
#   3. Legacy: a GitHub-style `- [x]` checkbox appears in the section body.
#
# Prints "<done> <total>" on stdout. Returns 0 always (empty doc → "0 0").
count_completed_tasks_in_staging() {
  local staging_doc="$1"
  if [ ! -f "$staging_doc" ]; then
    echo "0 0"
    return 0
  fi
  awk '
    function flush_section() {
      if (in_task) {
        total++
        if (done_this) done++
      }
      in_task = 0
      done_this = 0
    }
    function lc(s) { return tolower(s) }
    /^### Task / {
      flush_section()
      in_task = 1
      done_this = 0
      # Check heading for completion markers after the first colon
      line = $0
      colon = index(line, ":")
      tail = (colon > 0) ? substr(line, colon + 1) : line
      tl = lc(tail)
      if (index(tail, "\xe2\x9c\x93") > 0 || \
          index(tail, "\xe2\x9c\x85") > 0 || \
          tl ~ /(^|[^a-z])complete([^a-z]|$)/ || \
          tl ~ /(^|[^a-z])done([^a-z]|$)/) {
        done_this = 1
      }
      next
    }
    /^#/ {
      # Any other heading ends the current section
      flush_section()
      next
    }
    {
      if (!in_task) next
      # Status line: must contain **Status:** (with optional leading list marker/whitespace)
      if ($0 ~ /\*\*[Ss]tatus:\*\*/) {
        val = $0
        sub(/^.*\*\*[Ss]tatus:\*\*[[:space:]]*/, "", val)
        # Value before first pipe
        pipe = index(val, "|")
        if (pipe > 0) val = substr(val, 1, pipe - 1)
        vl = lc(val)
        if (vl ~ /(^|[^a-z])complete([^a-z]|$)/ || vl ~ /(^|[^a-z])done([^a-z]|$)/) {
          done_this = 1
        }
      }
      # Legacy checkbox
      if ($0 ~ /-[[:space:]]*\[[xX]\]/) {
        done_this = 1
      }
    }
    END {
      flush_section()
      printf "%d %d\n", done+0, total+0
    }
  ' "$staging_doc"
}

# ---------------------------------------------------------------------------
# VERIFY: execution
# ---------------------------------------------------------------------------

verify_execution() {
  local file="$SDLC_DIR/execution.yaml"

  if [ ! -f "$file" ]; then
    echo "hub: execution"
    echo "status: NO_CHECKPOINT"
    echo "recommendation: no execution checkpoint -- start from Phase 0 readiness check"
    return
  fi

  local story phase tasks_total tasks_completed
  local task_id task_name step iteration staging_doc
  local branch_name base_branch base_commit
  story="$(yaml_read "$file" "story")"
  phase="$(yaml_read "$file" "phase")"
  tasks_total="$(yaml_read "$file" "tasks_total")"
  tasks_completed="$(yaml_read "$file" "tasks_completed")"
  task_id="$(yaml_read "$file" "current_task_id")"
  task_name="$(yaml_read "$file" "current_task_name")"
  step="$(yaml_read "$file" "current_step")"
  iteration="$(yaml_read "$file" "current_iteration")"
  staging_doc="$(yaml_read "$file" "staging_doc")"
  branch_name="$(yaml_read "$file" "branch_name")"
  base_branch="$(yaml_read "$file" "base_branch")"
  base_commit="$(yaml_read "$file" "base_commit")"

  echo "hub: execution"
  echo "phase: ${phase:-unknown}"
  echo "story: ${story:-none}"
  echo "tasks: ${tasks_completed:-0}/${tasks_total:-?}"
  echo "status: IN_PROGRESS"

  # Verify git branch state if branch_name is recorded
  if [ -n "$branch_name" ] && [ "$branch_name" != "null" ]; then
    local current_branch
    current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"

    if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
      if [ "$current_branch" = "$branch_name" ]; then
        echo "branch: ${branch_name} (checked out)"
        echo "base_commit: ${base_commit:-unknown}"
      else
        echo "branch: ${branch_name} (EXISTS but not checked out -- current: ${current_branch})"
        echo "branch_action: checkout ${branch_name} before continuing"
      fi
    else
      echo "branch: ${branch_name} (MISSING -- may have been merged or deleted)"
      echo "branch_action: verify branch status -- may need to recreate from ${base_branch:-main}"
    fi
  fi

  # If we have a staging doc, verify task status against it
  if [ -n "$staging_doc" ] && [ "$staging_doc" != "null" ] && [ -f "$staging_doc" ]; then
    echo "staging_doc: ${staging_doc} (exists)"

    # Count actual task status from staging doc using convention-aware parser
    local counts actual_done actual_total cp_done
    counts="$(count_completed_tasks_in_staging "$staging_doc")"
    actual_done="${counts%% *}"
    actual_total="${counts##* }"
    cp_done="${tasks_completed:-0}"

    if [ "$actual_done" = "$cp_done" ]; then
      : # counts agree — no drift warning
    elif [ "$actual_done" -gt "$cp_done" ] 2>/dev/null; then
      echo "verification: staging ahead of checkpoint (staging: ${actual_done}/${actual_total}, checkpoint: ${cp_done}) -- trusting staging doc"
      tasks_completed="$actual_done"
    else
      echo "verification: checkpoint ahead of staging (checkpoint: ${cp_done}, staging: ${actual_done}/${actual_total}) -- counts differ; inspect staging doc manually"
    fi
  elif [ -n "$staging_doc" ] && [ "$staging_doc" != "null" ]; then
    echo "staging_doc: ${staging_doc} (MISSING)"
  fi

  # Phase 2: per-task dev loop
  if [ "${phase:-0}" = "2" ]; then
    if [ -n "$task_id" ] && [ "$task_id" != "null" ]; then
      echo "current_task: ${task_id} (${task_name:-unknown})"
      echo "current_step: ${step:-implement}"
      echo "current_iteration: ${iteration:-1}"

      case "${step:-implement}" in
        implement)
          echo "recommendation: dispatch sdlc-implementer for task ${task_id} \"${task_name}\""
          ;;
        review)
          echo "recommendation: dispatch sdlc-code-reviewer for task ${task_id} \"${task_name}\" (iteration ${iteration:-1})"
          ;;
        qa)
          echo "recommendation: dispatch sdlc-qa for task ${task_id} \"${task_name}\""
          ;;
        *)
          echo "recommendation: unknown step '${step}' -- read staging doc for task ${task_id} status"
          ;;
      esac
    else
      # No current task — either all done or need to pick next
      if [ "${tasks_completed:-0}" -ge "${tasks_total:-0}" ] 2>/dev/null; then
        echo "recommendation: all tasks complete -- advance to Phase 3 story integration"
      else
        echo "recommendation: read staging doc to identify next pending task"
      fi
    fi
    return
  fi

  # Other phases
  case "${phase:-0}" in
    0|0a|0b|1|1a|1b|1c)
      echo "recommendation: continue Phase ${phase} setup -- read staging doc if exists"
      ;;
    3)
      echo "recommendation: Phase 3 story integration -- dispatch sdlc-code-reviewer for full-story review"
      ;;
    3b)
      echo "recommendation: Phase 3b semantic review -- dispatch sdlc-semantic-reviewer with git context (branch: ${branch_name:-unknown}, base: ${base_commit:-unknown})"
      ;;
    4)
      echo "recommendation: Phase 4 acceptance -- dispatch sdlc-acceptance-validator with git context (branch: ${branch_name:-unknown}, base: ${base_commit:-unknown})"
      ;;
    5)
      echo "recommendation: Phase 5 documentation integration -- follow doc-integration-protocol"
      ;;
    6)
      echo "recommendation: Phase 6 user acceptance -- present evidence report to user"
      ;;
    *)
      echo "recommendation: unknown phase ${phase} -- read staging doc for context"
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Main dispatch
# ---------------------------------------------------------------------------

HUB="${1:-}"

if [ ! -d "$SDLC_DIR" ]; then
  echo "status: NO_CHECKPOINT_DIR"
  echo "recommendation: no .sdlc/ directory found -- either run checkpoint.sh init or start a new workflow"
  exit 0
fi

case "$HUB" in
  "")         verify_coordinator ;;
  planning)   verify_planning ;;
  execution)  verify_execution ;;
  *)          echo "Unknown hub: $HUB (expected: planning, execution, or empty for coordinator)" >&2; exit 1 ;;
esac
