# Accessibility Testing Protocol (WCAG 2.2 AA)

## Purpose

This reference defines the accessibility testing approach for the Testing Strategy agent. It covers automated testing tools, manual test protocols, and CI/CD integration for ensuring WCAG 2.2 AA compliance.

## Test Categories

### Automated Testing

Automated tools catch approximately 30-40% of WCAG violations. They are necessary but not sufficient.

| Tool | What It Tests | Integration Point |
|------|--------------|-------------------|
| axe-core | ARIA, color contrast, structure, forms, landmarks | Unit/integration tests, CI pipeline |
| Lighthouse | Performance, a11y, SEO, best practices | CI pipeline, PR checks |
| Pa11y | WCAG conformance, HTML validation | CI pipeline, scheduled scans |
| eslint-plugin-jsx-a11y | React/JSX accessibility rules | Linting (pre-commit) |

### Manual Testing Protocol

Manual testing catches the remaining 60-70% of issues. Required for each story with UI:

#### Keyboard Navigation
1. Tab through the entire flow without mouse.
2. Verify focus order matches visual order.
3. Verify focus indicator is visible (3:1 contrast, 2px minimum).
4. Verify no keyboard traps.
5. Verify all interactive elements are reachable.
6. Verify Enter/Space activate buttons and links.
7. Verify Escape closes modals and popups.
8. Verify arrow keys navigate within composite widgets (tabs, menus, grids).

#### Screen Reader Testing
1. Test with at least one screen reader (VoiceOver on macOS, NVDA on Windows).
2. Verify page title is announced on navigation.
3. Verify headings provide a meaningful outline.
4. Verify images have appropriate alt text.
5. Verify form inputs announce their labels.
6. Verify error messages are announced when they appear.
7. Verify dynamic content updates are announced via live regions.
8. Verify landmark regions are defined (main, nav, header, footer).

#### Visual Testing
1. Zoom to 200% — verify no content is lost or overlapping.
2. Zoom to 400% — verify reflow works (no horizontal scrolling at 320px).
3. Enable high contrast mode — verify content is still readable.
4. Disable CSS — verify content is still meaningful and ordered.
5. Check motion — verify animations respect `prefers-reduced-motion`.

## Component Patterns

Common accessible patterns for interactive components:

| Component | Pattern | Key Requirements |
|-----------|---------|-----------------|
| Modal | Dialog pattern | Focus trap, Escape to close, return focus on close |
| Tabs | Tablist pattern | Arrow keys between tabs, Enter/Space to activate |
| Dropdown | Listbox or Combobox | Arrow keys to navigate, Enter to select, Escape to close |
| Toast/Alert | Alert or Status role | Live region announcement, auto-dismiss optional |
| Data Table | Table with headers | th scope, caption, sortable column announcements |
| Form | Fieldset/Legend | Labels, error association, required indication |
| Navigation | Nav landmark | aria-label for multiple navs, current page indicator |

## CI/CD Integration

### Pre-commit
- eslint-plugin-jsx-a11y (or framework equivalent) catches code-level issues.

### Pull Request Checks
- axe-core integration tests run against rendered components.
- Lighthouse accessibility score threshold (e.g., >= 90).
- Pa11y checks against deployed preview environment.

### Staging Gate
- Full manual test protocol for changed screens.
- Screen reader testing for new/changed flows.
- Keyboard navigation test for new/changed interactive elements.

### Production Monitoring
- Scheduled Pa11y scans (weekly) against production.
- Lighthouse CI tracking over time.

## Test Reporting

For each accessibility test cycle, report:

```markdown
## Accessibility Test Report: {Story/Feature}

### Automated Results
- axe-core: {pass/fail count}
- Lighthouse a11y score: {score}
- Pa11y: {violation count}

### Manual Results
- Keyboard navigation: {pass/fail with details}
- Screen reader: {pass/fail with details}
- Visual zoom: {pass/fail with details}

### Issues Found
| # | Severity | WCAG Criterion | Description | Component | Fix Required |
|---|----------|---------------|-------------|-----------|--------------|
| 1 | Critical | 1.4.3 | Contrast ratio 2.8:1 on CTA button | LoginForm | YES |
| 2 | Major | 2.1.1 | Dropdown not keyboard accessible | FilterMenu | YES |

### Overall: PASS / FAIL
```
