# Criterion Mapping Template

Use this structure to systematically map each acceptance criterion to its implementation evidence before generating the final report.

## Per-Criterion Mapping

For each acceptance criterion from `story.md`:

```
CRITERION [N]: [exact text from story.md]

1. IMPLEMENTING CODE:
   - Primary file: [file:line range]
   - Supporting files: [file:line range] (if any)
   - How this code satisfies the criterion: [brief explanation]

2. VERIFICATION METHOD:
   - Type: [test / command / manual inspection / build check]
   - Command: [exact command to run]
   - Expected outcome: [what PASS looks like]

3. EVIDENCE:
   - Command run: [yes/no]
   - Output: [summary or full output]
   - Exit code: [code]
   - Matches expected: [yes/no]

4. VERDICT: [PASS / FAIL / UNABLE TO VERIFY]
   - If FAIL: [what's wrong — missing, broken, or incomplete]
   - If UNABLE TO VERIFY: [why — no test, ambiguous criterion, infrastructure issue]
```

## Mapping Strategies

| Criterion Type | Verification Approach |
|---------------|----------------------|
| Functional behavior | Run tests, call API, check UI rendering |
| Performance target | Run benchmark, measure metric, compare to target |
| Data model | Inspect schema, run migration, check constraints |
| API endpoint | Call endpoint, verify response shape and status |
| Error handling | Trigger error condition, verify graceful handling |
| Security control | Attempt unauthorized access, verify rejection |
| UI/UX requirement | Inspect component, check accessibility, verify layout |
| Integration | Run integration test, verify cross-component flow |

## Common Pitfalls

- **Criterion maps to no code**: The feature may not be implemented — report FAIL
- **Code exists but no test**: Write the verification command yourself (curl, node -e, etc.) — do not skip
- **Criterion is ambiguous**: Report UNABLE TO VERIFY with explanation — do not guess
- **Multiple files implement one criterion**: List all contributing files, verify the integration
