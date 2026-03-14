# Validation Cycles

## Overview

The PRD agent self-assesses against 8 validation dimensions after each draft or significant update. Each dimension is scored low, medium, or high. ALL 8 must reach "high" before completion. The agent presents a scorecard, asks targeted probing questions for non-high dimensions, and iterates until the gate passes.

## Scoring Scale

- **Low:** Critical gaps that would block or mislead downstream work.
- **Medium:** Addressable weaknesses that could cause rework or misalignment.
- **High:** Dimension is strong enough for downstream consumption without further clarification.

## Dimensions

### 1. Structure Completeness
All 14 PRD sections are present and contain substantive content — no placeholders.

**Required sections:** Metadata, Executive Summary, Problem Statement, Target Audience, Goals & Objectives, In Scope, User Stories, Constraints, Non-Functional Requirements, Dependencies, Assumptions, Risks & Mitigations, Out of Scope, Success Metrics.

**Probes:**
- Which sections still contain placeholder or generic content?
- Could a new team member understand each section without asking clarifying questions?

### 2. Testability
Every acceptance criterion maps to a specific, automatable test condition with a measurable threshold.

**Probes:**
- For "[acceptance criterion]", can you write a test assertion right now? What is the exact condition?
- What is the numeric threshold for performance criteria?
- What defines a "correct" output for any AI-generated or LLM-powered feature?

### 3. Consistency
No contradictions exist between sections; any tensions are explicitly resolved.

**Probes:**
- Does [requirement in section X] conflict with [requirement in section Y]? Which takes priority?
- Is [term] defined consistently across all sections, or does it mean different things in different places?

### 4. Security / Privacy
Security and privacy considerations are addressed for the product type and data handled.

**Probes:**
- Where exactly is [sensitive data / API key / credential] stored? What is the encryption strategy?
- What happens if an attacker gains access to [credential/token]? What is the blast radius?
- Which data qualifies as PII under applicable regulations? How is it retained and deleted?

### 5. Clarity / Precision
No subjective or ambiguous terms are used without an explicit definition or measurable proxy.

**Probes:**
- What does "[subjective term]" mean specifically? Can you point to a reference product or give a measurable threshold?
- How would two engineers independently interpret "[ambiguous phrase]"? Would they agree on the implementation?

### 6. Technical Feasibility
Technology choices are viable for the stated requirements and justified with documented trade-offs.

**Probes:**
- What evidence supports that [technology] can handle [requirement] at the expected scale?
- What are the known trade-offs of choosing [technology]?
- Is there a known incompatibility between [technology A] and [technology B] in this context?

When uncertain, dispatch sdlc-project-research before scoring.

### 7. Scope Definition
In-scope and out-of-scope are explicit, exhaustive, and leave no gray areas.

**Probes:**
- What is the expected behavior when a user tries to do [out-of-scope item]?
- Are there any features that are "sort of in scope" but not explicitly addressed?
- What is the expected behavior at the boundary between [feature A] and [feature B]?

### 8. Downstream Readiness
Designers and developers have enough detail to begin work without requiring additional clarification sessions.

**Probes:**
- What is the default screen when the app opens? Is the full navigation flow defined?
- What are the exact fields in the data model for [entity]?
- What does the UI show for each error state (network failure, API error, invalid input)?

## Scorecard Format

Present after each validation run:

| # | Dimension | Confidence | Key Issue |
|---|-----------|------------|-----------|
| 1 | Structure & Completeness | high/medium/low | [specific issue or "none"] |
| 2 | Testability | high/medium/low | [specific issue or "none"] |
| 3 | Consistency | high/medium/low | [specific issue or "none"] |
| 4 | Security & Privacy | high/medium/low | [specific issue or "none"] |
| 5 | Clarity & Precision | high/medium/low | [specific issue or "none"] |
| 6 | Technical Feasibility | high/medium/low | [specific issue or "none"] |
| 7 | Scope Definition | high/medium/low | [specific issue or "none"] |
| 8 | Downstream Readiness | high/medium/low | [specific issue or "none"] |

Follow the scorecard with grouped probing questions for each non-high dimension.

## Gate Rule

ALL 8 dimensions must be "high" before proceeding to downstream planning phases.

If the user explicitly overrides the gate: require written acknowledgment of the specific risk accepted for each non-high dimension, then proceed. Do not silently skip the gate.
