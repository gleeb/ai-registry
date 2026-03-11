# Accessibility Checklist (WCAG 2.2 AA)

## Purpose

This checklist is used during the Accessibility Audit phase (Phase 6 of the Design workflow). Every mockup must be evaluated against these criteria before the story's design is considered complete.

## Perceivable

### 1.1 Text Alternatives
- [ ] All non-text content has text alternatives (alt text for images, labels for icons)
- [ ] Decorative images have empty alt attributes (`alt=""`)
- [ ] Complex images (charts, diagrams) have long descriptions

### 1.2 Time-Based Media
- [ ] Video has captions (if applicable)
- [ ] Audio has transcripts (if applicable)
- [ ] No auto-playing media

### 1.3 Adaptable
- [ ] Content structure is conveyed through semantic HTML (headings, lists, tables)
- [ ] Reading order is logical when CSS is disabled
- [ ] Form inputs have associated labels
- [ ] Required fields are programmatically indicated (not just visually)

### 1.4 Distinguishable
- [ ] Text color contrast meets 4.5:1 ratio (normal text) or 3:1 (large text/UI components)
- [ ] Non-text contrast meets 3:1 against adjacent colors
- [ ] Text can be resized up to 200% without loss of functionality
- [ ] Content reflows at 320px viewport width (no horizontal scrolling)
- [ ] No content is conveyed by color alone (use icons, text, or patterns as well)
- [ ] Text spacing can be adjusted (line height 1.5x, paragraph spacing 2x, letter spacing 0.12em)

## Operable

### 2.1 Keyboard Accessible
- [ ] All functionality is available via keyboard
- [ ] No keyboard traps
- [ ] Keyboard focus order matches visual order
- [ ] Focus is visible on all interactive elements
- [ ] Focus indicator has 3:1 contrast and 2px minimum area

### 2.2 Enough Time
- [ ] Timed interactions can be extended, adjusted, or turned off
- [ ] Auto-updating content can be paused

### 2.3 Seizures and Physical Reactions
- [ ] No content flashes more than 3 times per second

### 2.4 Navigable
- [ ] Pages have descriptive titles
- [ ] Focus order is meaningful
- [ ] Link text describes the purpose (no "click here")
- [ ] Multiple ways to find pages (nav, search, sitemap)
- [ ] Headings and labels are descriptive
- [ ] Skip navigation links are provided

### 2.5 Input Modalities
- [ ] Touch targets are at least 24x24 CSS pixels
- [ ] Dragging actions have non-dragging alternatives
- [ ] No accidental activation (pointer cancellation)

## Understandable

### 3.1 Readable
- [ ] Page language is programmatically set
- [ ] Jargon and abbreviations are defined on first use

### 3.2 Predictable
- [ ] Navigation is consistent across pages
- [ ] Components with same function have consistent labels
- [ ] Changes of context are initiated only by user request

### 3.3 Input Assistance
- [ ] Error messages identify the field and describe the error clearly
- [ ] Labels and instructions are provided for user input
- [ ] Error suggestions are offered when known
- [ ] Important submissions can be reviewed, confirmed, or reversed

## Robust

### 4.1 Compatible
- [ ] HTML validates without significant errors
- [ ] Interactive elements have correct ARIA roles (when needed)
- [ ] Status messages are communicated to assistive technology via live regions

## Evaluation Notes

For each failing check, document:

```markdown
### Issue: {brief description}
- **Criterion**: {WCAG criterion number and name}
- **Severity**: Critical | Major | Minor
- **Location**: {which mockup and element}
- **Current state**: {what it looks like now}
- **Required fix**: {what needs to change}
```
