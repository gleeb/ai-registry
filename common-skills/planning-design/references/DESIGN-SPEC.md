# Design Specification Template

## Purpose

Use this format when drafting or refining a design specification. The design spec is the single source of truth for visual direction, component patterns, and screen inventory. It must be complete, consistent, and implementable before development begins.

## Contract Gates

- REQUIRE all sections to be substantive before the design spec is considered complete.
- REQUIRE every screen in the user flow to have a mockup path or explicit deferral rationale.
- DENY placeholders such as "TBD" or "to be determined" — document the decision or mark as deferred with rationale.
- DENY inconsistent component patterns across screens without explicit rationale.
- DENY mockups without defined error, empty, and loading states where applicable.
- ALLOW provisional draft only when clearly marked `PROVISIONAL - NOT VALIDATED`.

---

## 1. Metadata

| Field | Value |
|-------|-------|
| Document Version | 0.1.0 |
| Last Updated | [date] |
| Design Owner | [name or team] |
| Status | Draft / Review / Approved |
| Related Plans | plan/prd.md, plan/hld.md, plan/system-architecture.md |
| Target Platforms | Web / iOS / Android / Desktop / Multi-platform |
| WCAG Target Level | A / AA / AAA |

---

## 2. Design Direction

### 2.1 Visual Style

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| Overall style | [e.g., Minimal, Editorial, Playful, Enterprise, etc.] | [Why this style fits the product and audience] |
| Mood | [e.g., Calm, Energetic, Trustworthy, Innovative] | [How mood supports user goals] |
| Key principles | [3–5 principles, e.g., Clarity over decoration, Progressive disclosure] | [Design philosophy] |

### 2.2 References and Inspiration

| Reference | URL or Description | What we adopt |
|-----------|-------------------|---------------|
| [Reference 1] | [link or description] | [Specific elements: color, typography, layout] |
| [Reference 2] | [link or description] | [Specific elements] |

### 2.3 Constraints

- **Brand guidelines**: [Existing brand colors, logos, voice — or "None, greenfield"]
- **Platform constraints**: [Framework limitations, native vs web patterns]
- **Audience**: [Primary user segment and implications for design]

---

## 3. Color System

### 3.1 Palette Definition

See `plan/design/color-palette.md` for full color definitions. Summary:

| Role | Light Mode | Dark Mode | Usage |
|------|------------|-----------|-------|
| Primary | [hex] | [hex] | Primary actions, key UI elements |
| Secondary | [hex] | [hex] | Secondary actions, supporting elements |
| Accent | [hex] | [hex] | Highlights, links, emphasis |
| Background | [hex] | [hex] | Page/surface background |
| Surface | [hex] | [hex] | Cards, modals, elevated surfaces |
| Text Primary | [hex] | [hex] | Body text |
| Text Secondary | [hex] | [hex] | Muted text, captions |
| Border | [hex] | [hex] | Dividers, outlines |

### 3.2 Semantic Colors

| Semantic | Light Mode | Dark Mode | Usage |
|----------|------------|-----------|-------|
| Success | [hex] | [hex] | Confirmations, success states |
| Error | [hex] | [hex] | Errors, destructive actions |
| Warning | [hex] | [hex] | Warnings, caution states |
| Info | [hex] | [hex] | Informational messages |

### 3.3 Contrast Ratios

| Pairing | Ratio | WCAG AA | WCAG AAA |
|---------|-------|---------|----------|
| Text Primary on Background | [e.g., 7.2:1] | Pass | Pass |
| Text Secondary on Background | [e.g., 4.6:1] | Pass | Fail |
| Primary button text on Primary | [e.g., 4.5:1] | Pass | — |

---

## 4. Typography

### 4.1 Font Families

| Role | Font Family | Fallback | Source |
|------|-------------|----------|--------|
| Heading | [e.g., Inter, system-ui] | [fallback stack] | [Google Fonts, system, etc.] |
| Body | [e.g., Inter, system-ui] | [fallback stack] | [Source] |
| Monospace | [e.g., JetBrains Mono] | monospace | [Source] |

### 4.2 Type Scale

| Token | Size | Line Height | Weight | Usage |
|-------|------|-------------|--------|-------|
| Display | [e.g., 48px] | [e.g., 1.2] | [e.g., 700] | Hero headings |
| H1 | [e.g., 32px] | [e.g., 1.25] | [e.g., 700] | Page titles |
| H2 | [e.g., 24px] | [e.g., 1.3] | [e.g., 600] | Section titles |
| H3 | [e.g., 20px] | [e.g., 1.35] | [e.g., 600] | Subsection titles |
| Body | [e.g., 16px] | [e.g., 1.5] | [e.g., 400] | Body text |
| Small | [e.g., 14px] | [e.g., 1.4] | [e.g., 400] | Captions, labels |
| Caption | [e.g., 12px] | [e.g., 1.3] | [e.g., 400] | Metadata, hints |

