# PRD Validation Reference

## Overview

Before a PRD can proceed to user story decomposition, it must pass all 8 validation dimensions at "high" confidence. This is a blocking gate — not advisory.

The planner runs this cycle after each PRD draft or significant update, presents a scorecard, asks targeted probing questions for weak dimensions, and iterates until all dimensions reach "high".

---

## Scoring Scale

| Score | Meaning |
|-------|---------|
| **low** | Critical gaps that would block or mislead downstream work |
| **medium** | Addressable weaknesses that could cause rework or misalignment |
| **high** | Dimension is strong enough for downstream consumption without further clarification |

---

## The 8 Dimensions

### 1. Structure & Completeness

**What it checks**: All 14 PRD sections are present and contain substantive content — no placeholders.

**Required sections**: Metadata, Executive Summary, Problem Statement, Target Audience, Goals & Objectives, In Scope, User Stories, Constraints, Non-Functional Requirements, Dependencies, Assumptions, Risks & Mitigations, Out of Scope, Success Metrics.

| Score | Indicators |
|-------|-----------|
| low | Missing sections; content contains "TBD", "TODO", or "see later" |
| medium | All sections present but some lack depth or specificity |
| high | All 14 sections present and substantive — no placeholders |

**Probing questions**:
- Which sections still contain placeholder or generic content?
- Could a new team member understand each section without asking clarifying questions?

---

### 2. Testability

**What it checks**: Every acceptance criterion maps to a specific, automatable test condition with a measurable threshold.

| Score | Indicators |
|-------|-----------|
| low | Criteria use subjective/unmeasurable terms: "intuitive", "fast", "user-friendly", "relevant" |
| medium | Most criteria are testable but one or more remain vague or threshold-less |
| high | Every criterion has an explicit measurable threshold and an observable pass/fail condition |

**Common failure patterns**:
- "The app should be responsive" → must specify ms threshold (e.g., "First Contentful Paint < 1.5s on 4G")
- "Search should return relevant results" → must define what "relevant" means (e.g., "exact match in top 3")
- "Good user experience for errors" → must define specific error states and their required handling

**Probing questions**:
- For "[acceptance criterion]", can you write a test assertion right now? What is the exact condition?
- What is the numeric threshold for performance criteria?
- What defines a "correct" output for any AI-generated or LLM-powered feature?

---

### 3. Consistency

**What it checks**: No contradictions exist between sections; any tensions are explicitly resolved.

| Score | Indicators |
|-------|-----------|
| low | Direct contradictions between sections (e.g., "offline-first" AND "requires real-time sync") |
| medium | Potential tensions exist that are not explicitly resolved or acknowledged |
| high | All sections align; tensions are acknowledged with an explicit resolution rationale |

**Common failure patterns**:
- Offline-first requirement in NFR vs. real-time feature in scope
- "No backend ever" in constraints vs. a feature that implicitly requires server-side logic
- Term used with different meaning in different sections

**Probing questions**:
- Does [requirement in section X] conflict with [requirement in section Y]? Which takes priority?
- Is [term] defined consistently across all sections, or does it mean different things in different places?

---

### 4. Security & Privacy

**What it checks**: Security and privacy considerations are addressed for the product type and data handled.

| Score | Indicators |
|-------|-----------|
| low | No security or privacy section; sensitive data handling is undescribed |
| medium | Basic mentions exist but key concerns (credential storage, PII handling, threat model) are unaddressed |
| high | Sensitive data identified and handling strategy described; credential security addressed; privacy obligations acknowledged; key threats and mitigations present |

**Common failure patterns**:
- API keys stored in localStorage with no security warning
- PII collected but retention and deletion policies not specified
- No mention of HTTPS, encryption at rest, or secure storage
- No threat model — assumes benign usage only

**Probing questions**:
- Where exactly is [sensitive data / API key / credential] stored? What is the encryption strategy?
- What happens if an attacker gains access to [credential/token]? What is the blast radius?
- Which data qualifies as PII under applicable regulations? How is it retained and deleted?

---

### 5. Clarity & Precision

**What it checks**: No subjective or ambiguous terms are used without an explicit definition or measurable proxy.

| Score | Indicators |
|-------|-----------|
| low | Multiple undefined subjective terms: "mature aesthetic", "feels fast", "clean design", "relevant", "user-friendly" |
| medium | Most terms defined but some subjective language remains without measurable proxy |
| high | All terms are either objectively defined or have an explicit measurable proxy agreed by the user |

