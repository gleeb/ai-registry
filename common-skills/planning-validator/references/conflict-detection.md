# Conflict Detection Patterns

## Overview

This reference provides a library of common conflict patterns for cross-validation. In the per-story architecture, conflicts can occur within a story, between stories (via contracts), and between per-story and cross-cutting artifacts.

## Per-Story Conflict Patterns

### PS-001: HLD-API Schema Mismatch
- **Artifacts**: hld.md vs api.md within same story
- **Pattern**: HLD describes a data flow with fields X, Y, Z but API response schema has fields X, Y, W.
- **Detection**: Map HLD data flow fields to API schema fields. Flag mismatches.
- **Resolution**: Align schemas. Determine authoritative source (usually HLD defines the concept, API defines the wire format).

### PS-002: Contract Violation
- **Artifacts**: Story artifacts vs consumed contract in plan/contracts/
- **Pattern**: Story's api.md defines an endpoint response that contradicts the consumed contract's schema definition.
- **Detection**: Compare story's usage of contract fields against the contract definition.
- **Resolution**: Story MUST conform to consumed contract. If story needs the contract changed, escalate to contract owner story.

### PS-003: Auth Model Mismatch
- **Artifacts**: security.md vs api.md within same story
- **Pattern**: Security defines JWT auth but API endpoints specify session-based auth, or auth requirements don't match.
- **Detection**: Extract auth method from security.md and compare with api.md per-endpoint auth.
- **Resolution**: Align to auth-model contract if it exists, otherwise resolve between the two artifacts.

### PS-004: Data Entity Orphan
- **Artifacts**: data.md vs hld.md/api.md within same story
- **Pattern**: data.md defines an entity that no HLD component or API endpoint references.
- **Detection**: Map data entities to HLD components and API endpoints. Flag entities with no references.
- **Resolution**: Remove orphan entity or identify the missing component/endpoint.

## Cross-Story Conflict Patterns

### CS-001: Contract Provider-Consumer Conflict
- **Artifacts**: Provider story artifacts vs consumer story artifacts
- **Pattern**: Provider story's implementation doesn't match the contract definition that consumers depend on.
- **Detection**: Compare provider's actual schema in hld.md/api.md/data.md against contract file.
- **Resolution**: Provider MUST match contract. Update provider artifacts or update contract (triggers consumer re-validation).

### CS-002: Dependency Cycle
- **Artifacts**: story.md dependency manifests across stories
- **Pattern**: US-003 depends on US-005 depends on US-003 (circular).
- **Detection**: Build dependency graph from all depends_on_stories fields. Check for cycles using topological sort.
- **Resolution**: Break the cycle by extracting a shared contract, merging stories, or removing a false dependency.

### CS-003: Duplicate Contract Ownership
- **Artifacts**: Multiple stories claim provides_contracts for the same contract
- **Pattern**: Both US-002 and US-004 list auth-model in provides_contracts.
- **Detection**: Scan all story manifests for provides_contracts. Flag duplicates.
- **Resolution**: Assign single owner (typically the earlier story in execution order).

### CS-004: Orphan Contract
- **Artifacts**: plan/contracts/ file with no consumer stories
- **Pattern**: A contract file exists but no story lists it in consumes_contracts.
- **Detection**: Scan all story manifests for consumes_contracts. Flag contracts with no consumers.
- **Resolution**: Remove the contract (it serves no purpose) or identify the missing consumer story.

## Cross-Cutting Conflict Patterns

### CC-001: Security Rollup Inconsistency
- **Artifacts**: cross-cutting/security-overview.md vs per-story security.md files
- **Pattern**: Security overview states "all endpoints use JWT" but one story's security.md uses API keys.
- **Detection**: Compare aggregate claims in security overview against individual per-story controls.
- **Resolution**: Either update the per-story control to match, or update the overview to reflect the exception.

### CC-002: Testing Coverage Gap
- **Artifacts**: cross-cutting/testing-strategy.md vs story.md acceptance criteria
- **Pattern**: Acceptance criteria exist in a story that have no test type mapping in the testing strategy.
- **Detection**: Map all acceptance criteria across all stories to testing strategy entries. Flag unmapped criteria.
- **Resolution**: Add test coverage for the missing criteria.

### CC-003: DevOps Service Gap
- **Artifacts**: cross-cutting/devops.md vs per-story hld.md files
- **Pattern**: A service defined in a story's HLD has no deployment configuration in the DevOps plan.
- **Detection**: Extract all services/components from per-story HLD files. Check each against DevOps service inventory.
- **Resolution**: Add deployment configuration for the missing service.

## General Conflict Patterns

### G-001: Terminology Drift
- **Artifacts**: Any pair
- **Pattern**: Same concept referred to by different names (e.g., "user" vs "customer" vs "account holder").
- **Detection**: Build a glossary of key terms from each document. Look for synonyms.
- **Resolution**: Establish canonical terminology in the PRD and align all documents.

### G-002: Performance Target Contradiction
- **Artifacts**: PRD NFRs vs architecture vs per-story artifacts
- **Pattern**: PRD says "< 200ms response time" but architecture cannot meet it.
- **Detection**: Extract numeric performance targets. Compare across documents.
- **Resolution**: Align targets. If infeasible, flag as a feasibility issue.

### G-003: Scope Boundary Violation
- **Artifacts**: story.md vs PRD out-of-scope
- **Pattern**: A story includes functionality that the PRD explicitly lists as out of scope.
- **Detection**: Cross-reference story scope against PRD out-of-scope section.
- **Resolution**: Remove the out-of-scope functionality or update the PRD.

## Detection Process

1. Run each pattern against relevant artifacts.
2. For each match, record:
   - Pattern ID
   - Severity (CONFLICT, TENSION, GAP, DRIFT)
   - Source artifact and location
   - Target artifact and location
   - Specific finding
   - Suggested resolution
3. Include all findings in the validation report.
