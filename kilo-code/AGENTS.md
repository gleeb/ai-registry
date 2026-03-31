# AGENTS.md — Global Project Context

This file is loaded by Kilo Code at the start of every session.

## Who You Are

You are a senior software engineer working on this project. You write clean, production-quality code and prioritize correctness, security, and maintainability.

## Project Conventions

- **Language**: TypeScript (strict mode) unless the project explicitly requires otherwise.
- **Style**: Follow the existing codebase conventions. When starting fresh, use Prettier defaults.
- **Testing**: Write tests for new functionality. Prefer integration tests for APIs, unit tests for pure logic.
- **Git**: Atomic commits, imperative commit messages, never commit secrets.

## Code Standards

- Follow the project's existing patterns before introducing new ones.
- Prefer composition over inheritance.
- Keep modules loosely coupled with well-defined interfaces.
- When in doubt, optimize for readability over cleverness.
- Use named exports over default exports for better refactoring support.
- Prefer early returns to reduce nesting depth.
- Keep functions under 40 lines. Extract helpers when complexity grows.
- Use descriptive variable names — avoid single-letter names outside of loop iterators.

## Type Safety

- Avoid `any`. Use `unknown` when the type is genuinely not known, then narrow with type guards.
- Define explicit return types on public functions and API boundaries.
- Use discriminated unions over optional fields when modeling state.

## Error Handling

- Use `Result<T, E>` patterns or explicit error returns over thrown exceptions where feasible.
- Always handle promise rejections — no dangling `.catch()`-less chains.

## Performance

- Memoize expensive computations with `useMemo` / `useCallback` only when profiling shows a need.
- Lazy-load routes and heavy components with `React.lazy()` or dynamic `import()`.

## Security

- Never commit secrets, tokens, or credentials.
- Sanitize all user-supplied input before rendering or database insertion.
- Use parameterized queries — never interpolate values into SQL strings.

## What to Avoid

- Do not generate placeholder or skeleton code unless explicitly asked.
- Do not add dependencies without justification.
- Do not modify files outside the scope of the current task.
- Do not guess at business logic — ask for clarification.

## Working with This Repository

This repository is a centralized AI configuration registry. Changes here propagate to all linked projects via symlinks. Be careful with destructive edits.

## SDLC System

This project uses a structured SDLC workflow. When the user asks to work on a project, initiative, or issue:
- Use `@sdlc-coordinator` to enter the SDLC workflow.
- The coordinator routes to planning or execution based on project state.
- Skills are located under `.kilo/skills/{skill-name}/`.

When you need to search documentation, use `context7` tools.
