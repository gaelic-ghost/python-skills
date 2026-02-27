# Customizing `uv-pytest-unit-testing`

## Purpose and When To Use

Use this skill to set up and run pytest consistently for uv projects and uv workspaces, including package-targeted test execution.

## Opinionated Defaults

- Execution flow assumes `uv run` and `uv run --package` patterns.
- Baseline pytest config is minimal and conservative.
- Marker conventions are guidance-first rather than hard enforcement.
- Coverage is optional by default.
- Troubleshooting order favors context and discovery checks before deeper changes.

## What To Customize First

1. Baseline pytest config and marker policy.
2. Test directory conventions and discovery patterns.
3. Coverage behavior (optional vs enforced threshold).
4. Workspace package-targeting defaults and command wrappers.
5. CI-oriented pass/fail expectations.

## Customization Recipes

1. Enforce coverage minimums:
- Update `scripts/bootstrap_pytest_uv.sh` to include `pytest-cov` defaults.
- Add config and command examples that fail below target thresholds.

2. Change test path conventions:
- Update references and defaults to `tests/unit`, `tests/integration`, `tests/e2e`.
- Ensure command examples and docs target the new structure.

3. Tighten marker policy:
- Add required marker registration and strict unknown-marker behavior in docs/config snippets.
- Include explicit guidance for CI failure on unregistered marks.

4. Adjust workspace targeting behavior:
- Update `scripts/run_pytest_uv.sh` defaults for package resolution or required flags.
- Keep pass-through arg docs aligned with the script behavior.

5. Update quality gate narrative:
- Clarify what is mandatory vs advisory for local and CI flows.

## Example Codex Prompts

- "Update this skill to enforce 85% coverage with `pytest-cov`."
- "Change default test path conventions to `tests/{unit,integration,e2e}`."
- "Add strict marker policy and fail on unknown markers."
- "Require `--package` for workspace execution and error otherwise."
- "Add CI examples that fail fast on first error and publish coverage reports."

## Validation Checklist After Customization

1. Run bootstrap script in dry-run and real mode for both single project and workspace-member contexts.
2. Verify generated or documented pytest config matches selected policies.
3. Execute representative test commands (root and `--package`) to confirm behavior.
4. Confirm references, prompts, and script behavior are consistent.
5. Re-run sensitive-data scan before release.
