#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Bootstrap a uv Python project.

Usage:
  init_uv_python_project.sh --name <project-name> [options]

Required:
  --name <name>               Project name

Options:
  --path <path>               Target directory (default: ./<name>)
  --profile <package|service> Scaffold profile (default: package)
  --python <version>          Python version (default: 3.13)
  --force                     Allow non-empty target directory
  --initial-commit            Create initial git commit on success
  --no-git-init               Skip git init (default is enabled)
  -h, --help                  Show help
USAGE
}

fail() {
  echo "[ERROR] $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

abs_path() {
  local input="$1"
  if [ -d "$input" ]; then
    (cd "$input" && pwd)
  else
    local parent="$(dirname "$input")"
    local base="$(basename "$input")"
    mkdir -p "$parent"
    (cd "$parent" && printf '%s/%s\n' "$(pwd)" "$base")
  fi
}

normalize_module_name() {
  local raw="${1//-/_}"
  printf '%s' "$raw" | tr -c '[:alnum:]_' '_'
}

target_from_python() {
  local v="$1"
  local major="$(printf '%s' "$v" | cut -d. -f1)"
  local minor="$(printf '%s' "$v" | cut -d. -f2)"
  printf 'py%s%s\n' "$major" "$minor"
}

append_tooling_config() {
  local pyproject="$1"
  local py_version="$2"

  if grep -q '^\[tool\.ruff\]' "$pyproject"; then
    return
  fi

  cat >>"$pyproject" <<EOF_CFG

[tool.ruff]
line-length = 100
target-version = "$(target_from_python "$py_version")"

[tool.ruff.lint]
select = ["E", "F", "UP", "B"]

[tool.pytest.ini_options]
addopts = "-q"
testpaths = ["tests"]

[tool.mypy]
python_version = "$py_version"
warn_unused_configs = true
check_untyped_defs = true
no_implicit_optional = true
EOF_CFG
}

render_readme() {
  local template="$1"
  local out="$2"
  local name="$3"
  local type="$4"
  local run_cmds="$5"
  local test_cmds="$6"
  local notes="$7"

  sed \
    -e "s|__NAME__|$name|g" \
    -e "s|__TYPE__|$type|g" \
    -e "s|__RUN_COMMANDS__|$run_cmds|g" \
    -e "s|__TEST_COMMANDS__|$test_cmds|g" \
    -e "s|__NOTES__|$notes|g" \
    "$template" >"$out"
}

NAME=""
TARGET=""
PROFILE="package"
PYTHON_VERSION="3.13"
FORCE=0
INITIAL_COMMIT=0
GIT_INIT=1

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --path) TARGET="$2"; shift 2 ;;
    --profile) PROFILE="$2"; shift 2 ;;
    --python) PYTHON_VERSION="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    --initial-commit) INITIAL_COMMIT=1; shift ;;
    --no-git-init) GIT_INIT=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown argument: $1" ;;
  esac
done

[ -n "$NAME" ] || fail "--name is required"
[ "$PROFILE" = "package" ] || [ "$PROFILE" = "service" ] || fail "--profile must be 'package' or 'service'"

if [ -z "$TARGET" ]; then
  TARGET="./$NAME"
fi
TARGET="$(abs_path "$TARGET")"

require_cmd uv
if [ "$GIT_INIT" -eq 1 ] || [ "$INITIAL_COMMIT" -eq 1 ]; then
  require_cmd git
fi

if [ -e "$TARGET" ]; then
  if [ -n "$(ls -A "$TARGET" 2>/dev/null || true)" ] && [ "$FORCE" -ne 1 ]; then
    fail "Target directory is not empty: $TARGET (use --force to allow)"
  fi
  if [ -f "$TARGET/pyproject.toml" ] && [ "$FORCE" -eq 1 ]; then
    fail "Refusing to overwrite existing pyproject.toml in $TARGET"
  fi
else
  mkdir -p "$TARGET"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
README_TEMPLATE="$SCRIPT_DIR/../assets/README.md.tmpl"
[ -f "$README_TEMPLATE" ] || fail "Missing template: $README_TEMPLATE"

if [ "$PROFILE" = "package" ]; then
  uv init --package --lib --name "$NAME" --python "$PYTHON_VERSION" --vcs none "$TARGET"
else
  uv init --app --name "$NAME" --python "$PYTHON_VERSION" --vcs none "$TARGET"
fi

cd "$TARGET"
MODULE_NAME="$(normalize_module_name "$NAME")"

if [ "$PROFILE" = "service" ]; then
  uv add fastapi --extra standard
  mkdir -p app tests
  touch app/__init__.py

  cat > app/main.py <<'PY'
from fastapi import FastAPI

app = FastAPI(title="Service API")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
PY

  cat > tests/test_service.py <<'PY'
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.main import app


def test_app_exists() -> None:
    assert app is not None
PY

  RUN_COMMANDS="uv run fastapi dev app/main.py"
  NOTES="This profile ships a FastAPI app at app/main.py. Use FastAPI CLI for local development."
else
  mkdir -p tests
  cat > tests/test_import.py <<PY
from ${MODULE_NAME} import __name__ as imported_name


def test_package_import() -> None:
    assert imported_name == "${MODULE_NAME}"
PY

  RUN_COMMANDS="uv run python -c \"import ${MODULE_NAME}\""
  NOTES="This profile uses src layout and uv_build for packaging."
fi

uv add --group dev pytest ruff mypy
append_tooling_config "pyproject.toml" "$PYTHON_VERSION"

render_readme \
  "$README_TEMPLATE" \
  "README.md" \
  "$NAME" \
  "$PROFILE project" \
  "$RUN_COMMANDS" \
  "uv run pytest; uv run ruff check .; uv run mypy ." \
  "$NOTES"

uv lock
uv sync
uv run pytest
uv run ruff check .
uv run mypy .

if [ "$GIT_INIT" -eq 1 ]; then
  if [ ! -d .git ]; then
    git init
  fi
  git add .
  if [ "$INITIAL_COMMIT" -eq 1 ]; then
    git commit -m "Initial scaffold from bootstrap-uv-python-workspace"
  fi
fi

echo "[OK] Project scaffold complete: $TARGET"
