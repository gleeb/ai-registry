# Error Handling for Cross-Cutting DevOps

## Missing Per-Story Artifacts

- **Trigger**: One or more `plan/user-stories/*/hld.md` files do not exist.
- **Action**: Do not proceed with incomplete topology. Report which stories are missing HLD.
- **Action**: Request that HLD planning be completed for those stories before DevOps planning.
- **Prohibited**: Do not guess or invent service topology from story.md alone.

## Missing system-architecture.md

- **Trigger**: `plan/system-architecture.md` does not exist.
- **Action**: Do not proceed. Report: "DevOps planning requires system-architecture.md for deployment topology and infrastructure requirements."
- **Action**: Request that the Architecture agent be dispatched first.
- **Prohibited**: Do not guess or invent architecture.

## Missing security-overview.md

- **Trigger**: `plan/cross-cutting/security-overview.md` does not exist.
- **Action**: Do not proceed. Report: "DevOps planning requires security-overview.md for secrets management and security infrastructure alignment."
- **Action**: Request that the Security agent be dispatched first.
- **Prohibited**: Do not invent security infrastructure that may conflict with security overview.

## Security Overview Conflicts

- **Trigger**: Proposed infrastructure contradicts security-overview.md (e.g., secrets handling, network policies, TLS).
- **Action**: Surface the conflict with specific references.
- **Action**: Reconcile with security overview before completing — align DevOps plan or escalate for security overview revision.
- **Prohibited**: Do not proceed with conflicting infrastructure.

## Incomplete Service Topology

- **Trigger**: Per-story HLDs are incomplete or inconsistent — services cannot be fully enumerated.
- **Action**: Flag which stories have incomplete HLD.
- **Action**: Request HLD completion or clarification before proceeding.
- **Prohibited**: Do not deploy a partial or guessed topology.

## Missing Monitoring for Services

- **Trigger**: One or more services have no monitoring plan defined.
- **Action**: Do not write devops.md until every service has monitoring.
- **Action**: Report which services lack monitoring and add coverage.
- **Prohibited**: Do not leave any service unmonitored.
