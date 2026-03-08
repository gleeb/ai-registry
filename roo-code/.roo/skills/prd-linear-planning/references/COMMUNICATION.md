# Communication and Change Tracking (Linear)

## Contents
- Purpose
- Resources
- Initiative updates
- Project (User Story) updates
- HLD Issue activity and comments
- Minimal comment/update contract

## Purpose
Use this reference to keep planning changes auditable in Linear through structured updates and comment trails.

## Resources
- Use the **Resources** section on Projects to attach external links and create Linear documents for planning context.
- Keep links labeled and current so stakeholders can find the latest spec, decision log, and supporting material.
- Prefer resources for durable context; prefer comments/updates for incremental change history.

## Initiative updates
- Use Initiative updates for high-level progress communication.
- Include health (`onTrack`, `atRisk`, `offTrack`) and a concise narrative of changed assumptions, timeline, ownership, or scope.
- If comments are used under an update, continue discussion in-thread to preserve chronology.

## Project (User Story) updates
- Use Project updates for delivery-level progress, milestone movement, target-date changes, and risk shifts.
- Keep each update focused on delta since the last update.
- If Slack sync is enabled, update comments can sync bi-directionally; treat the Linear thread as the system of record for traceability.

## HLD Issue activity and comments
- Use Issue comments for granular decisions, blockers, handoffs, and acceptance evidence links.
- Keep one thread per decision/blocker topic to avoid fragmented history.
- Prefer comments over description rewrites for explaining *why* a change occurred; keep the Issue description focused on current desired state.

## Minimal comment/update contract
For every meaningful planning change (Initiative/Project/HLD Issue), record:
1. **What changed** (scope, timeline, owner, risk, acceptance criteria, dependency).
2. **Why it changed** (new information, conflict resolution, priority shift).
3. **Impact** (parent/child links affected, milestone dates, blockers).
4. **Next action** (owner + expected follow-up checkpoint).

REQUIRE this contract in either:
- the relevant Initiative/Project update body, or
- an HLD Issue comment when the change is Issue-local.
