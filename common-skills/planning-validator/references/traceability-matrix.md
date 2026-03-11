# Traceability Matrix Reference

## Overview

This reference defines how to check that requirements flow correctly through the per-story planning architecture. Traceability is checked at two levels: within a single story (per-story) and across stories (cross-story via contracts and dependency manifests).

## Per-Story Traceability Chains

### Chain 1: PRD → Story → Story Artifacts
```
PRD section (via story.md prd_sections)
  └── Story acceptance criterion
        ├── hld.md design unit
        ├── api.md endpoint
        ├── data.md entity
        └── security.md control
```

### Chain 2: Architecture → Story → Story Artifacts
```
Architecture component (via story.md architecture_components)
  └── Story scope statement
        └── hld.md component design
              ├── api.md endpoint (if api in domains)
              └── data.md schema (if data in domains)
```

### Chain 3: Contract → Story Artifacts
```
Consumed contract (via story.md consumes_contracts)
  └── Story artifacts must USE the contract definition
        ├── api.md schemas reference contract
        ├── data.md schemas reference contract
        └── security.md auth aligns with contract
```

## Cross-Story Traceability Chains

### Chain 4: PRD → Stories (full coverage)
```
PRD section 7 user story groups
  └── Story Decomposer output
        └── story.md files (each with prd_sections in manifest)
              └── Every PRD section covered by at least one story
```

### Chain 5: Architecture → Stories (full coverage)
```
Architecture component inventory
  └── story.md files (each with architecture_components in manifest)
        └── Every component referenced by at least one story
```

### Chain 6: Contracts → Provider/Consumer Stories
```
Contract file in plan/contracts/
  └── Owner story (provides_contracts)
  └── Consumer stories (consumes_contracts)
        └── Provider defines, consumers use — no contradictions
```

### Chain 7: Stories → Cross-Cutting Concerns
```
All story acceptance criteria
  └── Testing Strategy (plan/cross-cutting/testing-strategy.md)
        └── Every AC mapped to a test type

All per-story security.md
  └── Security Overview (plan/cross-cutting/security-overview.md)
        └── Aggregate covers all per-story controls

All per-story hld.md
  └── DevOps (plan/cross-cutting/devops.md)
        └── All services have deployment config
```

## How to Check Traceability

### Step 1: Extract Requirements

For each source document, extract a list of discrete requirements:
- PRD: sections, user story groups, NFRs, constraints
- Architecture: components, integration points, technology decisions
- Stories: acceptance criteria, dependency manifests
- Contracts: definitions, invariants, owner/consumer relationships

### Step 2: Map to Target Documents

For each requirement, look for a corresponding entry in downstream documents:
- Direct reference (by section number, story ID, contract name)
- Coverage by a broader element that subsumes the requirement
- Explicit exclusion with rationale (acceptable)

### Step 3: Classify Results

| Classification | Meaning | Severity |
|---|---|---|
| TRACED | Requirement has corresponding downstream entry | OK |
| UNTRACED | Requirement has no downstream entry | Critical |
| PARTIALLY_TRACED | Downstream entry covers some but not all aspects | Warning |
| ORPHANED | Downstream entry has no upstream requirement | Info |
| EXCLUDED | Explicitly excluded with rationale | OK |

### Step 4: Calculate Coverage

```
Coverage = TRACED / (TRACED + UNTRACED + PARTIALLY_TRACED) * 100%
```

Target: 100% for critical chains (PRD → stories, stories → artifacts), 90%+ for all chains.

## Per-Phase Validation Matrix

### After Phase 1 (PRD)
| Check | Source | Target |
|---|---|---|
| PRD internal consistency | PRD sections | PRD sections |

### After Phase 2 (Architecture + Story Decomposition)
| Check | Source | Target |
|---|---|---|
| Architecture covers PRD | PRD capabilities | Architecture components |
| Stories cover PRD | PRD section 7 groups | story.md prd_sections |
| Stories cover Architecture | Architecture components | story.md architecture_components |
| Contracts identified | Shared interfaces | plan/contracts/ |
| Dependency manifests complete | story.md files | All required fields present |

### After Phase 3 (Per-Story, per story)
| Check | Source | Target |
|---|---|---|
| Artifacts cover ACs | story.md acceptance criteria | hld.md + api.md + data.md + security.md |
| Contract compliance | Consumed contracts | Story artifact schemas |
| Technology alignment | Architecture decisions | hld.md choices |

### After Phase 4 (Cross-Cutting)
| Check | Source | Target |
|---|---|---|
| Testing covers all ACs | All story.md acceptance criteria | testing-strategy.md |
| Security rollup covers all | All per-story security.md | security-overview.md |
| DevOps covers all services | All per-story hld.md | devops.md |
| Full chain integrity | PRD → Architecture → Stories → Artifacts | End-to-end trace |
