# Reality Audit Guide

## Purpose

Use this audit when changing root docs, skill contracts, scripts, references, or metadata. The goal is to keep the shipped repo surface aligned with what the skills actually do.

## Root Doc Audit

Check that:

- `README.md` uses the canonical `*-skills` section schema
- install commands use current `skills` CLI syntax
- the active skill inventory matches the actual top-level directories with `SKILL.md`
- the repository layout snippet matches the real repo
- `ROADMAP.md` uses checklist-style sections and milestone progress

## Skill Contract Audit

For each skill directory:

- frontmatter `name` matches the directory name
- frontmatter includes the repo-required open-standard fields: `license`, `compatibility`, `metadata`, and `allowed-tools`
- `SKILL.md` describes the actual entrypoint and supported modes
- every referenced file under `scripts/`, `references/`, `assets/`, and `agents/` exists
- runtime defaults in docs match the scripts
- fallback or handoff guidance reflects the real current surface

## Metadata Audit

For each `agents/openai.yaml`:

- `display_name` is readable and stable
- `short_description` matches the skill’s actual scope
- `brand_color` is present and valid
- `default_prompt` names the canonical skill and primary behavior accurately
- `policy.allow_implicit_invocation` is present and reflects intended triggering behavior
- any listed dependencies or policy knobs reflect real usage

## Script Audit

Check that:

- developer-facing shell entrypoints use the repo’s current shell policy
- help text matches actual supported flags
- docs use `uv run ...` for Python commands
- generated next-step commands match what the scaffold really creates
- generated projects include the committed `.env`, ignored `.env.local`, and `pydantic-settings`-based config surface described in the docs

## Maintainer Validation Commands

Run these from repo root:

```bash
uv sync --dev
zsh .github/scripts/validate_repo_docs.sh
uv run pytest
```

If these commands and the docs disagree, the docs are stale until updated in the same pass.
