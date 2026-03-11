# code_review_error_handling

## scenario missing_staging_document

**trigger:** Staging document path from dispatch message does not exist or is empty.

**required_actions:**
- Do not attempt review without plan context.
- Return to sdlc-architect via attempt_completion with blocker status.
- State: "Cannot review — staging document not found at [path]. Provide correct path or re-create staging doc."

**prohibited:** Do not guess the architecture intent when staging document is missing.

## scenario unclear_specification

**trigger:** LLD section in staging document is ambiguous or incomplete for the task being reviewed.

**required_actions:**
- Review what can be assessed with available context.
- Flag ambiguous requirements as "Unable to assess — spec unclear" in the review output.
- Include the ambiguity in the review verdict so the architect can clarify.

## scenario implementation_not_found

**trigger:** Files mentioned in implementer's completion summary do not exist or are unchanged.

**required_actions:**
- Search for the expected implementation in nearby files or alternative paths.
- If still not found, return Changes Required with: "Implementation files not found — expected [files] based on completion summary."

## scenario test_or_build_command_fails

**trigger:** Running verification commands during review produces errors.

**required_actions:**
- Include the command output and error in the review report.
- Categorize as Critical issue if it indicates broken functionality.
- Do not attempt to fix the code — report the failure for the implementer.
