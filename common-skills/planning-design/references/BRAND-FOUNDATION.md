# Brand Foundation Reference

## Purpose

Brand Foundation establishes the visual identity and voice guidelines that all design work follows. This phase runs once (during the first story with design work) and is referenced by subsequent stories.

If the project has existing brand guidelines, this phase validates alignment and extracts relevant constraints. If no brand exists, this phase creates the foundation.

## Brand Identity

```markdown
## Brand Identity

**Brand name**: {name}
**Brand positioning**: {one sentence describing what the brand stands for}
**Brand personality**: {3-5 adjectives — e.g., professional, approachable, innovative}
**Brand voice**: {how the brand communicates — e.g., clear, concise, friendly, authoritative}

### Voice guidelines
- **Do**: {examples of correct voice}
- **Don't**: {examples of incorrect voice}
- **Tone variations**: {how tone shifts by context — error messages vs success vs onboarding}
```

## Visual Identity

```markdown
## Visual Identity

### Color Palette
- **Primary**: {color hex + name + usage}
- **Secondary**: {color hex + name + usage}
- **Accent**: {color hex + name + usage}
- **Neutral**: {grays, whites, blacks with usage}
- **Semantic**: {success green, error red, warning yellow, info blue}
- **Contrast ratios**: All foreground/background combinations must meet WCAG 2.2 AA (4.5:1 for normal text, 3:1 for large text)

### Typography
- **Primary font**: {font name, weight range, usage}
- **Secondary font**: {font name, weight range, usage}
- **Type scale**: {base size, scale ratio, heading sizes}
- **Line heights**: {body, heading, caption}
- **Font loading strategy**: {system fallbacks, FOUT/FOIT preference}

### Spacing System
- **Base unit**: {e.g., 4px or 8px}
- **Scale**: {e.g., 4, 8, 12, 16, 24, 32, 48, 64}
- **Usage**: {when to use each spacing value}

### Iconography
- **Style**: {outlined, filled, duotone}
- **Size grid**: {e.g., 16px, 20px, 24px, 32px}
- **Source**: {icon library or custom}

### Border and Shadow
- **Border radius**: {e.g., 4px for inputs, 8px for cards, 16px for modals}
- **Shadow levels**: {e.g., sm, md, lg with values}
```

## Design Tokens

Design tokens are the machine-readable version of the visual identity. They enable consistent implementation:

```json
{
  "color": {
    "primary": { "value": "#1a73e8" },
    "secondary": { "value": "#5f6368" },
    "error": { "value": "#d93025" }
  },
  "spacing": {
    "xs": { "value": "4px" },
    "sm": { "value": "8px" },
    "md": { "value": "16px" },
    "lg": { "value": "24px" }
  },
  "typography": {
    "body": { "fontFamily": "Inter", "fontSize": "16px", "lineHeight": "1.5" },
    "heading": { "fontFamily": "Inter", "fontSize": "24px", "fontWeight": "600" }
  }
}
```

## Output

Brand Foundation artifacts are written to:
- `plan/design/design-spec.md` — brand identity, visual identity, design tokens
- `plan/design/color-palette.md` — detailed color system with accessibility notes

These are created during the first story with design work and referenced by all subsequent stories.
