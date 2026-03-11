# Design/UI-UX Agent Dispatch Template

Use this template when dispatching `sdlc-planner-design` via `new_task`.

## Required Message Structure

```
PLAN: Design and UI/UX

CONTEXT:
- [Reference to plan/prd.md — user stories, UX constraints, target audience]
- [Reference to plan/hld.md — feature areas and user flows]
- [Reference to plan/system-architecture.md — platform/framework constraints]
- [Whether greenfield or updating existing designs]
- [Any design references, brand guidelines, or inspiration provided by user]

SCOPE:
- IN SCOPE: Visual design direction, color palette, typography, component patterns, screen mockups (HTML/CSS), user flow diagrams, responsive/adaptive design, accessibility considerations
- OUT OF SCOPE: Implementation of UI components (execution phase), backend design, API design

EXISTING PLAN ARTIFACTS:
- plan/prd.md: [REQUIRED]
- plan/hld.md: [REQUIRED or in progress]
- plan/design/: [exists / does not exist]
- [List any other relevant existing plan files]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- [UX & Design constraints from PRD section 8]
- [Accessibility requirements from PRD section 9]
- [User stories and user flows from PRD section 7]
- [Platform constraints from architecture]

OUTPUT:
- Write design specification to plan/design/design-spec.md
- Write color palette to plan/design/color-palette.md
- Create mockup gallery at plan/design/mockups/index.html
- Create screen mockups in plan/design/mockups/screens/[feature]/

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that design artifacts have been written
2. Design direction summary (visual style, key decisions)
3. Color palette and typography choices
4. Screen inventory with mockup paths
5. Accessibility decisions
6. User flow coverage (which PRD user stories have mockups)
7. Unresolved design questions or alternatives presented to user

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
