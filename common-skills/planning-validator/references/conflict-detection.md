# Conflict Detection Patterns

## Overview

This reference provides a library of common conflict patterns to look for when cross-validating plan documents. Each pattern describes a specific contradiction type, which documents are typically involved, and how to detect it.

## Pattern Library

### P-001: Offline vs. Real-Time Conflict
- **Documents**: PRD (NFRs) vs Architecture/HLD
- **Pattern**: PRD states "offline-first" or "works without internet" but Architecture or HLD describes features requiring real-time connectivity.
- **Detection**: Search PRD for offline requirements. Cross-reference with Architecture integration points and HLD features that require network calls.
- **Resolution**: Define which features work offline and which require connectivity. Update PRD or Architecture to align.

### P-002: No-Backend vs. Server-Side Logic
- **Documents**: PRD (Constraints) vs Architecture/API Design
- **Pattern**: PRD states "no backend" or "client-only" but Architecture describes a backend service or API Design defines server endpoints.
- **Detection**: Search PRD constraints for backend restrictions. Check Architecture and API Design for server-side components.
- **Resolution**: Clarify whether the constraint means "no custom backend" (allowing BaaS) or "purely client-side".

### P-003: Authentication Mismatch
- **Documents**: Security vs API Design vs Architecture
- **Pattern**: Security plan specifies one authentication method (e.g., JWT) but API Design uses a different method (e.g., session cookies), or Architecture assumes a third approach.
- **Detection**: Extract auth method from each document and compare.
- **Resolution**: Align all documents to a single authentication approach.

### P-004: Database Technology Disagreement
- **Documents**: Architecture vs Data Architecture vs HLD
- **Pattern**: Architecture specifies PostgreSQL, Data Architecture models with MongoDB patterns, HLD references DynamoDB access patterns.
- **Detection**: Extract database technology mentions from all documents. Check for consistency.
- **Resolution**: Align to a single database technology (or explicitly document a multi-DB strategy).

### P-005: Performance Target Contradiction
- **Documents**: PRD vs Architecture vs Testing Strategy
- **Pattern**: PRD specifies "< 200ms response time" but Architecture's chosen approach cannot meet that target, or Testing Strategy tests for a different threshold.
- **Detection**: Extract all numeric performance targets and compare across documents.
- **Resolution**: Align targets. If architecture cannot meet PRD targets, flag as a feasibility issue.

### P-006: Scope Boundary Violation
- **Documents**: HLD sections vs User Stories vs PRD (Out of Scope)
- **Pattern**: An HLD section or user story includes functionality that PRD explicitly lists as out of scope.
- **Detection**: Cross-reference HLD sections and user stories against PRD Out of Scope list (section 13).
- **Resolution**: Remove the out-of-scope functionality from HLD/stories, or update PRD scope if the decision has changed.

### P-007: Deployment vs. Security Conflict
- **Documents**: DevOps vs Security
- **Pattern**: DevOps plan exposes services or ports that Security plan requires to be restricted. Or DevOps uses plaintext secrets that Security requires encrypted.
- **Detection**: Compare DevOps infrastructure config against Security network and access requirements.
- **Resolution**: Update DevOps plan to meet Security requirements.

### P-008: API Contract vs. Data Model Mismatch
- **Documents**: API Design vs Data Architecture
- **Pattern**: API response schema includes fields that don't exist in the data model, or data model has required fields that no API endpoint populates.
- **Detection**: Map API response fields to data model fields. Look for mismatches.
- **Resolution**: Align API schemas with data model. Add derived/computed field documentation if fields are transformations.

### P-009: Test Coverage Gap
- **Documents**: Testing Strategy vs User Stories/HLD
- **Pattern**: User stories or HLD sections have acceptance criteria that no test type in the Testing Strategy covers.
- **Detection**: Map each acceptance criterion to a test type in the Testing Strategy. Flag unmapped criteria.
- **Resolution**: Add test types or update Testing Strategy to cover the gap.

### P-010: Design vs. PRD UX Constraint Violation
- **Documents**: Design vs PRD (Constraints - UX & Design)
- **Pattern**: Design mockups violate PRD UX constraints (e.g., too many screens, wrong navigation structure, missing dark mode).
- **Detection**: Extract UX constraints from PRD section 8 and verify each against Design spec and mockups.
- **Resolution**: Update Design to comply with PRD constraints, or negotiate PRD constraint changes.

### P-011: Terminology Drift
- **Documents**: Any pair
- **Pattern**: The same concept is referred to by different names in different documents (e.g., "user" vs "customer" vs "account holder").
- **Detection**: Build a glossary of key terms from each document. Look for synonyms used inconsistently.
- **Resolution**: Establish canonical terminology in the PRD and align all documents.

### P-012: Missing Error Handling
- **Documents**: HLD vs API Design vs Design
- **Pattern**: HLD describes a failure mode, API Design has no error code for it, and Design has no error state mockup.
- **Detection**: Extract failure modes from HLD. Check for corresponding API error codes and Design error mockups.
- **Resolution**: Add missing error handling across all three documents.

## Detection Process

1. Run each pattern against the relevant documents.
2. For each match, record:
   - Pattern ID
   - Severity (CONFLICT, TENSION, GAP, DRIFT)
   - Source document and location
   - Target document and location
   - Specific finding
   - Suggested resolution
3. Include all findings in the validation report.
