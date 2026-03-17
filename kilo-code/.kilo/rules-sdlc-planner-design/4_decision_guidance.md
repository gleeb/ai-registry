# Decision Guidance for Per-Story Design

## Principles

- Visual design decisions are within scope. Make them confidently with usability justification.
- `story.md`, `hld.md`, and `prd.md` are required inputs. Do not proceed without them.
- Implementation code is out of scope. Design specs and HTML/CSS mockups only.
- Backend design is out of scope. Focus on user-facing UI/UX.
- Gallery template must be functional HTML — navigable and viewable in a browser.

## When to Create vs Reuse Components

- **Reuse** when `plan/design/design-spec.md` documents a component with a matching pattern.
- **Create** when `design-spec.md` does not exist (first design story) or when the story requires a new pattern.
- **Extend** when the story needs a variant of an existing component — document the extension and ensure consistency.

## Color Palette Decisions

- Use `plan/design/color-palette.md` when it exists. Do not deviate without user approval.
- On first design story: define primary, secondary, accent, semantic, and neutral colors.
- Ensure semantic colors (success, error, warning) meet contrast requirements.

## Typography Choices

- Follow typography scale from `design-spec.md` when it exists.
- On first design story: define headings, body, captions, and font families.
- Minimum 16px body text for readability.

## Layout Pattern Selection

- Match layout patterns used in other stories when `design-spec.md` documents them.
- When creating new layouts: document them for consistency in future stories.
- Prefer established patterns over novel ones unless the story requires it.

## When to Flag Brand Inconsistency

- Flag when mockups would deviate from `plan/design/design-spec.md`.
- Flag when color palette or typography conflicts with existing design.
- Flag when component patterns differ from documented patterns.
- Request user resolution before proceeding.

## Responsive Strategy Decisions

- Define breakpoints consistent with architecture or PRD.
- Document how each layout adapts at mobile, tablet, and desktop.
- Ensure key screens have mockups or notes for at least mobile and desktop.

## Boundaries

- **ALLOW**: Visual design decisions (color, typography, layout, component patterns). Creating design-spec.md, color-palette.md, HTML/CSS mockups. Iterating with user on visual direction and mockups.
- **REQUIRE**: story.md, hld.md, prd.md as input. design-spec.md when not first design story. Gallery template as functional HTML.
- **DENY**: Writing implementation code (React, Vue, backend). Backend design, API design, or data model design. Proceeding without required inputs.
