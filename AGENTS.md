# AGENTS.md

## Repository Policy

- This repository is the source of truth for skill development.
- Do all skill authoring, refactoring, testing, and maintenance only in this repository.
- Treat managed production skills at `~/.agents/skills` as read-only deployment artifacts.
- Never edit files under `~/.agents/skills` directly; make changes here and promote through the normal sync/release flow.

## Durable Skill Customization

- Global durable customization path for shipped skills: `~/.config/gaelic-ghost/python-skills/<skill-name>/customization.yaml`.
- Repo-local override path: `.codex/profiles/<skill-name>/customization.yaml`.
- Repo-local override files are user-local and must remain untracked.
- Built-in script defaults remain canonical fallback when no profile exists or when bypass flags are used.
