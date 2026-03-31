# Best Practices

## Right-Sizing Stories

- Target ~30-60 minutes of agent execution work per story.
- A story touching more than 3 architecture components is probably too large. Split it.
- A story with more than 8 acceptance criteria is probably too large. Split it.
- A story with only 1 acceptance criterion might be too small — consider merging with related story.
- The scaffolding story (US-001) is an exception to sizing rules — it may be minimal.

## Spec Quoting

- Every requirement in a story MUST quote the exact PRD text with section number.
- Format: `Per PRD {section}: "{verbatim text}"`
- Never paraphrase requirements. If you cannot find the exact PRD text, the requirement may not exist.
- Acceptance criteria MUST trace to specific PRD sections.

## Files Affected

- List specific file paths, not categories ("auth files").
- Use `CREATE` for new files, `MODIFY` for changes to existing files.
- Files must be consistent with architecture component boundaries.
- A file appearing in two stories indicates a potential shared contract or incorrect story boundaries.

## No Gold-Plating

- If a story includes requirements not in the PRD, flag with `[ADDITION]`.
- Require explicit user approval for any additions.
- "Users would expect this" is not PRD evidence. Push back.
- "Industry best practice" is not PRD evidence. Push back.
- If the user wants to add scope, help them identify which PRD section should be updated.

## Dependency Manifests

- Every story MUST have a complete dependency manifest.
- `prd_sections` and `architecture_components` are never empty.
- `candidate_domains` always includes `hld`.
- Include `design` only when the story has user-facing UI.
- Include `security` when the story handles auth, PII, or sensitive operations.
- Include `api` when the story exposes or consumes HTTP/gRPC/WebSocket endpoints.
- Include `data` when the story creates or modifies persistent data entities.

## Contract Identification

- If two stories both reference the same data shape, extract it as a contract.
- If two stories both need the same API contract, extract it as a contract.
- Auth models are almost always shared contracts.
- Error response formats are often shared contracts.
- When in doubt, extract a contract. Over-documenting shared interfaces is better than under-documenting.

## Scaffolding Story

- US-001-scaffolding ALWAYS comes first with execution_order: 1.
- It covers project setup, dependency installation, folder structure, CI/CD basics.
- It provides contracts for project-level patterns (error handling format, logging format, etc.).
- Acceptance criteria: project builds, tests run, linting passes, CI pipeline executes.
