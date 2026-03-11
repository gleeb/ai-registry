# Traceability Matrix Reference

## Overview

This reference defines how to check that requirements flow correctly from higher-level documents to lower-level documents. Every requirement in a parent document must have at least one corresponding entry in each relevant child document.

## Traceability Chains

### Chain 1: PRD → Architecture → HLD → User Stories
```
PRD requirement
  └── Architecture component/decision
        └── HLD section
              └── User Story with acceptance criteria
```

### Chain 2: PRD → Security → DevOps
```
PRD security/privacy NFR
  └── Security plan control
        └── DevOps infrastructure control
```

### Chain 3: PRD → HLD → API Design → Data Architecture
```
PRD feature requirement
  └── HLD component design
        ├── API endpoint contract
        └── Data entity schema
```

### Chain 4: All → Testing Strategy
```
User Story acceptance criteria
  └── Testing strategy test type mapping
        └── Test coverage entry
```

## How to Check Traceability

### Step 1: Extract Requirements
For each source document, extract a list of discrete requirements:
- PRD: user stories, NFRs, constraints, success criteria
- Architecture: components, integration points, technology decisions
- HLD: design sections, acceptance criteria
- Security: controls, policies, compliance requirements
- API Design: endpoints, contracts
- Data Architecture: entities, schemas

### Step 2: Map to Target Documents
For each requirement, look for a corresponding entry in each downstream document:
- Direct mention by name/ID
- Coverage by a broader section that subsumes the requirement
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

Target: 100% for Critical chains, 90%+ for all chains.

## Per-Phase Validation Matrix

### After Phase 1 (PRD)
| Check | Source | Target |
|---|---|---|
| PRD internal consistency | PRD sections | PRD sections |
| 8-dimension validation | PRD | VALIDATION rubric |

### After Phase 2 (Architecture + Security)
| Check | Source | Target |
|---|---|---|
| Architecture covers PRD | PRD capabilities | Architecture components |
| Security covers PRD | PRD security NFRs | Security controls |
| Architecture-Security alignment | Architecture decisions | Security requirements |

### After Phase 3 (Detailed Design)
| Check | Source | Target |
|---|---|---|
| HLD covers Architecture | Architecture components | HLD sections |
| API covers integration points | Architecture integrations | API endpoints |
| Data covers HLD entities | HLD data entities | Data schemas |
| DevOps covers Architecture+Security | Architecture+Security | DevOps controls |
| Design covers user flows | PRD user stories | Design mockups |

### After Phase 4 (Stories + Testing)
| Check | Source | Target |
|---|---|---|
| Stories cover PRD | PRD user stories | User story files |
| Testing covers acceptance criteria | All acceptance criteria | Test type mappings |
| Full chain integrity | PRD → Architecture → HLD → Stories | End-to-end trace |
