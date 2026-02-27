# Customizing `bootstrap-uv-python-workspace`

## Purpose and When To Use

Use this skill to scaffold uv-managed Python projects and workspaces with package/service profiles and deterministic defaults.

## Opinionated Defaults

- Uses `uv` for initialization, deps, lock/sync, and execution.
- Default Python version is `3.13`.
- Workspace default members are `core-lib,api-service`.
- Default profile behavior sets first member to `package`, remainder to `service`.
- Quality defaults are `pytest`, `ruff`, `mypy`.
- Generated README content comes from a shared template.

## What To Customize First

1. Python runtime baseline.
2. Profile and member defaults for workspace creation.
3. Dependency bootstrap and quality stack.
4. Generated README content and project notes.
5. Linking behavior between package and service members.

## Customization Recipes

1. Change Python default:
- Update default `--python` in both workspace and project scripts.
- Update `SKILL.md` and recipe references to match.

2. Change member/profile defaults:
- Edit `MEMBERS_CSV` and profile fallback logic in `scripts/init_uv_python_workspace.sh`.
- Keep examples synchronized in `SKILL.md`.

3. Customize dependency bootstrap:
- Modify `uv add --group dev ...` defaults in both scripts.
- Add/remove tools (for example `pyright`, `pytest-cov`) and adjust check commands.

4. Customize generated README template:
- Edit `assets/README.md.tmpl` to match your org standards.
- Ensure script render placeholders still map correctly.

5. Change workspace linking behavior:
- Update the logic that adds package dependencies to service members.
- Document any new linking rules in `SKILL.md` and references.

## Example Codex Prompts

- "Make this skill default to package-only workspace members."
- "Set Python default to 3.11 and tighten ruff rules."
- "Customize generated README template for internal engineering standards."
- "Replace mypy with pyright in generated quality checks."
- "Disable automatic service-to-package linking in workspace mode."

## Validation Checklist After Customization

1. Scaffold package project, service project, and workspace variants.
2. Verify generated `pyproject.toml`, tests, and README outputs match intended defaults.
3. Run generated quality checks to confirm toolchain consistency.
4. Verify docs/examples align with actual scaffold behavior.
5. Re-run sensitive-data scan before release.
