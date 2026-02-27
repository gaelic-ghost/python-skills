#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_ROOT="$(pwd)"
PACKAGE_NAME=""
WITH_COV=0
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: bootstrap_pytest_uv.sh [--workspace-root PATH] [--package NAME] [--with-cov] [--dry-run]

Options:
  --workspace-root PATH  Repository root containing pyproject.toml (default: cwd)
  --package NAME         Workspace member package name for package-scoped install
  --with-cov             Also install pytest-cov and add coverage defaults when creating config
  --dry-run              Print planned commands and file changes without mutating files
  -h, --help             Show this help
USAGE
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

append_pytest_config_if_missing() {
  local pyproject_path="$1"
  local addopts_value="-ra"

  if [[ "$WITH_COV" -eq 1 ]]; then
    addopts_value="-ra --cov --cov-report=term-missing"
  fi

  if rg -n "^\[tool\.pytest\.ini_options\]" "$pyproject_path" >/dev/null 2>&1; then
    echo "info: [tool.pytest.ini_options] already exists in $pyproject_path; leaving config unchanged"
    return 0
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] append baseline [tool.pytest.ini_options] to $pyproject_path"
    return 0
  fi

  cat >>"$pyproject_path" <<EOF_CFG

[tool.pytest.ini_options]
addopts = "$addopts_value"
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
EOF_CFG

  echo "info: added [tool.pytest.ini_options] to $pyproject_path"
}

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
    --with-cov)
      WITH_COV=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
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
require_cmd rg

if [[ ! -d "$WORKSPACE_ROOT" ]]; then
  echo "error: workspace root does not exist: $WORKSPACE_ROOT" >&2
  exit 1
fi

PYPROJECT_PATH="$WORKSPACE_ROOT/pyproject.toml"
if [[ ! -f "$PYPROJECT_PATH" ]]; then
  echo "error: missing pyproject.toml at $PYPROJECT_PATH" >&2
  exit 1
fi

cd "$WORKSPACE_ROOT"

declare -a deps
if [[ "$WITH_COV" -eq 1 ]]; then
  deps=(pytest pytest-cov)
else
  deps=(pytest)
fi

if [[ -n "$PACKAGE_NAME" ]]; then
  run_cmd uv add --package "$PACKAGE_NAME" --dev "${deps[@]}"
else
  run_cmd uv add --dev "${deps[@]}"
fi

append_pytest_config_if_missing "$PYPROJECT_PATH"

echo "info: bootstrap complete"