### 4.3 Usage Guidelines

- **Minimum body font size**: 16px for readability and WCAG.
- **Line length**: 45–75 characters for body text.
- **Heading hierarchy**: Use H1 once per page; maintain logical order (H1 → H2 → H3).

---

## 5. Component Library

### 5.1 Buttons

| Variant | Style | States | Usage |
|---------|-------|--------|-------|
| Primary | [Background, text, border] | Default, Hover, Active, Focus, Disabled | Primary CTA |
| Secondary | [Style] | [States] | Secondary actions |
| Ghost | [Style] | [States] | Tertiary, low emphasis |
| Destructive | [Style] | [States] | Delete, remove |

- **Minimum touch target**: 44×44px (or 24×24px with 8px+ spacing).
- **Focus indicator**: [e.g., 2px outline, 2px offset, primary color].

### 5.2 Forms and Inputs

| Component | Style | States | Usage |
|-----------|-------|--------|-------|
| Text input | [Border, background, padding] | Default, Focus, Error, Disabled | Single-line text |
| Textarea | [Style] | [States] | Multi-line text |
| Select | [Style] | [States] | Dropdown selection |
| Checkbox | [Style] | [States] | Boolean choice |
| Radio | [Style] | [States] | Single choice from group |
| Toggle | [Style] | [States] | Boolean switch |

- **Label placement**: [Above / Inline / Floating].
- **Error display**: [Inline below field / Inline with field].

### 5.3 Cards

| Variant | Style | Usage |
|---------|-------|-------|
| Default | [Padding, border, shadow] | Content containers |
| Elevated | [Style] | Modals, overlays |
| Interactive | [Style + hover] | Clickable cards |

### 5.4 Navigation

| Component | Style | Behavior | Usage |
|-----------|-------|----------|-------|
| Top nav | [Height, items, logo] | [Sticky, scroll behavior] | Primary navigation |
| Sidebar | [Width, items] | [Collapsible, responsive] | Secondary navigation |
| Tabs | [Style] | [Keyboard, ARIA] | Section switching |
| Breadcrumb | [Style] | [Separator, truncation] | Hierarchy |
| Mobile nav | [Style] | [Hamburger, drawer] | Small screens |

### 5.5 Modals and Overlays

| Component | Style | Behavior | Usage |
|-----------|-------|----------|-------|
| Modal | [Size, overlay] | [Focus trap, escape, backdrop click] | Confirmations, forms |
| Drawer | [Position, width] | [Slide in/out] | Filters, settings |
| Toast | [Position, duration] | [Auto-dismiss, stack] | Notifications |
| Tooltip | [Style] | [Hover/focus trigger] | Hints |

### 5.6 Alerts and Feedback

| Component | Style | Usage |
|-----------|-------|-------|
| Alert (info) | [Background, border, icon] | Informational messages |
| Alert (success) | [Style] | Success confirmations |
| Alert (warning) | [Style] | Warnings |
| Alert (error) | [Style] | Error messages |
| Empty state | [Icon, text, CTA] | No data |
| Loading state | [Skeleton / Spinner] | Async operations |

---

## 6. Layout System

### 6.1 Grid

| Breakpoint | Columns | Gutter | Max Width |
|------------|---------|--------|-----------|
| Mobile (< 768px) | [e.g., 4] | [e.g., 16px] | 100% |
| Tablet (768px–1279px) | [e.g., 8] | [e.g., 24px] | [e.g., 100%] |
| Desktop (≥ 1280px) | [e.g., 12] | [e.g., 24px] | [e.g., 1440px] |

### 6.2 Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| xs | [e.g., 4px] | Tight spacing |
| sm | [e.g., 8px] | Component internal |
| md | [e.g., 16px] | Between elements |
| lg | [e.g., 24px] | Section spacing |
| xl | [e.g., 32px] | Major sections |
| 2xl | [e.g., 48px] | Page margins |

### 6.3 Breakpoints

| Name | Min Width | Usage |
|------|-----------|-------|
| mobile | 0 | Base, mobile-first |
| tablet | 768px | Tablet layout |
| desktop | 1280px | Desktop layout |
| wide | 1920px | Large screens (optional) |

---

## 7. Iconography and Imagery

### 7.1 Icons

| Aspect | Decision |
|--------|----------|
| Icon set | [e.g., Lucide, Heroicons, custom] |
| Size scale | [e.g., 16, 20, 24, 32px] |
| Stroke weight | [e.g., 1.5px, 2px] |
| Color inheritance | [e.g., currentColor for flexibility] |