**Common failure patterns**:
- "Mature, clean aesthetic" without a reference product or visual design reference
- "Fast" without a specific ms/s threshold
- "Standard" behavior without specifying which standard

**Probing questions**:
- What does "[subjective term]" mean specifically? Can you point to a reference product or give a measurable threshold?
- How would two engineers independently interpret "[ambiguous phrase]"? Would they agree on the implementation?

---

### 6. Technical Feasibility

**What it checks**: Technology choices are viable for the stated requirements and justified with documented trade-offs.

| Score | Indicators |
|-------|-----------|
| low | Technology choices are assumed without justification; known incompatibilities or risks are unaddressed |
| medium | Choices are plausible but key trade-offs or compatibility risks are not documented |
| high | Each significant technology choice is justified, key trade-offs are acknowledged, and known risks are mitigated |

**Common failure patterns**:
- "We'll use React Native for V2" without addressing V1→V2 migration path feasibility
- Technology chosen without verifying it supports required platform APIs
- Third-party SDK used client-side where CORS or CSP restrictions may block it

**Probing questions**:
- What evidence supports that [technology] can handle [requirement] at the expected scale?
- What are the known trade-offs of choosing [technology]?
- Is there a known incompatibility between [technology A] and [technology B] in this context?

**Research dispatch**: When the planner cannot confidently assess technical feasibility, dispatch an `sdlc-project-research` agent before scoring this dimension. Do not guess.

---

### 7. Scope Definition

**What it checks**: In-scope and out-of-scope are explicit, exhaustive, and leave no gray areas.

| Score | Indicators |
|-------|-----------|
| low | Scope is implied or vague; no explicit out-of-scope list; boundary cases unaddressed |
| medium | Core scope is defined but some boundary cases or edge behaviors are unaddressed |
| high | In-scope and out-of-scope are exhaustive; boundary behaviors are explicitly defined; no gray areas |

**Common failure patterns**:
- No out-of-scope list at all — assuming "everything not mentioned is excluded"
- Out-of-scope items that could be triggered indirectly by in-scope actions
- Features that are "sort of in scope" but never explicitly called out

**Probing questions**:
- What is the expected behavior when a user tries to do [out-of-scope item]?
- Are there any features that are "sort of in scope" but not explicitly addressed?
- What is the expected behavior at the boundary between [feature A] and [feature B]?

---

### 8. Downstream Readiness

**What it checks**: Designers and developers have enough detail to begin work without requiring additional clarification sessions.

| Score | Indicators |
|-------|-----------|
| low | Key design or implementation decisions are deferred; navigation flow, data model, or UI states are undefined |
| medium | Most decisions present but some key details (screen flow, data shape, API contract, error states) are missing |
| high | All decisions needed to begin design and implementation are present; no blocking ambiguities remain |

**Common failure patterns**:
- Navigation structure not defined (which screen is the home screen?)
- Data model fields not specified (what fields does an inventory item have?)
- Error states not defined (what does the UI show when the LLM API fails?)
- API contract or integration format not specified

**Probing questions**:
- What is the default screen when the app opens? Is the full navigation flow defined?
- What are the exact fields in the data model for [entity]?
- What does the UI show for each error state (network failure, API error, invalid input)?

---

## Scorecard Template

Present after each validation run:

```
| # | Dimension | Confidence | Key Issue |
|---|-----------|-----------|-----------|
| 1 | Structure & Completeness | high/medium/low | [specific issue or "none"] |
| 2 | Testability | high/medium/low | [specific issue or "none"] |
| 3 | Consistency | high/medium/low | [specific issue or "none"] |
| 4 | Security & Privacy | high/medium/low | [specific issue or "none"] |
| 5 | Clarity & Precision | high/medium/low | [specific issue or "none"] |
| 6 | Technical Feasibility | high/medium/low | [specific issue or "none"] |
| 7 | Scope Definition | high/medium/low | [specific issue or "none"] |
| 8 | Downstream Readiness | high/medium/low | [specific issue or "none"] |
```

Follow the scorecard with grouped probing questions for each non-high dimension.

---

## Gate Rule

ALL 8 dimensions must be "high" before proceeding to user story decomposition.

If the user explicitly overrides the gate: require written acknowledgment of the specific risk accepted for each non-high dimension, then proceed. Do not silently skip the gate.
