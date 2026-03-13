# Project Roadmap

## Vision

- Keep `python-skills` as a focused, durable Python skill bundle with direct top-level entrypoints, deterministic local helpers, and docs that describe the shipped behavior exactly.

## Product principles

- Keep the active public surface constrained to standalone, directly installable skills.
- Prefer deterministic local scripts and validation over implied behavior.
- Keep skill docs, metadata, and script behavior synchronized.
- Keep maintainer tooling simple and repo-local rather than adding new abstraction layers.

## Milestone Progress

- [x] Milestone 1: Initial Python skill bundle
- [x] Milestone 2: FastAPI and FastMCP bootstrap coverage
- [x] Milestone 3: `uv` pytest workflow coverage
- [x] Milestone 4: Standards alignment and maintainer contract
- [ ] Milestone 5: Validation expansion and release hardening

## Milestone 1: Initial Python skill bundle

Scope:

- [x] Establish the repository and initial Python bootstrap surfaces.

Tickets:

- [x] Ship the first `uv` bootstrap skill.
- [x] Add repository-level install guidance.

Exit criteria:

- [x] The repository exists in a usable published form with Python-focused skills.

## Milestone 2: FastAPI and FastMCP bootstrap coverage

Scope:

- [x] Expand the repository beyond generic `uv` scaffolding into service-oriented workflows.

Tickets:

- [x] Add FastAPI bootstrap support.
- [x] Add FastMCP bootstrap support.
- [x] Include baseline verification commands in the shipped workflow guidance.

Exit criteria:

- [x] FastAPI and FastMCP bootstrap tasks are covered by active standalone skills.

## Milestone 3: `uv` pytest workflow coverage

Scope:

- [x] Add a dedicated pytest setup and execution skill for `uv` repositories.

Tickets:

- [x] Add bootstrap guidance for pytest in `uv` projects and workspaces.
- [x] Add package-targeted execution guidance for workspace members.

Exit criteria:

- [x] The repository includes a dedicated test workflow skill alongside the bootstrap skills.

## Milestone 4: Standards alignment and maintainer contract

Scope:

- [x] Align repo docs, roadmap shape, maintainer docs, skill contracts, and metadata with the standards used in the more recent skill repositories.

Tickets:

- [x] Rewrite the root `README.md` to the canonical section schema.
- [x] Add checklist-style `ROADMAP.md`.
- [x] Add `docs/maintainers/workflow-atlas.md` and `docs/maintainers/reality-audit.md`.
- [x] Retire per-skill `README.md` files as maintained surfaces.
- [x] Normalize each skill’s `SKILL.md` and `agents/openai.yaml` against shipped behavior.
- [x] Add repo-local metadata validation tooling and tests.
- [x] Normalize developer-facing shell entrypoints toward the repo’s Zsh-oriented shell policy.

Exit criteria:

- [x] Repo docs, maintainer docs, skill metadata, and validation tooling all describe the same active surface.

## Milestone 5: Validation expansion and release hardening

Scope:

- [ ] Extend validation and smoke coverage now that the repo has a canonical maintainer contract.

Tickets:

- [ ] Add dry-run or help-path smoke coverage for every shell entrypoint.
- [ ] Add validation for default-prompt and root-doc inventory drift.
- [ ] Document the release-check procedure for future tags and changelog updates.

Exit criteria:

- [ ] A future pass expands automated validation beyond the current metadata and docs integrity checks.
