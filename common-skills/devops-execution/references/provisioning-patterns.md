# Provisioning Patterns

Reference templates for common infrastructure provisioning scenarios.

## Docker Compose Service

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

## Local SQLite

1. Create the database directory if it doesn't exist.
2. Initialize with schema from migrations or SQL file.
3. Set `DATABASE_URL=sqlite:./data/{name}.db` in `.env`.
4. Verify with: `sqlite3 data/{name}.db ".tables"`.

## Environment File

```
# .env — managed by DevOps execution agent
# {Dependency}: {type} at {location}
{ENV_VAR_NAME}={connection_string}
```
