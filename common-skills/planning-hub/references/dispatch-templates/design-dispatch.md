# Design/UI-UX Agent Dispatch Template

**DISPATCH TO**: `sdlc-planner-design`

Use this template when dispatching `sdlc-planner-design` via the Task tool for per-story design work (Phase 3).

## Required Message Structure

```
PLAN: Per-Story Design (7-Phase Workflow)

STORY: US-NNN-name
STORY FOLDER: plan/user-stories/US-NNN-name/

CONTEXT:
- plan/user-stories/US-NNN-name/story.md: REQUIRED (scope, acceptance criteria, UI flows)
- plan/user-stories/US-NNN-name/hld.md: REQUIRED (component structure, user flows)
- plan/prd.md: REQUIRED (user personas, product vision)
- plan/design/design-spec.md: [exists / does not exist — if exists, follow existing design system]
- plan/design/color-palette.md: [exists / does not exist — if exists, use existing palette]
- [Whether this is the first story with design work (creates global design artifacts) or subsequent]
- [Whether this is initial design or revision based on validation/user feedback]

SCOPE:
- IN SCOPE: 7-phase design workflow for this story — UX discovery, brand foundation, information architecture, visual design, HTML/CSS mockups, accessibility audit, developer handoff
- OUT OF SCOPE: Other stories' designs, implementation code, backend logic

EXISTING PLAN ARTIFACTS:
- plan/user-stories/US-NNN-name/story.md: REQUIRED
- plan/user-stories/US-NNN-name/hld.md: REQUIRED
- plan/user-stories/US-NNN-name/design/: [exists / does not exist]
- plan/design/: [exists / does not exist]
- plan/prd.md: REQUIRED

REQUIREMENTS FROM HIGHER DIMENSIONS:
- Story acceptance criteria involving UI/UX
- HLD component structure and user flows
- PRD user personas and product vision
- Existing design system (if established by earlier story)

SHARED SPARRING RULES:
Read and apply skills/planning-hub/references/shared-sparring-rules.md for all interactions.

OUTPUT:
- Write mockups to plan/user-stories/US-NNN-name/design/
- If first design story: create plan/design/design-spec.md, color-palette.md, mockups/index.html, mockups/styles.css
- Update plan/design/mockups/index.html gallery with new screens

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Confirmation of design artifacts written in story folder
2. UX discovery findings (personas applied, journey map)
3. Mockup inventory: screen name, purpose, states covered
4. Accessibility audit summary (WCAG 2.2 AA compliance)
5. Developer handoff summary (design tokens, component states, responsive breakpoints)
6. User review items requiring feedback

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Re-dispatch (after validation feedback)

When re-dispatching after Plan Validator returns NEEDS WORK, add:

```
VALIDATOR GUIDANCE (from Plan Validator):

REASONED CORRECTIONS:
[Paste the corrections section from the Plan Validator's guidance package.
Each correction includes what's wrong, what the better artifact looks like,
and the reasoning chain explaining why.]

DOCUMENTATION:
[Paste any fetched documentation excerpts from the guidance package.]
[Paste any documentation fetch instructions — if included, use context7 MCP
to retrieve the specified docs before revising. Search for the exact terms,
library, and sections specified.]

IMPROVEMENT INSTRUCTIONS:
[Paste the consolidated improvement instructions from the guidance package.
These are specific, actionable steps to follow.]

Apply the corrections and follow the improvement instructions. If documentation
fetch instructions are included, retrieve the docs via context7 first — they
contain the context needed to produce the correct artifact.
```
