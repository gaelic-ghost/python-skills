# Workflow Atlas

## Active Surface

`python-skills` currently ships four standalone top-level skills:

- `bootstrap-python-mcp-service`
- `bootstrap-python-service`
- `bootstrap-uv-python-workspace`
- `uv-pytest-unit-testing`

These are the only active public install surfaces that root docs and metadata should present.

## Skill Roles

### `bootstrap-uv-python-workspace`

This is the shared scaffolding base for generic `uv` project and workspace creation. It owns:

- package and service scaffold layout
- default Python/tooling versions
- README template rendering for generated projects
- shared workspace-member conventions

### `bootstrap-python-service`

This skill is the FastAPI-specialized layer on top of the shared `uv` bootstrap surface. It owns:

- FastAPI-oriented app and run-command guidance
- project-versus-workspace entrypoint selection for service creation
- handoff guidance to the shared workspace bootstrap scripts

### `bootstrap-python-mcp-service`

This skill is the FastMCP-specialized layer. It owns:

- FastMCP overlay behavior for generated projects or service members
- OpenAPI and FastAPI mapping-analysis guidance
- the `fastmcp_docs` documentation dependency callout

### `uv-pytest-unit-testing`

This skill owns repo-shape detection and pytest workflow guidance for `uv` repositories. It owns:

- bootstrap guidance for `tool.pytest.ini_options`
- package-targeted `uv run --package ... pytest` patterns
- test troubleshooting order and execution examples

## Contract Shape

Each active skill should maintain this minimum contract:

- frontmatter `name` matches the directory name
- `SKILL.md` clearly states when to use the skill and its primary workflow
- script references in `SKILL.md` resolve to real files
- `agents/openai.yaml` presents the same public surface as `SKILL.md`
- assets and references called out in docs actually exist

## Repo-Level Sources Of Truth

- Root `README.md`: install surface and discovery guidance
- `ROADMAP.md`: milestone history and near-term intent
- `AGENTS.md`: repo-local authoring and validation policy
- `docs/maintainers/reality-audit.md`: audit checklist for shipped reality
- `scripts/validate_repo_metadata.py`: mechanical validation for basic integrity

## Validation Ownership

Maintainers should validate three layers together whenever the skill surface changes:

1. Root docs:
   - inventory, install commands, and layout
2. Skill contracts:
   - `SKILL.md`, script inventory, references, and metadata
3. Validation path:
   - metadata validator and associated tests

Do not treat one of these layers as authoritative if the others disagree; update all of them in the same pass.
