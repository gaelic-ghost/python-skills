# python-skills

Curated Codex skills for Python development with `uv`-first workflows and practical automation templates.

## What These Agent Skills Help With

This repository supports Python users who want consistent project setup, testing, and MCP/FastAPI bootstrapping with modern `uv` tooling.

## Skill Guide (When To Use What)

- `bootstrap-python-mcp-service`
  - Use when creating Python MCP services with FastMCP + `uv` defaults.
  - Helps by standardizing project scaffolding and initial quality checks.
- `bootstrap-python-service`
  - Use when creating Python FastAPI services with `uv`.
  - Helps by quickly generating sane service structure and dev tooling defaults.
- `bootstrap-uv-python-workspace`
  - Use when creating multi-package Python workspaces under `uv`.
  - Helps by setting predictable workspace layout and package/service conventions.
- `uv-pytest-unit-testing`
  - Use when adding or stabilizing pytest-based tests in `uv` projects.
  - Helps by aligning test setup, execution commands, and troubleshooting patterns.

## Quick Start (Vercel Skills CLI)

```bash
npx skills add gaelic-ghost/python-skills
```

```bash
npx skills add gaelic-ghost/python-skills -a codex
```

```bash
npx skills add gaelic-ghost/python-skills -a codex -g
```

## Install individually by Skill

```bash
npx skills add gaelic-ghost/python-skills@bootstrap-python-mcp-service -a codex
npx skills add gaelic-ghost/python-skills@bootstrap-python-service -a codex
npx skills add gaelic-ghost/python-skills@bootstrap-uv-python-workspace -a codex
npx skills add gaelic-ghost/python-skills@uv-pytest-unit-testing -a codex
```

## Find Skills like these with the `skills` CLI by Vercel — [vercel-labs/skills](https://github.com/vercel-labs/skills)

```bash
npx skills find "python uv codex"
npx skills find "fastapi bootstrap"
npx skills find "pytest uv workflow"
```

## Find Skills like these with `Find Skills` by Vercel — [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills)

```bash
npx skills add vercel-labs/agent-skills -a codex
npx skills find "python workspace skill"
npx skills find "mcp service bootstrap"
```

- Skills catalog: [skills.sh](https://skills.sh/)

## Repository Layout

```text
.
├── README.md
├── LICENSE
├── bootstrap-python-mcp-service/
├── bootstrap-python-service/
├── bootstrap-uv-python-workspace/
└── uv-pytest-unit-testing/
```

## Notes

- All workflows in this repo assume `uv` as the default Python tooling path.
- Each skill includes automation template guidance suitable for Codex App and Codex CLI execution.

## Search Keywords

Python skills, uv, FastAPI, FastMCP, pytest, workspace bootstrap, Codex automation.

## License

Apache-2.0. See [LICENSE](./LICENSE).
