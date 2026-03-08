---
name: code-review
description: Use when reviewing completed implementation work against an architecture plan or spec, evaluating plan alignment, code quality, architecture patterns, and documentation with severity-categorized issues and file:line references.
---

# Code Review

## Overview

Structured code review evaluating implementation against architecture specifications.

**Core principle:** Verify, don't trust. Read the code independently — never rely on implementer claims.

## When to Use

- After an implementation task completes and needs review against the plan
- When the sdlc-architect dispatches to code-reviewer mode
- Before marking any implementation unit as complete

## Review Framework

### 1. Plan Alignment Analysis
- Compare implementation against staging doc/LLD requirements line by line
- Identify missing requirements (not implemented)
- Identify scope creep (implemented but not in spec)
- Assess whether deviations are justified improvements or problems

### 2. Code Quality Assessment
- Error handling, type safety, defensive programming
- Naming conventions, code organization, readability
- Test coverage and test quality
- Security vulnerabilities and performance issues
- Adherence to established project patterns

### 3. Architecture and Design Review
- SOLID principles and separation of concerns
- Integration with existing systems and interfaces
- Scalability and extensibility

### 4. Issue Categorization

| Severity | Criteria | Action |
|----------|----------|--------|
| Critical | Bugs, security issues, spec violations | Must fix |
| Important | Design issues, missing tests, poor patterns | Should fix |
| Suggestion | Style improvements, minor refactors | Nice to have |

Every issue must include:
- **file:line** reference
- What's wrong (specific, not vague)
- How to fix it (actionable recommendation)

## Review Output Format

```
## Spec Compliance: PASS / FAIL
[Specific gaps if FAIL]

## Code Quality
### Strengths
- [What was done well]

### Issues
#### Critical
- file.py:42 — [issue] → [fix]

#### Important
- file.py:78 — [issue] → [fix]

#### Suggestions
- file.py:15 — [suggestion]

## Overall Assessment: Approved / Changes Required
```

## Verdict Rules

- ANY Critical issue → Changes Required
- Important issues (no Critical) → Changes Required
- Only Suggestions → Approved
