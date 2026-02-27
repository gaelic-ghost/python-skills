---
name: bootstrap-uv-python-workspace
description: Bootstrap new Python projects and multi-package workspaces with uv on macOS using deterministic scripts and consistent defaults. Use when creating a new uv Python project, scaffolding a uv monorepo/workspace, setting up package or service profiles, initializing dev tooling (pytest, ruff, mypy), creating README scaffolds, or initializing git with an optional first commit.
---

# Bootstrap UV Python Workspace

Create repeatable uv-based scaffolds for both single projects and workspaces.
Use this skill as the shared scaffolding basis for other Python bootstrap skills that need consistent uv project/workspace defaults.

## Workflow

1. Choose bootstrap mode:
- Single project: `scripts/init_uv_python_project.sh`
- Workspace: `scripts/init_uv_python_workspace.sh`
2. Select profile(s):
- `package`: library/package layout
- `service`: FastAPI service layout
3. Run scaffold script with explicit `--name` and optional `--path`, `--python`, and `--initial-commit`.
4. Verify generated environment with built-in checks run by the scripts.
5. Return exact next commands to run locally.

## Commands

```bash
# Package project
scripts/init_uv_python_project.sh --name my-lib --profile package

# Service project
scripts/init_uv_python_project.sh --name my-service --profile service --python 3.13

# Workspace with defaults (core-lib package + api-service service)
scripts/init_uv_python_workspace.sh --name my-workspace

# Workspace with explicit members and profile mapping
scripts/init_uv_python_workspace.sh \
  --name platform \
  --members "core-lib,billing-service,orders-service" \
  --profile-map "core-lib=package,billing-service=service,orders-service=service"

# Allow non-empty target directory
scripts/init_uv_python_project.sh --name my-lib --force

# Skip git initialization
scripts/init_uv_python_workspace.sh --name platform --no-git-init

# Create initial commit after successful scaffold
scripts/init_uv_python_project.sh --name my-service --profile service --initial-commit
```

## Guardrails

- Refuse non-empty target directories unless `--force` is set.
- Refuse to overwrite an existing `pyproject.toml`.
- Require `uv` and `git` (when git initialization is enabled).
- Exit non-zero with actionable error text for invalid arguments or missing prerequisites.

## Defaults

- Python version: `3.13` (override with `--python`).
- Quality tooling: `pytest`, `ruff`, `mypy`.
- Git initialization: enabled by default (disable via `--no-git-init`).
- Workspace defaults:
- Members: `core-lib,api-service`
- Profiles: first member `package`, remaining members `service`
- Local linking: services depend on the first package member using uv workspace sources.

## References

Use [references/uv-command-recipes.md](references/uv-command-recipes.md) for concise uv command patterns.

## Resources

### scripts/

- `init_uv_python_project.sh`: bootstrap a single uv project (`package` or `service`).
- `init_uv_python_workspace.sh`: bootstrap a uv workspace with multiple members.

### references/

- `uv-command-recipes.md`: short recipes for init/add/run/sync/workspace operations.

### assets/

- `README.md.tmpl`: shared template consumed by both scripts.
