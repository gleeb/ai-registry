# Decision Guidance

## When to Split a Story

Split when ANY of these conditions hold:

- Story touches more than 3 architecture components.
- Story has more than 8 acceptance criteria.
- Story has both backend and frontend work that could be independently useful.
- Story modifies files that belong to another story's primary scope.
- Execution estimate exceeds ~60 minutes of agent work.

## When to Merge Stories

Merge when ALL of these conditions hold:

- Both stories touch the same component exclusively.
- Neither story is independently useful (both need the other to deliver value).
- Combined acceptance criteria count is 8 or fewer.
- Combined execution estimate is under 60 minutes.

## Contract Ownership Decisions

| Situation | Owner |
|-----------|-------|
| Auth model | The story that implements authentication (usually US-002 or US-003) |
| Data entity used by multiple stories | The story that first defines and creates the entity |
| API error format | The scaffolding story (US-001) |
| Shared DTOs | The story that defines the source data model |
| Event schemas (if event-driven) | The story that publishes the event |

## Execution Order Decisions

1. Scaffolding (US-001) is always order 1.
2. Stories that provide contracts must come before their consumers.
3. Backend stories before frontend stories that depend on them (unless there's a mock/stub strategy).
4. Stories with no dependencies on other stories can run in parallel (same execution_order number).
5. If two stories have a circular dependency, one of the following is true:
   - They should be merged into one story.
   - A shared contract is missing.
   - The dependency is actually one-directional and the manifest is wrong.

## Candidate Domain Decisions

| Story Type | Candidate Domains |
|------------|-------------------|
| Pure backend service | hld, api, data, security |
| Pure frontend feature | hld, design |
| Full-stack feature with API | hld, api, data, security, design |
| Infrastructure/scaffolding | hld |
| Data migration | hld, data |
| Auth/authorization feature | hld, api, data, security |
| Reporting/analytics feature | hld, api, data |

## Greenfield vs. Incremental Decisions

### Greenfield

- Decompose everything from scratch.
- Create all story folders and contracts.
- Full PRD coverage check.

### Incremental

- Read existing stories first.
- Only modify affected stories.
- Preserve unaffected story folder structure.
- Mark removed scope as `status: removed` — never delete.
- If new scope requires a new story, add it with the next available US number.
- If scope moves between existing stories, update both stories and their dependency manifests.
