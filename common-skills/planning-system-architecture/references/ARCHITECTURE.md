# System Architecture Template

## Purpose
Use this format when drafting or refining a System Architecture specification. The architecture document is the single source of truth for system topology, component boundaries, technology choices, and integration patterns. It must be validated before downstream planning (HLD, API Design, Data Architecture, DevOps) proceeds.

## Contract gates
- REQUIRE all 11 sections to be substantive before the architecture is considered complete.
- REQUIRE technology choices to include rationale and trade-offs — no unsubstantiated recommendations.
- REQUIRE component boundaries to be justified — no arbitrary splits.
- DENY proceeding to HLD/API/Data planning before user validates the architecture.
- ALLOW provisional draft only when clearly marked `PROVISIONAL - NOT VALIDATED`.

---

## Template

### 1) Metadata

| Field | Value |
|-------|-------|
| Document Version | 0.1.0 |
| Last Updated | [date] |
| Author | [name] |
| Status | Draft / Review / Approved |
| PRD Reference | plan/prd.md (version/date) |

---

### 2) Architecture Overview

**Topology**
- [Monolith / Microservices / Serverless / Hybrid / Other — with brief justification]
- [Key structural decisions: e.g., modular monolith with bounded contexts, event-driven microservices, serverless-first with Lambda + API Gateway]

**Key Decisions Summary**
- [2–4 bullet points capturing the most consequential architectural choices]
- [Each decision should be traceable to an ADR in section 9]

---

### 3) Component Inventory

| Component | Responsibility | Technology | Dependencies |
|-----------|----------------|------------|--------------|
| [Name] | [What it does; bounded context] | [Language, framework, runtime] | [Upstream/downstream components] |
| [Name] | [What it does; bounded context] | [Language, framework, runtime] | [Upstream/downstream components] |
| ... | ... | ... | ... |

**Component Boundary Rationale**
- [For each component: why it exists as a separate unit; what would break or couple if merged with another]

---

### 4) Integration Patterns

**Synchronous**
- [REST / gRPC / GraphQL — where used, why]
- [Request/response flow for key operations]
- [Timeout and retry policies]

**Asynchronous**
- [Message queue / event bus / pub-sub — technology and topology]
- [Event types and ownership]
- [At-least-once vs exactly-once semantics; idempotency strategy]

**External Integrations**
- [Third-party APIs, webhooks, SDKs]
- [Authentication and rate limiting]

**Integration Diagram**
```
[Text or Mermaid diagram showing component-to-component communication]
```

---

### 5) Technology Stack

| Layer | Choice | Rationale | Trade-offs |
|-------|--------|-----------|------------|
| Language(s) | [e.g., TypeScript, Python] | [Why: team expertise, ecosystem, performance] | [What we give up] |
| Framework(s) | [e.g., Next.js, FastAPI] | [Why: fit for use case, conventions] | [What we give up] |
| Database(s) | [e.g., PostgreSQL, Redis] | [Why: consistency model, scale characteristics] | [What we give up] |
| Infrastructure | [e.g., AWS, GCP, Vercel] | [Why: cost, region, managed services] | [What we give up] |
| Other | [Message queue, cache, search, etc.] | [Why] | [What we give up] |

---

### 6) Cross-Cutting Concerns

**Logging**
- [Structured logging format; log levels; what is logged]
- [Aggregation and retention strategy]
- [Sensitive data exclusion]

**Configuration**
- [Environment-based config; secrets management]
- [Feature flags strategy]

**Error Handling**
- [Error propagation patterns; error codes vs exceptions]
- [User-facing vs internal error boundaries]
- [Retry, circuit breaker, fallback patterns]

**Authentication & Authorization**
- [Auth model: JWT, session, OAuth, API keys]
- [Where auth is enforced; delegation to Security agent for threat model]

**Observability**
- [Metrics, tracing, alerting — high-level; details in DevOps]

---

### 7) Scalability Strategy

**Horizontal vs Vertical**
- [Which components scale horizontally; which vertically]
- [Scaling triggers and automation]

**Load Projections**
- [Expected traffic/throughput at launch and at 12 months]
- [Peak vs average; growth assumptions]

**Bottlenecks and Mitigations**
- [Identified bottlenecks and how they are addressed]
- [What we accept as limits until we measure]

**Performance Targets**
- [Latency targets for key operations]
- [Throughput targets; consistency with PRD section 9]

---

### 8) Deployment Architecture

**Environments**
| Environment | Purpose | Topology |
|-------------|---------|----------|
| Development | [Local or shared dev] | [How it differs from prod] |
| Staging | [Pre-production validation] | [How it differs from prod] |
| Production | [Live traffic] | [Regions, availability] |

**Cloud Provider & Regions**
- [Provider; primary and secondary regions]
- [Multi-region strategy if applicable]

**Availability**
- [High availability approach: multi-AZ, active-passive, active-active]
- [RTO/RPO targets if known]

**Deployment Topology Diagram**
```
[Text or Mermaid diagram showing environments and deployment flow]
```

---

### 9) Architecture Decision Records

| ID | Decision | Context | Options Considered | Decision | Consequences |
|----|----------|----------|-------------------|----------|--------------|
| ADR-001 | [Short title] | [What problem or constraint] | [Option A, B, C] | [Chosen option] | [Positive and negative consequences] |
| ADR-002 | [Short title] | [What problem or constraint] | [Option A, B, C] | [Chosen option] | [Positive and negative consequences] |
| ... | ... | ... | ... | ... | ... |

---

### 10) Constraints and Assumptions

**Constraints**
- [Hard constraints from PRD, budget, compliance, or platform]
- [Technical constraints: e.g., must run on edge, must support offline]

**Assumptions**
- [Assumptions about load, team, timeline, or dependencies]
- [Each assumption should be verifiable or falsifiable]

---

### 11) Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Architectural risk] | High / Medium / Low | High / Medium / Low | [How it is mitigated] |
| [Technology risk] | High / Medium / Low | High / Medium / Low | [How it is mitigated] |
| [Scalability risk] | High / Medium / Low | High / Medium / Low | [How it is mitigated] |
| ... | ... | ... | ... |

---

### Component Dependency Graph

```
[Text-based or Mermaid diagram showing component dependencies]

Example (Mermaid):
flowchart TD
    A[API Gateway] --> B[Auth Service]
    A --> C[Core Service]
    C --> D[Database]
    C --> E[Cache]
    C --> F[Message Queue]
    F --> G[Worker]
```

---

## Quality Checklist

- [ ] All 11 sections are present and substantive — no placeholders.
- [ ] Technology choices include rationale and trade-offs.
- [ ] Component boundaries are justified; no arbitrary splits.
- [ ] Integration patterns specify sync/async, protocols, and failure semantics.
- [ ] Scalability strategy includes load projections or explicit ceilings.
- [ ] Cross-cutting concerns cover logging, config, error handling, auth.
- [ ] ADRs document key decisions with context, options, and consequences.
- [ ] Risks have explicit mitigations.
- [ ] Component dependency graph is included.
- [ ] Architecture is consistent with PRD constraints (section 8) and NFRs (section 9).
- [ ] Unresolved questions and dependencies on other planning agents are documented.
