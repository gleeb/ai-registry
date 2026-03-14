# Error Handling for Per-Story Design

## Missing story.md

- **Trigger**: `plan/user-stories/US-NNN-name/story.md` does not exist.
- **Action**: Do not proceed. Report: "Design requires story.md for scope and acceptance criteria."
- **Action**: Request that the story be created or the correct path be provided.
- **Prohibited**: Do not invent story scope or acceptance criteria.

## Missing hld.md

- **Trigger**: `plan/user-stories/US-NNN-name/hld.md` does not exist.
- **Action**: Do not proceed. Report: "Design requires hld.md for component structure and user flows."
- **Action**: Request that the HLD agent be dispatched first.
- **Prohibited**: Do not guess component structure.

## Missing prd.md

- **Trigger**: `plan/prd.md` does not exist or lacks user personas and UX constraints.
- **Action**: Report the gap. Request PRD with user stories and UX constraints.
- **Action**: Do not proceed with design until PRD is available and sufficient.
- **Prohibited**: Do not invent personas or UX constraints without PRD.

## Missing design-spec.md on Non-First Story

- **Trigger**: This is not the first design story, but `plan/design/design-spec.md` does not exist.
- **Action**: Flag for Planning Hub: "Brand foundation was expected but design-spec.md is missing."
- **Action**: Request that the first design story be completed or design-spec.md be provided.
- **Prohibited**: Do not create a new design system for a non-first story.
- **Prohibited**: Do not proceed without an established design system.

## Accessibility Critical Failures

- **Trigger**: Self-validation or user feedback identifies accessibility violations (contrast, font size, touch targets).
- **Action**: Identify the specific violation and location (screen, element).
- **Action**: Propose a fix that meets WCAG 2.2 AA.
- **Action**: Update the mockup and re-validate.
- **Action**: Document the fix in design-spec if it affects the design system.
- **Prohibited**: Do not ship designs with known accessibility violations.
- **Prohibited**: Do not defer accessibility fixes to implementation.

## Brand Inconsistencies

- **Trigger**: Mockups deviate from `plan/design/design-spec.md` or `plan/design/color-palette.md`.
- **Action**: Document the inconsistency: which screens or elements conflict.
- **Action**: Propose alignment with the design system.
- **Action**: If deviation is intentional, get user approval and document the exception.
- **Prohibited**: Do not complete with unresolved brand inconsistencies.

## Mockup Coverage Gaps

- **Trigger**: Story ACs with UI require mockups that are missing.
- **Trigger**: Screens missing error, empty, or loading states.
- **Action**: Identify the gap: which ACs or states are not covered.
- **Action**: Create the missing mockups or states before completing.
- **Prohibited**: Do not declare complete with mockup coverage gaps.

## Unclear User Flows

- **Trigger**: User stories exist but flows are ambiguous or contradictory.
- **Action**: Document the ambiguity: which flows are unclear.
- **Action**: Present options to the user: "Flow A could mean X or Y. Which do you intend?"
- **Action**: Request clarification before creating mockups.
- **Action**: If hld.md exists, cross-reference for flow clarity.

## Conflicting Design Requirements

- **Trigger**: PRD, HLD, or user feedback contains conflicting design requirements.
- **Action**: Document the conflict: "Requirement A says X, Requirement B says Y."
- **Action**: Present the conflict to the user with impact analysis.
- **Action**: Ask the user to prioritize or resolve the conflict.
- **Action**: Proceed only after user provides a clear direction.
