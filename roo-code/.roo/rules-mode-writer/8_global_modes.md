# global_modes_reference

## overview

This reference documents how global (system-wide) modes work, where they live, and how they interact
with workspace-scoped modes.

## locations

### workspace

**File:** .roomodes

**Scope:** Per-workspace (project) modes

### global

**File:** Global custom modes settings file (stored in VS Code globalStorage; exact path is environment-specific)

**Scope:** System-wide modes for Roo Code

**Notes:** This file is created automatically on Roo Code startup if it does not exist.

## precedence

**Rule:** When a mode with the same slug exists in both locations, the workspace (.roomodes) version takes precedence.

**Implications:**
- Editing the global mode may have no visible effect inside a workspace that overrides the same slug.
- To change behavior in one repo only, prefer editing .roomodes.

## workflow_guidance

### decision

- Default to editing .roomodes unless the user explicitly requests global scope.
- If the user asks for global scope, first check whether a workspace override exists for the same slug. If it does, explain the precedence and offer to edit both.

### safe_editing_principles

- Prefer minimal, targeted changes and preserve YAML formatting.