### 7.2 Imagery

| Aspect | Decision |
|--------|----------|
| Photography style | [e.g., Stock, custom, illustration] |
| Illustration style | [e.g., Line, flat, 3D] |
| Aspect ratios | [e.g., 16:9, 4:3, 1:1] |
| Placeholder | [e.g., Gradient, pattern, skeleton] |

---

## 8. Interaction Patterns

### 8.1 States

| State | Treatment | Usage |
|-------|-----------|-------|
| Default | [Style] | Initial state |
| Hover | [Style change] | Mouse over |
| Focus | [Visible focus indicator] | Keyboard focus |
| Active | [Style change] | Pressed/clicked |
| Disabled | [Reduced opacity, no pointer] | Unavailable |
| Loading | [Spinner, skeleton, disabled] | Async in progress |
| Error | [Border, message, icon] | Validation failure |
| Empty | [Icon, message, CTA] | No data |
| Success | [Checkmark, message] | Completed action |

### 8.2 Transitions

| Property | Duration | Easing | Usage |
|----------|----------|--------|-------|
| Color, opacity | [e.g., 150ms] | [e.g., ease] | Hover, focus |
| Transform | [e.g., 200ms] | [e.g., ease-out] | Modals, drawers |
| Layout | [e.g., 300ms] | [e.g., ease-in-out] | Expand, collapse |

### 8.3 Loading Patterns

| Pattern | Usage |
|---------|-------|
| Skeleton | Content-heavy pages, lists |
| Spinner | Buttons, inline loading |
| Progress bar | Long operations |
| Optimistic UI | Instant feedback, rollback on error |

---

## 9. Accessibility Standards

### 9.1 WCAG Compliance

| Level | Target | Notes |
|-------|--------|-------|
| A | Required | Minimum |
| AA | Target | [e.g., Contrast, focus, keyboard] |
| AAA | Aspirational | [Where feasible] |

### 9.2 Contrast Ratios

- **Normal text**: Minimum 4.5:1 (AA), 7:1 (AAA).
- **Large text (18px+ or 14px+ bold)**: Minimum 3:1 (AA), 4.5:1 (AAA).
- **UI components and graphics**: Minimum 3:1.

### 9.3 Focus Indicators

- **Visibility**: All interactive elements must have a visible focus indicator.
- **Style**: [e.g., 2px solid outline, 2px offset, primary color].
- **Never**: `outline: none` without an alternative.

### 9.4 Screen Reader Guidelines

- **Semantic HTML**: Use `<button>`, `<nav>`, `<main>`, `<article>`, etc.
- **ARIA**: Use only when semantic HTML is insufficient; document ARIA usage per component.
- **Alt text**: All images must have meaningful alt text or `alt=""` if decorative.
- **Labels**: All form inputs must have associated labels (visible or aria-label).
- **Live regions**: Use `aria-live` for dynamic content (toasts, alerts).

### 9.5 Keyboard Navigation

- **Tab order**: Logical, matches visual order.
- **Escape**: Dismiss modals, drawers, dropdowns.
- **Enter/Space**: Activate buttons, links.
- **Arrow keys**: Navigate within components (tabs, menus, lists) where appropriate.

---

## 10. Screen Inventory

| Feature | Screen | Mockup Path | Notes |
|---------|--------|-------------|-------|
| [Feature A] | [Screen 1] | `screens/[feature-a]/[screen-1].html` | [e.g., Main flow] |
| [Feature A] | [Screen 2] | `screens/[feature-a]/[screen-2].html` | [e.g., Empty state] |
| [Feature B] | [Screen 1] | `screens/[feature-b]/[screen-1].html` | |
| — | — | — | |

**Deferred screens** (with rationale):

| Feature | Screen | Deferral Rationale |
|---------|--------|-------------------|
| [Feature] | [Screen] | [Why mockup is deferred] |

---

## Quality Checklist

Before marking the design spec complete, verify:

- [ ] All 10 sections have substantive content (no placeholders).
- [ ] Color palette includes light and dark mode when required by PRD.
- [ ] Contrast ratios are documented and meet WCAG target.
- [ ] Typography scale is defined with minimum 16px body text.
- [ ] All component patterns include default, hover, focus, active, disabled, loading, error states where applicable.
- [ ] Layout system includes breakpoints and spacing scale.
- [ ] Screen inventory maps every user-facing flow to a mockup or deferral.
- [ ] Accessibility section specifies WCAG level, focus indicators, and screen reader approach.
- [ ] Empty states and loading states are defined for all data-dependent screens.
- [ ] Design direction includes usability rationale for key choices.
