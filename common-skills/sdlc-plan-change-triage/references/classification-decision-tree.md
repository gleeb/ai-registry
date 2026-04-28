# Classification decision tree

Use after the forward-impact scan (skill §Step 3) has produced
`affected_stories.{completed, in_flight, planned}`.

The taxonomy is ordered. Pick the **smallest** class consistent with
the evidence.

## Decision flow

```
START
  │
  ├── Does the change invalidate architecture.md, the primary
  │   platform/language/persistence layer, or a cross-cutting contract
  │   ≥ half of stories depend on?
  │     │
  │     ├── YES → Class 4 (Foundational). Stop.
  │     │
  │     └── NO  → continue
  │
  ├── Is `affected_stories.completed` non-empty AND any completed
  │   story's AC is materially contradicted by the change?
  │     │
  │     ├── YES → Class 3 (Multi-story replan).
  │     │        Open P21 Category C incident(s) for the affected
  │     │        completed stories on the routing pass.
  │     │        Stop.
  │     │
  │     └── NO  → continue
  │
  ├── Does `affected_stories.planned` contain ≥ 2 entries
  │   OR does the change retire an external integration referenced
  │   by ≥ 2 stories?
  │     │
  │     ├── YES → Class 3 (Multi-story replan). Stop.
  │     │
  │     └── NO  → continue
  │
  ├── Does the change fit cleanly into the active or next-up story —
  │   shared implementation context, no new external integration,
  │   `affected_stories.planned` empty?
  │     │
  │     ├── YES → Class 1 (Additive within active story). Stop.
  │     │
  │     └── NO  → continue
  │
  └── The change adds net-new capability with a clean scope boundary,
      and no existing stories are invalidated.
        →   Class 2 (Additive new story). Stop.
```

## Tie-breaking rules

- **Class 1 vs Class 2.** When the change could either be absorbed into
  the active story or stand alone as a new story:
  - If the change adds an AC that **shares implementation context**
    (same files, same components, same tests) with an existing AC in
    the active story → Class 1.
  - If the change is **independent** (different files, different
    components, reusable across future stories) → Class 2.
  - When ambiguous, prefer Class 2. Class 2 is reversible (the new
    story can be merged into another story later); Class 1 amendments
    are harder to extract once committed.

- **Class 2 vs Class 3.** If a single new story is added but adding it
  forces re-scoping of an existing planned story (e.g., the new story
  takes over scope that planned US-008 was going to cover), the
  combined operation is Class 3 — the planned story is `affected`.

- **Class 3 vs Class 4.** Multi-story replans stay Class 3 unless they
  invalidate `architecture.md` or a cross-cutting contract that ≥ half
  of stories depend on. "Drop the OpenAI provider" is Class 3 even if
  3 stories are affected, because `architecture.md`'s provider
  abstraction stays intact (the abstraction supports plug-out). "Drop
  all external providers and ship a local-only model" is Class 4
  because `architecture.md`'s integration topology dissolves.

## Worked examples

### Example 1 — "Add a title field to the photo form" (mid-US-004)

- `affected_artifacts`: US-004/story.md (AC append), US-004/api.md
  (request schema field).
- `affected_stories.planned`: empty.
- `affected_stories.completed`: empty.
- New external integration: no.
- Verdict: **Class 1**.

### Example 2 — "Add a model-selector dropdown" (mid-US-004, model selector reusable)

- `affected_artifacts`: ambiguous — could be US-004/story.md (AC
  append) or new US-00X.
- `affected_stories.planned`: empty.
- `affected_stories.completed`: empty.
- Tie-break: model-selector is **independent** (different files —
  settings UI vs photo intake UI) and **reusable** across future
  stories that pick providers.
- Verdict: **Class 2**.

### Example 3 — "Drop OpenAI; require free-model selector after OPENROUTER_API_KEY set"

- `affected_artifacts`: architecture.md (provider abstraction note),
  required-env.md (remove `OPENAI_API_KEY`),
  external-contracts/openai.md (retire), US-004/api.md (provider
  refs), US-007/story.md (provider-selection scope), US-008/story.md
  (settings UI).
- `affected_stories.planned`: US-007, US-008 (2 entries).
- `affected_stories.completed`: empty.
- New external integration: no (OpenRouter already declared).
- Verdict: **Class 3** (planned ≥ 2, AND retires integration referenced
  by ≥ 2 stories — either condition alone suffices).

### Example 4 — "Change target platform from web to desktop"

- `affected_artifacts`: architecture.md (target platform — primary
  field), every story (every story.md is web-shaped), every api.md
  (browser fetch vs Electron / Tauri IPC), every design/ folder (web
  mockups vs desktop mockups).
- Verdict: **Class 4**. Architecture.md primary platform field is the
  Class 4 trigger.
