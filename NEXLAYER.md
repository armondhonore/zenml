# Nexlayer — zenml

<!-- nexlayer:meta version=1 analyzed=2026-06-30T23:55:47Z repo=https://github.com/armondhonore/zenml branch=nexlayer -->

> **For AI agents (Claude Code, Cursor, Gemini CLI, Copilot):**
> This file is the **project context** for this Nexlayer deployment — tech stack, env vars, secrets, live URL.
> For full platform detail (nexlayer.yaml schema, Dockerfile rules, CI/CD, task recipes) read **`nexlayer.skills`** in this repo.
>
> **Critical rules (full detail in `nexlayer.skills`):**
> - Inter-pod refs: `${podName:port}` only — never `localhost` or bare hostnames
> - Docker Hub images: prefix with `mirror.gcr.io/library/` — bare tags fail on the cluster
> - Secrets: set in the Nexlayer dashboard — never commit to `nexlayer.yaml` or Dockerfile
>
> **This file:** `agent-managed` sections update automatically. `user-editable` sections (Local Development Setup, Nexlayer Deployment Plan, Build Notes) are yours — preserved across re-analysis.

## Project Summary
<!-- nexlayer:section agent-managed=project_summary -->
ZenML is an MLOps framework that allows AI engineers to create portable pipelines and agentic workflows that can run on any infrastructure backend.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Python | language | >=3.10,<3.15 | pyproject.toml |
| uv | build | 0.8.17 | pyproject.toml |
| Alembic | tool | latest | alembic.ini |
| Docker | infra | 7.1.0 | pyproject.toml |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- src/ — Core ZenML source code and logic
- tests/ — Test suites for the platform
- helm/ — Kubernetes deployment charts
- infra/ — Infrastructure as Code definitions
- docker/ — Dockerfile definitions for various services
- scripts/ — Automation and setup scripts
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- PostgreSQL (for ZenML Server metadata)
- Docker Registry / Container Runtime
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- Python 3.10+
- uv package manager
- Docker

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
ZENML_STORE_URL=http://localhost:8237
DATABASE_URL=postgresql://postgres:password@localhost:5432/zenml
```

### Steps

1. `uv sync` — Install project dependencies using uv
2. `zenml up` — Initialize and start the local ZenML server

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `app` | `PYTHONUNBUFFERED` | `"1"` | plain |
| `app` | `PORT` | `"8000"` | plain |
| `app` | `ZENML_DATABASE_URL` | `"postgresql://zenml:${POSTGRES_PASSWORD}@postgres.pod:5432/zenml"` | inter-pod |
| `postgres` | `POSTGRES_USER` | `zenml` | plain |
| `postgres` | `POSTGRES_PASSWORD` | `${POSTGRES_PASSWORD}` | inter-pod |
| `postgres` | `POSTGRES_DB` | `zenml` | plain |
| `zenml-postgres-data` | `size` | `10Gi` | plain |
| `zenml-postgres-data` | `mountPath` | `/var/lib/postgresql` | plain |

### nexlayer.yaml

```yaml
application:
  name: zenml
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/zenml:9f1af57-fix3"
      path: /
      servicePorts:
        - 8000
      vars:
        PYTHONUNBUFFERED: "1"
        PORT: "8000"
        ZENML_DATABASE_URL: "postgresql://zenml:${POSTGRES_PASSWORD}@postgres.pod:5432/zenml"
    - name: postgres
      image: mirror.gcr.io/library/postgres:16-alpine
      servicePorts:
        - 5432
      vars:
        POSTGRES_USER: zenml
        POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
        POSTGRES_DB: zenml
      volumes:
        - name: zenml-postgres-data
          size: 10Gi
          mountPath: /var/lib/postgresql
```
<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| zenml-server | mirror.gcr.io/library/python:3.11-slim | 8237 | web |
| db | mirror.gcr.io/library/postgres:16-alpine | 5432 | database |

### Deployment notes

- The ZenML server connects to the database via db.pod:5432
- Each daemon is isolated in its own pod according to Nexlayer rules
- Official Python images are mirrored via gcr.io to avoid Docker Hub namespace failures

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-07-01T00:11:24Z  
**Live URL:** https://relaxed-weasel-zenml.cloud.nexlayer.ai  
**Runtime:**  · **Port:** auto-detected  
**Deploy branch:** nexlayer  

```yaml
application:
  name: zenml
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/zenml:9f1af57-fix3"
      path: /
      servicePorts:
        - 8000
      vars:
        PYTHONUNBUFFERED: "1"
        PORT: "8000"
        ZENML_DATABASE_URL: "postgresql://zenml:${POSTGRES_PASSWORD}@postgres.pod:5432/zenml"
    - name: postgres
      image: mirror.gcr.io/library/postgres:16-alpine
      servicePorts:
        - 5432
      vars:
        POSTGRES_USER: zenml
        POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
        POSTGRES_DB: zenml
      volumes:
        - name: zenml-postgres-data
          size: 10Gi
          mountPath: /var/lib/postgresql
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-06-30T23:55:47Z | analyzed | initial repo analysis |
| 2026-07-01T00:11:24Z | success | deployed https://relaxed-weasel-zenml.cloud.nexlayer.ai |
<!-- nexlayer:end -->

