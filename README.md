# python-skills

Canonical Codex skills for Python bootstrapping, testing, FastAPI service setup, and FastMCP scaffolding with `uv`-first workflows.

For standards and maintainer operating guidance, see [AGENTS.md](./AGENTS.md).

## Table of Contents

- [What These Agent Skills Help With](#what-these-agent-skills-help-with)
- [Skill Guide (When To Use What)](#skill-guide-when-to-use-what)
- [Quick Start (Vercel Skills CLI)](#quick-start-vercel-skills-cli)
- [Install individually by Skill or Skill Pack](#install-individually-by-skill-or-skill-pack)
- [Update Skills](#update-skills)
- [More resources for similar Skills](#more-resources-for-similar-skills)
- [Repository Layout](#repository-layout)
- [Notes](#notes)
- [Keywords](#keywords)
- [License](#license)

## What These Agent Skills Help With

This repository packages reusable Python-focused Codex skills for creating `uv` projects and workspaces, bootstrapping FastAPI or FastMCP services, and standardizing pytest execution in `uv`-managed repositories.

Current scaffold defaults now include typed configuration via `pydantic-settings`, a committed `.env` for safe defaults, and an ignored `.env.local` for local or secret overrides.

## Skill Guide (When To Use What)

- `bootstrap-python-mcp-service`
  - Bootstrap `uv` FastMCP projects and workspaces, plus optional OpenAPI or FastAPI mapping guidance.
- `bootstrap-python-service`
  - Bootstrap `uv` FastAPI projects and workspaces with consistent app, test, and quality-tool defaults.
- `bootstrap-uv-python-workspace`
  - Create the shared `uv` package or workspace scaffolds used directly or as the basis for the higher-level bootstrap skills.
- `uv-pytest-unit-testing`
  - Standardize pytest setup, package-targeted runs, and troubleshooting for `uv` projects and workspaces.

## Quick Start (Vercel Skills CLI)

Use the Vercel `skills` CLI to install from this repository.

```bash
npx skills add gaelic-ghost/python-skills
```

## Install individually by Skill or Skill Pack

```bash
npx skills add gaelic-ghost/python-skills --skill bootstrap-python-mcp-service
npx skills add gaelic-ghost/python-skills --skill bootstrap-python-service
npx skills add gaelic-ghost/python-skills --skill bootstrap-uv-python-workspace
npx skills add gaelic-ghost/python-skills --skill uv-pytest-unit-testing
```

Install all active skills:

```bash
npx skills add gaelic-ghost/python-skills --all
```

## Update Skills

```bash
npx skills check
npx skills update
```

## More resources for similar Skills

### Find Skills like these with the `skills` CLI by Vercel — [vercel-labs/skills](https://github.com/vercel-labs/skills)

```bash
npx skills find "python uv workspace bootstrap"
npx skills find "fastapi scaffold"
npx skills find "fastmcp bootstrap"
npx skills find "pytest uv workflow"
```

### Find Skills like these with the `Find Skills` Agent Skill by Vercel — [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills)

```bash
npx skills add vercel-labs/agent-skills --skill find-skills
```

Then ask your Agent for help finding a skill for "" or ""

### Leaderboard

- Skills catalog: [skills.sh](https://skills.sh/)

## Repository Layout

```text
.
├── README.md
├── ROADMAP.md
├── AGENTS.md
├── docs/
│   └── maintainers/
│       ├── reality-audit.md
│       └── workflow-atlas.md
├── .github/
│   └── scripts/
│       └── validate_repo_docs.sh
├── scripts/
│   └── validate_repo_metadata.py
├── bootstrap-python-mcp-service/
├── bootstrap-python-service/
├── bootstrap-uv-python-workspace/
└── uv-pytest-unit-testing/
```

## Notes

- The repository stays flat at the root; active skills are not nested under `skills/`.
- Root docs are the canonical installation and discovery surface.
- Each skill’s maintained contract lives in `SKILL.md` plus `agents/openai.yaml`; per-skill `README.md` files are intentionally retired.
- Generated bootstrap projects now ship `pydantic-settings`, a committed `.env`, and an ignored `.env.local`.
- Maintainer-side validation is standardized on `uv run pytest` and `uv run scripts/validate_repo_metadata.py`.

## Keywords

Codex skills, Python skills, `uv`, FastAPI, FastMCP, pytest, workspace bootstrap, automation workflows, documentation alignment.

## License

Apache-2.0. See [LICENSE](./LICENSE).
