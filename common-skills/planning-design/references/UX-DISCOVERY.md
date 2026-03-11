# UX Discovery Reference

## Purpose

UX Discovery is the first phase of the enhanced Design workflow. It grounds all design decisions in user research rather than assumptions. For planning purposes, this phase produces lightweight personas, journey maps, and heuristic assessments — not full UX research studies.

## Persona Definition

For each primary user type identified in the PRD:

```markdown
## Persona: {Name}

**Role**: {user role from PRD}
**Goals**: {what they want to accomplish}
**Pain points**: {frustrations with current state}
**Tech comfort**: {low / medium / high}
**Primary device**: {mobile / desktop / tablet}
**Accessibility needs**: {any known accessibility requirements}

### Key scenarios
1. {Scenario 1: what they do, when, why}
2. {Scenario 2: what they do, when, why}

### Success metrics
- {How do we know this persona is satisfied?}
```

## Journey Mapping

For each primary user flow in the story:

```markdown
## Journey: {Flow Name}

| Stage | Action | Thinking | Feeling | Pain Points | Opportunities |
|-------|--------|----------|---------|-------------|---------------|
| Discover | {what user does} | {what they're thinking} | {emotion} | {friction} | {improvement} |
| Engage | ... | ... | ... | ... | ... |
| Complete | ... | ... | ... | ... | ... |
| Return | ... | ... | ... | ... | ... |
```

## Usability Heuristics (Nielsen's 10)

Evaluate each story's UI flows against:

1. **Visibility of system status**: Is the user always informed about what's happening?
2. **Match between system and real world**: Does the language match the user's mental model?
3. **User control and freedom**: Can users easily undo, redo, or exit?
4. **Consistency and standards**: Do similar elements behave the same way?
5. **Error prevention**: Does the design prevent errors before they occur?
6. **Recognition over recall**: Can users recognize options rather than remembering them?
7. **Flexibility and efficiency**: Are there shortcuts for experienced users?
8. **Aesthetic and minimalist design**: Is irrelevant information removed?
9. **Error recovery**: Are error messages clear and actionable?
10. **Help and documentation**: Is help available when needed?

## Output Format

The UX Discovery phase produces notes within the story's design documentation, not a separate file. Include:

- Personas relevant to this story
- Journey map for the primary flow
- Heuristic assessment flagging potential issues
- Recommendations that feed into subsequent design phases
