#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_ROOT="$(pwd)"
PACKAGE_NAME=""
TEST_PATH=""

usage() {
  cat <<'USAGE'
Usage: run_pytest_uv.sh [--workspace-root PATH] [--package NAME] [--path TEST_PATH] [-- <pytest args>]

Options:
  --workspace-root PATH  Repository root containing pyproject.toml (default: cwd)
  --package NAME         Workspace member package name for package-scoped run
  --path TEST_PATH       Optional test path selector (e.g., tests/unit)
  --                     Pass remaining args directly to pytest
  -h, --help             Show this help
USAGE
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

EXTRA_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace-root)
      WORKSPACE_ROOT="$2"
      shift 2
      ;;
    --package)
      PACKAGE_NAME="$2"
      shift 2
      ;;
    --path)
      TEST_PATH="$2"
      shift 2
      ;;
    --)
      shift
      EXTRA_ARGS=("$@")
      break
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_cmd uv

if [[ ! -d "$WORKSPACE_ROOT" ]]; then
  echo "error: workspace root does not exist: $WORKSPACE_ROOT" >&2
  exit 1
fi

if [[ ! -f "$WORKSPACE_ROOT/pyproject.toml" ]]; then
  echo "error: missing pyproject.toml at $WORKSPACE_ROOT/pyproject.toml" >&2
  exit 1
fi

cd "$WORKSPACE_ROOT"

CMD=(uv run)
if [[ -n "$PACKAGE_NAME" ]]; then
  CMD+=(--package "$PACKAGE_NAME")
fi
CMD+=(pytest)

if [[ -n "$TEST_PATH" ]]; then
  CMD+=("$TEST_PATH")
fi

if [[ "${#EXTRA_ARGS[@]}" -gt 0 ]]; then
  CMD+=("${EXTRA_ARGS[@]}")
fi

echo "info: running: ${CMD[*]}"
"${CMD[@]}"
