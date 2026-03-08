# Universal Skills

Shared capabilities and procedures that all AI agents should follow, regardless of IDE or provider.

---

## File Searching

When asked to find files or content in the codebase:

1. **Start broad, then narrow.** Use glob patterns (`**/*.ts`) or semantic search to survey the landscape before drilling into specific files.
2. **Prefer specialized tools over shell commands.** Use the IDE's built-in search, ripgrep (`rg`), or semantic search rather than `find` + `grep` pipelines.
3. **Respect ignore files.** Honor `.gitignore`, `.cursorignore`, and similar exclusion patterns. Never search inside `node_modules/`, `.git/`, or build output directories unless explicitly asked.
4. **Report what you found.** After searching, summarize the results concisely — list matching files, relevant line numbers, and a brief description of each match.

## Documentation Lookup

When the user asks about a library, framework, or API:

1. **Check local docs first.** Look for a `docs/` folder, inline JSDoc/docstrings, or a README in the relevant package.
2. **Use MCP documentation tools** (e.g., Context7, AWS Docs) when available to fetch up-to-date documentation.
3. **Cite your sources.** Always include the URL or file path where you found the information.
4. **Distinguish between versions.** Be explicit about which version of a library the documentation applies to, especially if the project pins a specific version.

## Code Generation

When generating or modifying code:

1. **Read before writing.** Always read the target file and its surrounding context before making changes.
2. **Match existing style.** Adopt the conventions already present in the codebase (indentation, naming, patterns).
3. **Minimize blast radius.** Make the smallest change that achieves the goal. Avoid unrelated refactors in the same edit.
4. **Verify after editing.** Run linters, type checks, or tests if available to confirm the change is correct.

## Task Management

For complex, multi-step tasks:

1. **Create a plan.** Break the task into discrete steps and track progress.
2. **Work incrementally.** Complete and verify each step before moving to the next.
3. **Communicate blockers.** If something is unclear or missing, ask rather than guess.

## Git Operations

When working with version control:

1. **Never force-push** to shared branches without explicit permission.
2. **Never commit secrets.** Scan staged changes for API keys, tokens, and passwords.
3. **Write clear commit messages.** Use imperative mood, explain *why* not just *what*.
4. **Keep commits atomic.** One logical change per commit for clean history.
