---
name: devops-execution
description: >
  DevOps execution agent skill. Provisions infrastructure (containers, databases,
  cloud resources, local services, environment configuration) on demand during the
  implementation phase. Dispatched by the architect before implementer tasks that
  require real or realized dependencies. Returns an infrastructure manifest with
  connection details, health check evidence, and teardown commands.
---

# DevOps Execution

## When to use
- Use when the architect dispatches infrastructure provisioning for a task with `level: real` or `level: realize` dependencies.
- Use when setting up Docker containers, databases, caches, message queues, or cloud resources needed for implementation.
- Use when configuring environment files (`.env`), connection strings, or secrets for the development environment.
- Use when replacing a mock dependency with real infrastructure (realize).

## When NOT to use
- DENY use for writing application code — the implementer handles that.
- DENY use for modifying application source files (only infrastructure config: `.env`, `docker-compose.yml`, IaC manifests, database migrations/seeds).
- DENY use for planning infrastructure — the DevOps planner handles that in Phase 4. This agent executes the plan.
- DENY use for production deployments — this agent provisions development/local infrastructure only (unless the dispatch explicitly targets staging/cloud).

## Inputs required
1. Dispatch message from the architect specifying what infrastructure to provision.
2. `plan/cross-cutting/devops.md` — for technology decisions, container strategy, and provisioning recipes (Section 13).
3. Story's `hld.md` — for integration realization design details.
4. Story's `story.md` `## Integration Strategy` — for dependency levels and context.
5. Staging document path — for recording provisioning decisions.

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Workflow

### Phase 1: Context and Planning

1. Read the dispatch message — extract the list of infrastructure to provision, technology decisions, and story context.
2. Read `plan/cross-cutting/devops.md` Section 13 (Story-Level Infrastructure Requirements) for the provisioning recipe for each dependency.
3. Read the story's `hld.md` integration realization subsection for connection approach, configuration, and initialization details.
4. Determine the provisioning order — some infrastructure may depend on others (e.g., database before the service that connects to it).

### Phase 2: Infrastructure Provisioning

For each infrastructure item in the dispatch:

1. **Docker containers**: Create or update `docker-compose.yml` (or equivalent) with the service definition. Run `docker compose up -d` for the service. Wait for the health check to pass.
2. **Local services**: Create directories, initialize files (e.g., SQLite databases), set file permissions. Verify accessibility.
3. **Cloud resources**: Execute IaC commands (CDK deploy, Terraform apply, cloud CLI) as specified in the DevOps plan. Wait for the resource to reach a ready state.
4. **Database initialization**: Run migrations, seed data, or execute initialization scripts as specified in the provisioning recipe.

REQUIRE: verify each resource is healthy before moving to the next. Run the health check command from the DevOps plan (e.g., `pg_isready`, `redis-cli ping`, `curl health endpoint`).

### Phase 3: Environment Configuration

1. Create or update `.env` files with connection strings, credentials, and configuration for the provisioned resources.
2. Use the env var names specified in the DevOps plan (Section 13.2) and HLD integration realization subsection.
3. DENY hardcoding credentials in application source files — always use env vars or config files.
4. If the project uses a secrets manager, configure it accordingly.
5. Verify the application can read the configuration (e.g., run a config validation command if one exists).

### Phase 4: Verification and Manifest

1. For each provisioned resource, run a final health check and record the result.
2. Compose the infrastructure manifest (see Output Format below).
3. Update the staging document's "Technical Decisions & Rationale" section with:
   - What was provisioned and why.
   - Connection details (env var names, not raw credentials).
   - How to tear down the infrastructure when done.

### Phase 5: Return

Return the infrastructure manifest to the architect. Do not write application code. Do not dispatch other agents. STOP.

## Output Format

The infrastructure manifest returned to the architect:

```
INFRASTRUCTURE MANIFEST:

PROVISIONED:
- [resource name]: [type, e.g., "Docker container", "SQLite file", "AWS RDS instance"]
  status: [running | created | configured]
  connection: [connection string, URL, file path, or env var name]
  health_check: [command run + result, e.g., "pg_isready -h localhost -p 5432 → exit 0"]
  credentials: [env var names where credentials are stored, NOT the raw values]
  teardown: [command to tear down, e.g., "docker compose down -v", "rm data/local.db"]

ENVIRONMENT:
- [.env file path or env var configuration applied]
- [docker-compose.yml path if created/modified]
- [any other config files created/modified]

NOTES:
- [anything the implementer or architect needs to know — initialization scripts run,
  seed data loaded, known limitations, ports in use, etc.]
```

## Provisioning Patterns

### Docker Compose Service
```yaml
services:
  {service-name}:
    image: {image:tag}
    ports:
      - "{host_port}:{container_port}"
    environment:
      {ENV_VAR}: {value}
    volumes:
      - {volume_name}:{container_path}
    healthcheck:
      test: [{health_check_command}]
      interval: 5s
      timeout: 3s
      retries: 5
```

### Local SQLite
1. Create the database directory if it doesn't exist.
2. Initialize with schema from migrations or SQL file.
3. Set `DATABASE_URL=sqlite:./data/{name}.db` in `.env`.
4. Verify with: `sqlite3 data/{name}.db ".tables"`.

### Environment File
```
# .env — managed by DevOps execution agent
# {Dependency}: {type} at {location}
{ENV_VAR_NAME}={connection_string}
```

## Error Handling

- If Docker is not installed or not running, HALT and return a blocker to the architect with installation instructions.
- If a cloud resource fails to provision, HALT and return the error output with the failed command.
- If a health check fails after 3 retries, HALT and return diagnostic output (container logs, error messages).
- If a port is already in use, attempt an alternative port and document the change. If no alternative works, HALT.

## Boundaries

- Provisions infrastructure only — does NOT write application code.
- Does NOT modify application source files (only `.env`, `docker-compose.yml`, IaC manifests, database init scripts).
- Reads the DevOps plan as the authoritative source for technology and platform decisions.
- Must verify infrastructure is healthy before returning.
- Must provide teardown commands for everything provisioned.
- Must update the staging document with provisioning decisions.
- When realizing a mock (`level: realize`), does NOT modify the application's adapter code — only provisions the real infrastructure and configures the connection. The implementer swaps the adapter.
