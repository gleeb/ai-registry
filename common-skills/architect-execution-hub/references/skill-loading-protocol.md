# Skill Loading Protocol

Maps the story manifest's `tech_stack` entries to available skills, and includes skill paths in dispatch messages.

## Skill Mapping

Read the `tech_stack` array from the story manifest and map each entry:

| Tech Stack Entry | Skill Path | Notes |
|-----------------|------------|-------|
| `react-native` | `common-skills/react-native/` | Performance budgets, platform patterns |
| `typescript` | (built-in) | No separate skill needed |
| `expo` | (covered by react-native skill) | Included in RN skill guidance |
| `node` | (built-in) | No separate skill needed |
| `python` | (built-in) | No separate skill needed |

This table should be extended as new technology skills are added to the registry.

## Loading Process

1. Read `tech_stack` from story manifest.
2. For each entry, look up the skill path in the mapping table above.
3. Verify the skill exists at the mapped path (check for SKILL.md).
4. Collect all valid skill paths into a `TECH_SKILLS` list.
5. If a `tech_stack` entry has no mapped skill and is not built-in, note it as a gap — do not block execution.

## Including Skills in Dispatches

### Implementer Dispatch

Add the `TECH SKILLS` section to the implementer dispatch message:

```
TECH SKILLS:
- react-native (path: common-skills/react-native/)
  Load and apply patterns from this skill during implementation.
```

The implementer is responsible for loading and following each skill's guidance.

### Reviewer Dispatch

Add the `TECH SKILLS` section to the reviewer dispatch message:

```
TECH SKILLS:
- react-native (path: common-skills/react-native/)
  Verify implementation follows this skill's patterns and performance budgets.
```

The reviewer checks that skill patterns were followed and performance budgets are met.

## Missing Skills

If a `tech_stack` entry has no corresponding skill:

1. Note it in the staging document under Tech Stack & Loaded Skills: `[tech] — no skill available`
2. Proceed with implementation — the implementer uses general best practices
3. Consider creating the skill after the story completes (flag for future work)
