# Security and Personalization Scan

- Scan timestamp (UTC): `2026-02-27T19:06:34Z`
- Scope: all tracked files under:
  - `bootstrap-python-mcp-service/`
  - `bootstrap-python-service/`
  - `bootstrap-uv-python-workspace/`
  - `uv-pytest-unit-testing/`

## Methods Used

## Sensitive data and PII pattern classes

Pattern families scanned with `rg`:

- Secrets and credentials:
  - `OPENAI_API_KEY`, `API_KEY`, `SECRET`, `TOKEN`, `PASSWORD`, `auth_token`
  - private key markers: `BEGIN ... PRIVATE KEY`, `-----BEGIN`
  - known token formats: `gho_...`, `sk-...`, `AKIA...`, `xox...`
- Direct PII markers:
  - email address regex patterns

## Personalization marker classes

Pattern families scanned with `rg`:

- platform assumptions (`macOS`)
- tooling assumptions (`uv`-exclusive commands)
- runtime defaults (`Python 3.13`)
- scaffold defaults (`members`, `profile-map`, workspace naming)
- MCP integration defaults (`fastmcp_docs`, implicit invocation policy)

## Sensitive Data Findings

No hard secrets, credentials, private keys, or direct PII were detected in tracked skill files under the scoped directories.

Notes:

- A root-level Git remote URL exists in `.git/config` (expected repository metadata, not a secret).
- Localhost loopback documentation references (for example, `127.0.0.1`) are operational docs, not sensitive data.

## Personalization Findings

| Skill | Personalization found | Why downstream users may customize |
|---|---|---|
| `bootstrap-python-mcp-service` | macOS-first language, `uv` workflow, default Python `3.13`, default workspace members/profile behavior, `fastmcp_docs` MCP dependency assumptions | Teams may use Linux CI/dev containers, different Python baselines, different workspace topology, or no MCP docs dependency |
| `bootstrap-python-service` | macOS-first conventions, `uv` workflow, FastAPI run-mode defaults, default Python `3.13`, workspace naming/profile conventions | Users may prefer Docker-first runs, alternate app layout, different type/lint stacks, or different workspace/member naming standards |
| `bootstrap-uv-python-workspace` | `uv`-exclusive scaffolding flow, default Python `3.13`, package/service profile defaults, default members (`core-lib,api-service`) and profile-map conventions | Users may prefer package-only repos, different runtime baselines, stricter lint/type defaults, or different workspace composition |
| `uv-pytest-unit-testing` | pytest baseline config choices, `uv run --package` usage model, marker/coverage defaults | Users may enforce coverage thresholds, different test directory conventions, or stricter marker policy |

## Public Repo Suitability

This repository is suitable for a public release based on the current scan results:

- Sensitive-data scan: no blocking findings.
- Personalization scan: non-sensitive but meaningful defaults exist; these are documented in per-skill customization READMEs.

## Re-scan Checklist for Future Releases

1. Re-run sensitive-data pattern scan across tracked files.
2. Re-run personalization scan for new defaults added to scripts/templates.
3. Review `.git/config` output only for accidental credential embedding in remote URLs.
4. Verify generated docs/examples do not include personal paths, usernames, or internal hosts.
5. Record scan timestamp and findings updates in this file before release tagging.
