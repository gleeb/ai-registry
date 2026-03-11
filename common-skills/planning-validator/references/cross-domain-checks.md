# Cross-Domain Consistency Checks

## Overview

This reference defines consistency checks between plan documents. In the per-story architecture, checks run at two levels: within a story's artifacts and across stories.

## Validation Posture

Default to NEEDS WORK. For each check:
1. State what was checked.
2. State what evidence was examined (specific sections, field values).
3. State the finding.

Do NOT mark a check as PASS without examining the actual content. "References exist" is insufficient — verify the content matches.

## Per-Story Consistency Checks

### 1. HLD-API Alignment
**Artifacts**: hld.md, api.md within same story folder.

| Check | What to verify |
|---|---|
| Component → endpoint mapping | Every HLD component that exposes functionality has API endpoints |
| Data flow → schema | Data flows in HLD match API request/response schemas |
| Error handling | HLD failure modes have corresponding API error codes |

### 2. HLD-Data Alignment
**Artifacts**: hld.md, data.md within same story folder.

| Check | What to verify |
|---|---|
| Entity coverage | Every data entity in HLD has a schema in data.md |
| Relationship consistency | Entity relationships in HLD match data.md cardinality |
| Lifecycle coverage | Data lifecycle in HLD matches data.md create/update/delete patterns |

### 3. API-Data Alignment
**Artifacts**: api.md, data.md within same story folder.

| Check | What to verify |
|---|---|
| Schema field alignment | API request/response fields match data.md entity fields |
| Query pattern support | API list/filter endpoints have corresponding indexes in data.md |
| Data type consistency | Field types match (e.g., string in API = varchar in data) |

### 4. Security-API Alignment
**Artifacts**: security.md, api.md within same story folder.

| Check | What to verify |
|---|---|
| Auth per endpoint | Every API endpoint has auth requirements matching security.md |
| Rate limiting | Rate limits in security.md reflected in api.md |
| Input validation | Input validation rules in security.md reflected in api.md |

### 5. Contract Compliance
**Artifacts**: story artifacts vs consumed contracts.

| Check | What to verify |
|---|---|
| Schema match | Consumed contract definitions used exactly in story artifacts |
| No local redefinition | Story does not redefine a consumed contract's fields differently |
| Invariant respect | Contract invariants not violated by story's design |

## Cross-Story Consistency Checks

### 6. Technology Stack Alignment
**Artifacts**: All per-story hld.md vs system-architecture.md.

| Check | What to verify |
|---|---|
| Language consistency | All stories use the same backend language as architecture |
| Framework consistency | Framework choices match architecture |
| Database consistency | Database technology matches architecture and data decisions |

### 7. Contract Provider-Consumer Alignment
**Artifacts**: plan/contracts/*.md vs all story artifacts.

| Check | What to verify |
|---|---|
| Provider completeness | Contract file is complete enough for consumers |
| Consumer compliance | All consumers use the contract as defined |
| No conflicting extensions | If consumers extend contracts, extensions don't conflict |

### 8. Cross-Cutting Coverage
**Artifacts**: cross-cutting/* vs per-story artifacts.

| Check | What to verify |
|---|---|
| Security rollup | security-overview.md covers all per-story security.md controls |
| Testing coverage | testing-strategy.md maps all acceptance criteria to test types |
| DevOps coverage | devops.md covers all services from per-story hld.md files |

### 9. Dependency Graph Integrity
**Artifacts**: All story.md dependency manifests.

| Check | What to verify |
|---|---|
| No circular dependencies | No cycles in depends_on_stories graph |
| Execution order consistency | No story ordered before its dependencies |
| Contract ownership | Every contract has exactly one owner story |
| No orphan contracts | Every contract has at least one consumer |

## Severity Classification

| Severity | Definition | Action |
|---|---|---|
| **CONFLICT** | Two artifacts make directly contradictory decisions | MUST resolve before proceeding |
| **TENSION** | Two artifacts make potentially incompatible decisions | SHOULD resolve or acknowledge |
| **GAP** | A decision in one artifact has no counterpart in another | MAY be acceptable if documented |
| **DRIFT** | Same concept uses different terminology | SHOULD align terminology |
