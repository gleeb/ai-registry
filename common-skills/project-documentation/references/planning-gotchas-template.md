# Planning Gotchas Template

Use this template when the engineering hub creates the planning-gotchas sibling file during Phase 1b.

**File location:** `docs/staging/US-NNN-name.planning-gotchas.md`
**Linked from:** `docs/staging/US-NNN-name.md` (main staging doc header)

**Purpose:** Append-only log of systemic planning misses discovered during this story's execution — cases where the Phase 3 story-review iteration cap (3) triggered escalation because the plan artifacts (PRD / HLD / API / Security / Testing / Story AC) did not anticipate an issue. Post-run, the human reviews this file alongside the run transcript and any promotion of the lesson into planning agents or planning skills is a deliberate manual action.

**Who writes it:** The engineering hub appends entries on iteration-cap escalation during Phase 3 story review. Subagents do NOT write to this file directly.
**Who reads it:** The human, post-run, in a separate evaluation pass. NOT read, rolled up, or propagated by any agent during the story run or during subsequent planning runs.
**Who must NOT promote from it:** Any agent during a story run or a planning run. Promotion into planner agents, planner skills, or plan-artifact templates is a human post-run action only.

**Distinction from skill-gotchas:** `skill-gotchas` captures technical library/framework quirks (candidates for promotion into implementation skills). `planning-gotchas` captures systemic planning gaps (candidates for promotion into planner agents or planner skills). They are siblings by purpose, not duplicates. Both follow the same human-post-run review pattern — neither is consumed by agents during runs.

---

## Template

```markdown
# US-NNN — Planning Gotchas

**Story:** [Story Title]
**Main staging doc:** `docs/staging/US-NNN-name.md`
**Post-run action:** Review entries below with the run transcript. Any promotion into planner agents, planner skills, or plan-artifact templates is a human decision made out-of-band.

---

## Gotchas

<!-- Append entries below. Do not delete or reorder existing entries. -->

```

---

## Entry Schema

Each entry added by the engineering hub when the 3-iteration story-review cap triggers escalation must use this format:

```markdown
## Gotcha: [short descriptive title]

- **trigger:** [What triggered the write — e.g., "Story-review iteration cap (3) hit with unresolved Critical finding on payload-size bounds"]
- **recurring_finding:** [What the story reviewer kept finding across iterations, summarized. Include the lens from the Review Coverage Matrix where it surfaced.]
- **plan_artifact_category:** [One of: PRD | HLD | API | Security | Testing | Story AC — which plan artifact should have anticipated this. Informational only — used by the human reviewer to route the lesson to the right planner agent/skill during post-run evaluation.]
- **missed_in_planning:** [Specifically what the plan artifact lacked. Cite the artifact path if it exists, e.g., "plan/user-stories/US-002-name/hld.md does not specify payload-size constraints for the state-sync protocol"]
- **suggested_planning_fix:** [Candidate planning-side change for a future cycle. Name a specific planner agent or planner skill (e.g., sdlc-planner-hld, sdlc-planner-api, sdlc-planner-security) and describe what that agent should produce differently. Treated as a suggestion to the human reviewer, not an instruction to any agent.]
- **runtime_resolution:** [What path the engineering hub took at runtime — Oracle dispatch or architect self-implementation — so the human reviewer can cross-reference the resolution evidence in the staging doc]
- **discovered_in:** [Story ID and the story-review iteration that first surfaced the finding, e.g., "US-002, story-review iteration 2"]
```

---

## Example

```markdown
## Gotcha: Payload-size bounds absent from state-sync HLD

- **trigger:** Story-review iteration cap (3) hit. Story reviewer repeatedly surfaced payload-size/serialization findings under the "Payload / input-boundary edges" lens; each remediation introduced a new edge case.
- **recurring_finding:** Non-serializable payloads and unbounded message sizes in the state-sync protocol. Iteration 1 flagged strict-shape handling; iteration 2 flagged payload-size bounds; iteration 3 flagged non-serializable payload edge case. Findings clustered at the same architectural seam across different symptoms.
- **plan_artifact_category:** HLD
- **missed_in_planning:** `plan/user-stories/US-002-real-time-state/hld.md` design unit "State Sync Protocol" specifies message types and field names but does not specify payload-size limits, serialization contract, or rejection behavior for malformed payloads. The implementer had to invent these contracts mid-implementation.
- **suggested_planning_fix:** Candidate for sdlc-planner-hld: include a "Protocol Robustness" sub-section in every DU that defines a message/data-transfer protocol — required/optional fields, size bounds, serialization format, rejection behavior per violation class. Human reviewer to decide whether to land this in the planner agent, a planner skill reference, or both.
- **runtime_resolution:** Oracle dispatch at iteration cap produced the payload-size contract and serialization guard. Architect applied Oracle's recommendation verbatim. See `docs/staging/US-002-real-time-state.md` Oracle Escalation entry for full chain.
- **discovered_in:** US-002, story-review iteration 2
```
