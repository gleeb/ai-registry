# Per-Story Planning Dispatch Template

Use this template as the orchestration wrapper when dispatching Phase 3 agents for a single user story.

The Hub does NOT send this template to a sub-agent directly. Instead, it uses it as a checklist to dispatch the correct set of Phase 3 agents for a specific story.

## Orchestration Steps

```
STORY: US-NNN-name
EXECUTION ORDER: {N}

1. READ story.md:
   - Extract candidate_domains from dependency manifest
   - Extract consumes_contracts list
   - Extract depends_on_stories list

2. VERIFY PREREQUISITES:
   - All depends_on_stories have passed per-story validation
   - All consumed contracts exist in plan/contracts/
   - plan/system-architecture.md exists and is validated

3. DISPATCH AGENTS (in parallel where independent):

   IF hld in candidate_domains (ALWAYS):
     Dispatch sdlc-planner-hld using hld-dispatch.md
     - Story: US-NNN-name
     - Inputs: story.md, system-architecture.md, consumed contracts

   IF api in candidate_domains:
     Dispatch sdlc-planner-api using api-design-dispatch.md
     - Story: US-NNN-name
     - Inputs: story.md, system-architecture.md, consumed contracts

   IF data in candidate_domains:
     Dispatch sdlc-planner-data using data-architecture-dispatch.md
     - Story: US-NNN-name
     - Inputs: story.md, system-architecture.md, consumed contracts

   IF security in candidate_domains:
     Dispatch sdlc-planner-security using security-dispatch.md (PER-STORY mode)
     - Story: US-NNN-name
     - Inputs: story.md, system-architecture.md, consumed contracts

   IF design in candidate_domains:
     Dispatch sdlc-planner-design using design-dispatch.md
     - Story: US-NNN-name
     - Inputs: story.md, plan/prd.md, hld.md (wait for HLD to complete first)

4. WAIT for all dispatched agents to complete.

5. DISPATCH VALIDATOR in per-story mode:
   Dispatch sdlc-plan-validator using validator-dispatch.md (PER-STORY mode)
   - Story folder: plan/user-stories/US-NNN-name/
   - Check internal consistency of all artifacts in the story folder

6. GATE: Per-story validation must pass before moving to next story.
   - If FAIL with MINOR_PATCH findings only:
     Apply patches directly, log via checkpoint.sh dispatch-log --event direct-patch,
     then re-run validation to confirm.
   - If FAIL with REQUIRES_REDISPATCH findings:
     Re-dispatch the identified agent(s) with specific findings.
   - If FAIL with a mix: apply minor patches first, then re-dispatch for the rest.
   - If PASS: proceed to next story in execution_order.
```
