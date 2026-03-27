# PinchTab Environment Setup

## Architecture

PinchTab runs inside a Docker container with Chrome (headless). Docker Desktop bridges the container's port to the host, making PinchTab accessible at `http://localhost:9867`.

```
Host (WSL or macOS)
  |
  |-- Docker Desktop (bridged networking)
  |     |-- PinchTab container
  |           |-- PinchTab server (port 9867 inside container)
  |           |-- Chrome (headless, managed by PinchTab)
  |
  |-- Dev server (e.g. localhost:3000, started by agent or user)
  |
  Port mapping: container:9867 → host:9867
```

## Network Topology

### Host → PinchTab

The agent runs on the host. PinchTab's HTTP API is reachable at:

```
http://localhost:9867
```

All `curl` commands target this address.

### PinchTab → Dev Server (URL Translation)

PinchTab's Chrome is inside Docker. When it needs to navigate to a dev server, `localhost` inside the container refers to the container itself, not your development runtime.

Use `host.docker.internal` to reach the Docker host:

| Dev server on host | URL for PinchTab navigation |
|---|---|
| `http://localhost:3000` | `http://host.docker.internal:3000` |
| `http://localhost:5173` | `http://host.docker.internal:5173` |
| `http://localhost:8080` | `http://host.docker.internal:8080` |

Example:

```bash
# Agent starts dev server on host
npm run dev  # listening on localhost:3000

# Agent tells PinchTab to navigate (URL translated for Docker)
curl -X POST http://localhost:9867/navigate \
  -H 'Content-Type: application/json' \
  -d '{"url": "http://host.docker.internal:3000"}'
```

### WSL-Specific Note (Important)

In WSL environments, your app server may run inside the WSL VM (Linux network namespace), while PinchTab runs in Docker Desktop. In that setup:

- `http://localhost:<port>` from PinchTab **will fail** for WSL-hosted dev servers.
- `http://host.docker.internal:<port>` may point to the Windows host and can still fail for WSL-hosted services.
- The most reliable target is usually the WSL interface IP (for example from `hostname -I`) plus a server bound to `0.0.0.0`.

Recommended WSL flow:

```bash
# 1) Ensure server binds all interfaces
# (framework-specific; example)
npm run web

# 2) Get WSL IP
hostname -I

# 3) Navigate PinchTab using WSL IP
pinchtab nav "http://<WSL_IP>:<PORT>"
pinchtab text
```

Observed behavior reference:

| Target URL from PinchTab | Typical outcome in WSL |
|---|---|
| `http://localhost:<port>` | `ERR_CONNECTION_REFUSED` |
| `http://host.docker.internal:<port>` | Works only when service is reachable on Docker host path |
| `http://<WSL_IP>:<port>` | Preferred for WSL-hosted dev servers |

### PinchTab → External Sites

PinchTab can navigate to any external URL directly — no translation needed:

```bash
curl -X POST http://localhost:9867/navigate \
  -H 'Content-Type: application/json' \
  -d '{"url": "https://example.com"}'
```

## Container Assumptions

- The PinchTab container is **assumed to be already running**. No agent is responsible for starting it.
- The DevOps agent verifies PinchTab is healthy before implementation tasks on web app stories.
- If the health check fails, the DevOps agent reports a blocker — it does not attempt to start the container.

## Health Verification

```bash
curl http://localhost:9867/health
```

Expected: HTTP 200 with a JSON response indicating healthy status. If this fails, PinchTab is not reachable — check that the Docker container is running and port 9867 is mapped.

## MCP Alternative

If the `pinchtab` binary is installed on the host (not just in the container), the PinchTab MCP server can be used as an alternative interface. The MCP server (`pinchtab mcp`) runs on the host and proxies tool calls to the HTTP API at `localhost:9867`. See [mcp.md](mcp.md) for configuration and available tools.
