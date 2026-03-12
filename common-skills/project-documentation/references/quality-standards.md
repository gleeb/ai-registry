# Documentation Quality Standards

## Audience

All documentation is written for AI agent consumption. The primary reader is a future AI agent that needs to understand the codebase, make informed decisions, and avoid repeating past mistakes.

## Writing Guidelines

### Be Explicit
- State assumptions, constraints, and context clearly
- Never assume the reader has prior context — they are starting from the documentation
- Specify versions, configurations, and environment details when relevant

### Include Rationale
- Always explain WHY, not just WHAT
- Every technical decision needs a rationale section
- Document alternatives that were considered and why they were rejected

### Reference Implementations
- Use exact file paths to point to actual code: `src/features/auth/AuthProvider.tsx`
- Include line numbers when referencing specific logic: `src/api/handler.py:42-58`
- Keep file references current — update them when code moves

### Capture Gotchas
- Document anything that wasted time or caused confusion
- Record service limitations discovered during implementation (e.g., "AWS WebSocket API only allows authorizers on $connect route")
- Note non-obvious configuration requirements

### Link Relationships
- Show how components interact and depend on each other
- Cross-reference related documentation
- Document data flow between systems

## Anti-Patterns

- Vague descriptions without implementation details
- Documentation without file references
- Missing rationale for technical decisions
- Losing context during documentation merges
- Stopping at index files without reading actual content
- Placeholder text that was never filled in
- Stale file references pointing to moved or deleted files

## Structured Formats

Prefer structured formats that agents can parse efficiently:

- **Tables** for comparisons, issue tracking, and decision matrices
- **YAML frontmatter** for machine-readable metadata
- **Checklists** for verification and process steps
- **Code blocks** for commands, configurations, and examples
- **Headers** for scannable document structure
