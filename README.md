# python-skills

## Quick Add (Skills CLI)

Local Install

```bash
npx skills add gaelic-ghost/python-skills -a codex
```

Global Install

```bash
npx skills add gaelic-ghost/python-skills -g -a codex
```

For more on flags (`-a`, `-g`, etc.), see: [https://www.npmjs.com/package/skills](https://www.npmjs.com/package/skills)

Curated Codex skills for Python development workflows, focused on:

- `uv` project/workspace management
- FastAPI service bootstrapping
- FastMCP server bootstrapping
- pytest testing patterns for `uv` projects

## Included skills

- `bootstrap-python-mcp-service`
  - Bootstrap Python MCP server projects/workspaces using `uv` + FastMCP.
- `bootstrap-python-service`
  - Bootstrap Python FastAPI services using `uv`.
- `bootstrap-uv-python-workspace`
  - Scaffold Python projects and workspaces with `uv` defaults.
- `uv-pytest-unit-testing`
  - Set up and run pytest for `uv` projects and workspaces.

## Automation Templates

All included skills now provide inline automation prompt templates in `SKILL.md` for:

- Codex App automations (scheduled/background runs)
- Codex CLI automations (`codex exec` non-interactive runs)

Each template includes:

- Skill trigger usage (`$skill-name`)
- Scope boundaries
- Command intent
- Output/report contract
- Customization placeholders for local paths and options

## License

Apache-2.0. See [LICENSE](./LICENSE).
