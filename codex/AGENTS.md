# Codex / Windsurf Agent Instructions

## General Behavior

- Read the full task description before starting work.
- Break complex tasks into smaller steps and complete them sequentially.
- Always read a file before editing it.
- Match the existing code style of the project.

## Code Standards

- Use TypeScript with strict mode where applicable.
- Prefer functional, declarative patterns over imperative ones.
- Use meaningful names for variables, functions, and types.
- Handle all error paths explicitly.

## Safety

- Never commit secrets, credentials, or API keys.
- Never run destructive commands (e.g., `rm -rf`, `git push --force`) without explicit confirmation.
- Validate assumptions by reading code and running tests before making changes.

## Documentation

- Update relevant documentation when changing behavior.
- Add inline comments only for non-obvious logic or trade-offs.
