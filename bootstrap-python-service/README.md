# Customizing `bootstrap-python-service`

## Purpose and When To Use

Use this skill to scaffold FastAPI service projects or uv workspaces with service members and baseline quality tooling.

## Opinionated Defaults

- Platform guidance is macOS-first.
- Workflow is `uv`-centric.
- Default Python version is `3.13`.
- FastAPI run guidance defaults to `fastapi dev` and optional `fastapi run`.
- Workspace member naming/profile conventions are predefined.
- Guardrails are strict around `--force`, `--no-git-init`, and `--initial-commit` combinations.

## What To Customize First

1. Runtime and run-mode conventions (local vs containerized).
2. Generated app structure and tests.
3. Workspace naming and member/profile defaults.
4. Guardrail strictness and failure behavior.
5. Quality stack (`pytest`, `ruff`, `mypy`) and commands.

## Customization Recipes

1. Adjust FastAPI run mode defaults:
- Edit command text and examples in `scripts/init_python_service.sh` and `SKILL.md`.
- Optionally emit Docker commands instead of host-native runtime commands.

2. Change generated app and test structure:
- Update underlying shared scaffold expectations in `bootstrap-uv-python-workspace` templates/scripts.
- Align `SKILL.md` examples with the chosen structure (for example `src/<module>/api.py`).

3. Update workspace conventions:
- Change default members/profile map in upstream workspace scaffolding and reflect in this skill examples.

4. Tune guardrails:
- Modify argument validation and fail conditions in `scripts/init_python_service.sh`.
- Keep CLI help and docs synchronized with guardrail logic.

5. Replace default checks:
- Swap in `pyright` or additional tooling in generated guidance.
- Ensure command examples and references stay consistent.

## Example Codex Prompts

- "Adjust this skill to prefer Docker-based local run commands."
- "Change generated app structure from `app/main.py` to `src/<module>/api.py`."
- "Switch default checks to include `pyright` and drop `mypy`."
- "Relax guardrails so `--force` can overwrite specific known files only."
- "Update workspace defaults for domain-based service naming conventions."

## Validation Checklist After Customization

1. Verify argument help text and validation behavior are consistent.
2. Scaffold a project and a workspace, then run generated run/check commands.
3. Confirm docs and examples use the same structure and tooling.
4. Validate guardrails with both valid and invalid flag combinations.
5. Re-run sensitive-data scan before release.
