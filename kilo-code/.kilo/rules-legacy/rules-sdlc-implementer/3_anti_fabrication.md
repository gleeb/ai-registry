# anti_fabrication_rules

## purpose

Prevent agents from claiming work that wasn't done, skipping requirements, or using shortcuts that compromise implementation quality. These rules are enforced at every stage of the implementer's lifecycle.

## deny_rules

### DENY: Claiming a feature is implemented without showing the code

Every claimed implementation must reference specific files and code. "I implemented the login flow" without file references is a violation.

### DENY: Skipping acceptance criteria

Every criterion in the dispatch must be addressed. No criterion may be silently ignored. If a criterion cannot be implemented, HALT and escalate — do not proceed without it.

### DENY: Placeholder implementations

No TODO comments as implementation, no stub functions, no "implement later" markers. Every dispatched requirement must have a working implementation. Placeholder code is not a valid deliverable.

### DENY: Changing acceptance criteria to match what was built

The acceptance criteria come from the plan. The implementation must match the criteria, not the other way around. If a criterion is impossible as written, escalate — do not rewrite it.

### DENY: Simplified versions of requirements without explicit approval

"I implemented a simplified version" is not acceptable unless explicitly approved by the architect or user. If simplification is needed, HALT and request approval before proceeding.

### DENY: Deferring in-scope work to future iterations

Everything in the dispatch scope must be completed in this task. "This can be done later" for in-scope items is a violation. Only out-of-scope improvements discovered during implementation may be deferred.

### DENY: Beginning implementation without reading required context

Do not write any code before reading the staging document and the story's plan artifacts (at minimum story.md and hld.md). These contain architecture decisions, acceptance criteria, and constraints that are prerequisites for correct implementation.

### DENY: Claiming staging document was updated without specifics

"Staging doc updated" or "documentation was updated" without listing specific sections and changes is a violation. Every documentation claim must name the section and describe what was added or changed.

## require_rules

### REQUIRE: Map every acceptance criterion to specific code

For each acceptance criterion in the dispatch, identify the file(s) and lines that implement it. Include this mapping in the completion summary.

### REQUIRE: Run actual verification, not just claim tests pass

Before marking a criterion as verified, run the verification command in this session and capture the output. "Tests pass" without evidence is not verification.

### REQUIRE: If a criterion cannot be implemented, HALT and escalate

Do not skip, simplify, or defer. Return to the architect with a clear explanation of what's blocking the criterion and what options exist.

### REQUIRE: Load project documentation, story plan artifacts, and staging document before coding

These are prerequisites, not optional context. Read docs/index.md (if it exists), the staging document, and the story's plan artifacts via the staging doc's "Plan References" section before writing any code.

### REQUIRE: Update staging document with all changes

Every created file, modified file, technical decision, and issue resolution must be recorded in the staging document. An implementation without documentation updates is incomplete.

### REQUIRE: Include concrete staging doc update summary in completion result

The completion result must list each staging doc section that was updated and what was added or changed. This allows the reviewer to cross-reference claims against actual content.
