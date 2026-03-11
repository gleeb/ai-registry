# Developer Handoff Reference

## Purpose

Developer Handoff is the final phase of the Design workflow. It translates design decisions into implementation-ready specifications that an execution agent can follow without ambiguity.

## Design Tokens Specification

Provide all design tokens in a structured format:

```markdown
## Design Tokens

### Colors
| Token | Value | Usage |
|-------|-------|-------|
| `--color-primary` | #1a73e8 | Primary actions, links |
| `--color-primary-hover` | #1557b0 | Hover state for primary |
| `--color-error` | #d93025 | Error states, validation |

### Typography
| Token | Value | Usage |
|-------|-------|-------|
| `--font-body` | Inter, system-ui, sans-serif | Body text |
| `--font-heading` | Inter, system-ui, sans-serif | Headings |
| `--text-body-size` | 16px | Body text |
| `--text-body-line-height` | 1.5 | Body text |

### Spacing
| Token | Value | Usage |
|-------|-------|-------|
| `--space-xs` | 4px | Tight spacing, icon gaps |
| `--space-sm` | 8px | Compact element spacing |
| `--space-md` | 16px | Standard element spacing |
| `--space-lg` | 24px | Section spacing |

### Shadows
| Token | Value | Usage |
|-------|-------|-------|
| `--shadow-sm` | 0 1px 2px rgba(0,0,0,0.1) | Subtle elevation |
| `--shadow-md` | 0 4px 6px rgba(0,0,0,0.1) | Cards, dropdowns |
```

## Component State Documentation

For each interactive component in the mockups, document ALL states:

```markdown
## Component: {Component Name}

### States
| State | Visual Change | Trigger |
|-------|--------------|---------|
| Default | {description} | Initial render |
| Hover | {description} | Mouse over |
| Focus | {description} | Keyboard focus |
| Active | {description} | Mouse down / tap |
| Disabled | {description} | Not available |
| Loading | {description} | Async operation |
| Error | {description} | Validation failure |
| Empty | {description} | No data |

### Accessibility
- Role: {ARIA role if needed}
- Label: {accessible name source}
- States: {ARIA states communicated}
- Keyboard: {key interactions}
```

## Responsive Specifications

Document behavior at each breakpoint:

```markdown
## Responsive Behavior

### Breakpoints
| Name | Min Width | Layout Change |
|------|-----------|---------------|
| Mobile | 0px | Single column, stacked nav |
| Tablet | 768px | Two column, collapsible sidebar |
| Desktop | 1024px | Full layout, persistent sidebar |
| Wide | 1440px | Max content width, centered |

### Component-Specific
| Component | Mobile | Tablet | Desktop |
|-----------|--------|--------|---------|
| Navigation | Bottom tab bar | Collapsible sidebar | Persistent sidebar |
| Data table | Card list | Horizontal scroll | Full table |
| Form layout | Single column | Single column | Two column |
```

## Interaction Specifications

For each interaction:

```markdown
## Interaction: {Name}

**Trigger**: {what starts the interaction}
**Animation**: {type, duration, easing — e.g., slide-in, 200ms, ease-out}
**Loading state**: {what shows during async operations}
**Success state**: {what shows on success}
**Error state**: {what shows on failure}
**Undo**: {can the user reverse? how?}
```

## Asset Inventory

List all assets needed for implementation:

```markdown
## Assets Required

| Asset | Format | Location | Notes |
|-------|--------|----------|-------|
| Logo | SVG | plan/design/mockups/assets/ | Include dark/light variants |
| Icons | SVG sprite | plan/design/mockups/assets/ | From {icon library} |
| Fonts | WOFF2 | CDN / self-hosted | {font names and weights} |
| Illustrations | SVG/PNG | plan/design/mockups/assets/ | {specific illustrations} |
```

## Handoff Checklist

Before declaring design complete for a story:

- [ ] All design tokens documented
- [ ] All interactive component states documented
- [ ] Responsive behavior specified at all breakpoints
- [ ] Interactions specified with animations and states
- [ ] Accessibility requirements per component documented
- [ ] Error, empty, and loading states defined
- [ ] Assets inventoried with format and location
- [ ] Mockups match design spec (color palette, typography, spacing)
