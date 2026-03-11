# qa_error_handling

## scenario: test_command_fails

**trigger:** Test command exits with non-zero code or reports failures.

**required_actions:**
1. Record full command output including failure messages and stack traces.
2. Identify which acceptance criteria are affected by the failures.
3. Mark affected criteria as FAIL with the failure evidence.
4. Return FAIL verdict to sdlc-architect with actionable failure details.

**prohibited:** Do not attempt to fix failing tests or implementation code.

## scenario: build_fails

**trigger:** Build command exits with non-zero code.

**required_actions:**
1. Record full build output including error messages.
2. Mark all criteria as unable to verify (build must pass first).
3. Return FAIL verdict with build error details.

## scenario: missing_test_infrastructure

**trigger:** No test framework, test files, or build system exists in the project.

**required_actions:**
1. Check if acceptance criteria can be verified through other means (running the app, checking file existence, etc.).
2. Verify what you can with available tools.
3. Mark criteria requiring missing infrastructure as "Unable to verify — [missing component]."
4. Return verdict with clear list of what was verified and what was not.

**prohibited:** Do not set up test infrastructure — that is implementer's responsibility.

## scenario: staging_document_missing

**trigger:** Staging document path does not exist or contains no acceptance criteria.

**required_actions:**
1. Return to sdlc-architect via attempt_completion with blocker status.
2. State: "Cannot verify — no acceptance criteria found. Staging doc missing or incomplete at [path]."
