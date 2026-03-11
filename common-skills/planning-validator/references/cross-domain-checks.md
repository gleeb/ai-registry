# Cross-Domain Consistency Checks

## Overview

This reference defines the specific consistency checks to run between sibling plan documents. These checks detect contradictions, misalignments, and gaps where two or more documents make incompatible decisions.

## Check Categories

### 1. Technology Stack Alignment

**Documents**: Architecture, HLD, API Design, DevOps, Data Architecture

| Check | What to verify |
|---|---|
| Language consistency | Same backend language in Architecture and HLD component specs |
| Framework consistency | Framework choice in Architecture matches HLD implementation approach |
| Database consistency | DB technology in Architecture matches Data Architecture choice |
| API protocol consistency | API style in Architecture (REST/gRPC/GraphQL) matches API Design spec |
| Runtime consistency | Runtime in Architecture matches DevOps container/deployment config |
| Dependency consistency | Libraries/SDKs consistent across documents |

### 2. Data Model Consistency

**Documents**: HLD, API Design, Data Architecture

| Check | What to verify |
|---|---|
| Entity names | Same entities use same names across documents |
| Field definitions | Field names and types in API schemas match Data Architecture schemas |
| Relationship cardinality | Relationships described in HLD match Data Architecture ERD |
| Data flows | Data flow in HLD matches API request/response contracts |

### 3. Security Alignment

**Documents**: Security, Architecture, API Design, DevOps

| Check | What to verify |
|---|---|
| Auth approach | Authentication method in Security matches API Design auth spec |
| Encryption | Encryption requirements in Security reflected in Architecture and DevOps |
| Secret management | Secret handling in Security matches DevOps secrets approach |
| Access control | Authorization model in Security matches API Design per-endpoint auth |
| Data protection | Data classification in Security matches Data Architecture handling |
| Network security | Network restrictions in Security reflected in DevOps infrastructure |

### 4. Performance Targets

**Documents**: PRD, Architecture, API Design, Testing Strategy

| Check | What to verify |
|---|---|
| Latency targets | PRD performance NFRs match Architecture capacity planning |
| Rate limits | API Design rate limits consistent with Architecture scalability |
| Load targets | Architecture load projections match Testing Strategy performance tests |
| Caching alignment | Architecture caching strategy consistent with Data Architecture caching |

### 5. Environment Requirements

**Documents**: DevOps, Testing Strategy

| Check | What to verify |
|---|---|
| Test environments | Testing Strategy test env requirements match DevOps environment inventory |
| CI/CD integration | Testing Strategy QA gates match DevOps pipeline stages |
| Data requirements | Testing Strategy test data needs match DevOps environment provisioning |

### 6. User Flow Coverage

**Documents**: PRD, HLD, Design

| Check | What to verify |
|---|---|
| Screen coverage | Every user story with UI has a corresponding design mockup |
| Flow completeness | User flows in PRD are fully represented in Design screen inventory |
| Error states | Error states in HLD acceptance criteria have corresponding design mockups |
| Responsive design | If PRD specifies responsive, Design includes breakpoint mockups |

## Severity Classification

| Severity | Definition | Action |
|---|---|---|
| **CONFLICT** | Two documents make directly contradictory decisions | MUST resolve before proceeding |
| **TENSION** | Two documents make potentially incompatible decisions | SHOULD resolve or explicitly acknowledge |
| **GAP** | A decision in one document has no counterpart in another | MAY be acceptable if documented |
| **DRIFT** | Same concept uses different terminology across documents | SHOULD align terminology |
