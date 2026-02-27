# Customizing `bootstrap-python-mcp-service`

## Purpose and When To Use

Use this skill when you want to scaffold Python MCP servers (project or workspace mode) using `uv` and FastMCP with deterministic defaults.

## Opinionated Defaults

- Platform guidance is macOS-first.
- Tooling flow assumes `uv` and `git`.
- Default Python version is `3.13`.
- Workspace defaults are member/profile opinionated (first member package, others service).
- Mapping workflow assumes `scripts/assess_api_for_mcp.py` report style and `fastmcp_docs` lookup availability.
- Default quality gates are `pytest`, `ruff`, and `mypy`.

## What To Customize First

1. Runtime baseline: Python version and platform guidance.
2. Workspace composition: `--members` and `--profile-map` behavior.
3. FastMCP starter server/tool template behavior.
4. Mapping report strictness around sensitive endpoints.
5. Quality toolchain defaults and command output.

## Customization Recipes

1. Change default Python version:
- Update defaults in `SKILL.md` and `scripts/init_fastmcp_service.sh`.
- Keep examples and references aligned to the same version.

2. Change workspace member/profile defaults:
- Update fallback members and profile logic in `scripts/init_fastmcp_service.sh`.
- Update examples in `SKILL.md` to match new conventions.

3. Customize FastMCP template behavior:
- Edit generated `app/server.py` and `app/tools.py` template sections in `scripts/init_fastmcp_service.sh`.
- Optionally add required auth guards, telemetry hooks, or richer tool contracts.

4. Make mapping report stricter:
- Update classification and findings logic in `scripts/assess_api_for_mcp.py`.
- Add explicit warnings for `/admin` and `/internal` patterns or auth-sensitive operations.

5. Replace or extend quality defaults:
- Modify generated dependency and check commands (`pytest/ruff/mypy`) in scripts and docs.
- If adding `pyright` or coverage gates, reflect this in all run/check instructions.

## Example Codex Prompts

- "Modify this skill to default to Python 3.12 and Linux CI-first assumptions."
- "Change workspace defaults to three service members and no package member."
- "Make MCP mapping output stricter for internal/admin endpoints."
- "Update generated FastMCP server templates to include structured logging and auth placeholders."
- "Switch quality checks to pytest + ruff + pyright and update all docs/examples."

## Validation Checklist After Customization

1. Run script help and confirm defaults text is accurate.
2. Scaffold both project and workspace mode and verify generated files match intent.
3. Run quality checks in scaffolded outputs.
4. Verify `SKILL.md`, script defaults, and reference docs are consistent.
5. Re-run sensitive-data scan before release.
