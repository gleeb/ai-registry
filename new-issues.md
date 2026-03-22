** new issues


*** Testing
a testing fine was created in the same folder and location of the actual script/file, this is not ideomatic, should we create a skill for testing in various langs? 

Also, test files are created everywhere instead of in designated best practive locations like under test/ folder or something, they are being created next to the implementation file or in the root folder

another serious thing i have with the testing is that agents leave wihtout running all the tests, so they end up passing without trealizing that they broke something etc. this is also wasting tokens because more cycles ned top happen

there is a god damn import error:
'render' is declared but its value is never read.ts(6133)
Cannot find module 'react-native-testing-library' or its corresponding type declarations.ts(2307)
and no one is handling it...!!! (eventually something caught it and it cicled back to the implementor, but why didnt the impelementor run the linter or the tests to fix this out for himself? just wasteful cycles

*** validation
it feels like the acceptance validator and the semantic validator can be combined

*** logging task executions:
I think we should crerate a dispatch log template, so that the agnemt will not mess this up
****what was logged:

{"timestamp":"2026-03-22T08:35:09Z","event":"dispatch","dispatch_id":"exec-US001-t3-review-i1","agent":"sdlc-code-reviewer","story":"US-001-scaffolding","hub":"execution","phase":"2","task":"3:Startup budget baseline","model_profile":"gpt-5.3-codex","iteration":1}


**** what i want to be logged:
SDLC Architect Dispatch — Phase 2 Task Review

Story: US-001-scaffolding
Task ID: 3
Task Name: Startup budget baseline
Staging Path: docs/staging/US-001-scaffolding.md
LLD Section: Task 3 — Startup budget baseline

Implementer Summary:
- Created src/shared/performance/startup-budget.ts and src/shared/performance/startup-budget.test.ts
- Reported lint/typecheck pass and staging update

Required Artifacts To Review:
1) src/shared/performance/startup-budget.ts
   - export interface StartupBudget { webInteractiveMs: number }
   - export const STARTUP_BUDGET: StartupBudget
   - export function assertStartupBudget(observedMs: number, budget?: StartupBudget): { pass: boolean; deltaMs: number }
2) src/shared/performance/startup-budget.test.ts
   - tests for pass/fail threshold behavior
   - verifies delta reporting semantics

Boundary Checks:
- No Task 4 typography files implemented.
- No feature/business logic.

Review Focus:
- Spec conformance to exact interfaces/signatures and semantics
- Test adequacy for threshold pass/fail and delta reporting
- Boundary adherence (no scope creep into Task 4 or business logic)

Completion Contract (required):
1) Spec Compliance: PASS/FAIL
2) Issues by severity with file:line references
3) Overall Assessment: Approved / Changes Required

git worktrees:
explore, study the material explain it to me, how do i start working with branches and everything...

** execution flow
i notice there is an issue where for some reason it returns to the coordinator and then returns to the architect for no reason? somethibng is off there.,.. 