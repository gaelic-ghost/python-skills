# python-skills

Codex plugin bundle for Python bootstrapping, testing, FastAPI service setup, and FastMCP scaffolding with `uv`-first workflows.

For standards and maintainer operating guidance, see [AGENTS.md](./AGENTS.md).

## Table of Contents

- [What This Codex Plugin Includes](#what-this-codex-plugin-includes)
- [Bundled Skill Guide](#bundled-skill-guide)
- [Local Plugin Testing](#local-plugin-testing)
- [Plugin Structure](#plugin-structure)
- [Maintainer Workflow](#maintainer-workflow)
- [Notes](#notes)
- [Keywords](#keywords)
- [License](#license)

## What This Codex Plugin Includes

This repository now ships as a plugin-first Codex bundle. The plugin root contains `.codex-plugin/plugin.json`, the bundled skills live under `skills/`, and the repo-local `.agents/plugins/marketplace.json` file lets Codex install the plugin directly from this checkout during local development.

Current scaffold defaults now include typed configuration via `pydantic-settings`, a committed `.env` for safe defaults, and an ignored `.env.local` for local or secret overrides.

## Bundled Skill Guide

- `bootstrap-python-mcp-service`
  - Bootstrap `uv` FastMCP projects and workspaces, plus optional OpenAPI or FastAPI mapping guidance.
- `bootstrap-python-service`
  - Bootstrap `uv` FastAPI projects and workspaces with consistent app, test, and quality-tool defaults.
- `bootstrap-uv-python-workspace`
  - Create the shared `uv` package or workspace scaffolds used directly or as the basis for the higher-level bootstrap skills.
- `uv-pytest-unit-testing`
  - Standardize pytest setup, package-targeted runs, and troubleshooting for `uv` projects and workspaces.

## Local Plugin Testing

Codex plugin packaging follows the OpenAI plugin and skills docs:

- [Build plugins](https://developers.openai.com/codex/plugins/build)
- [Agent Skills](https://developers.openai.com/codex/skills/)

From a local checkout, point Codex at this repository's marketplace file:

```bash
cat .agents/plugins/marketplace.json
```

The marketplace entry is repo-local and targets the plugin root via `./`, so the bundled skills are discovered from `.codex-plugin/plugin.json` and `./skills/`.

## Plugin Structure

```text
.
├── README.md
├── ROADMAP.md
├── AGENTS.md
├── .codex-plugin/
│   └── plugin.json
├── .agents/
│   └── plugins/
│       └── marketplace.json
├── docs/
│   └── maintainers/
│       ├── reality-audit.md
│       └── workflow-atlas.md
├── .github/
│   └── scripts/
│       └── validate_repo_docs.sh
├── scripts/
│   └── validate_repo_metadata.py
└── skills/
    ├── bootstrap-python-mcp-service/
    ├── bootstrap-python-service/
    ├── bootstrap-uv-python-workspace/
    └── uv-pytest-unit-testing/
```

## Maintainer Workflow

Keep the repo plugin-first:

- Maintain `.codex-plugin/plugin.json` as the plugin distribution contract.
- Maintain `.agents/plugins/marketplace.json` for local Codex install and smoke testing.
- Keep bundled skills under `skills/` only; do not reintroduce a flat top-level skill layout.
- Treat each skill's `SKILL.md` plus `agents/openai.yaml` as the canonical per-skill contract pair.
- Run repo validation before commits:

```bash
uv run scripts/validate_repo_metadata.py
uv run pytest
```

## Notes

- Root docs are the canonical installation and discovery surface.
- The repository is now plugin-first; active bundled skills live under `skills/`.
- `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json` are maintained surfaces, not generated throwaways.
- Each skill’s maintained contract lives in `SKILL.md` plus `agents/openai.yaml`; per-skill `README.md` files are intentionally retired.
- Generated bootstrap projects now ship `pydantic-settings`, a committed `.env`, and an ignored `.env.local`.
- Maintainer-side validation is standardized on `uv run pytest` and `uv run scripts/validate_repo_metadata.py`.

## Keywords

Codex skills, Python skills, `uv`, FastAPI, FastMCP, pytest, workspace bootstrap, automation workflows, documentation alignment.

## License

Apache-2.0. See [LICENSE](./LICENSE).
