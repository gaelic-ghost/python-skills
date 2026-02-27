#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Bootstrap a uv Python workspace.

Usage:
  init_uv_python_workspace.sh --name <workspace-name> [options]

Required:
  --name <name>                    Workspace name

Options:
  --path <path>                    Target directory (default: ./<name>)
  --members "a,b,c"                Workspace member names (default: core-lib,api-service)
  --profile-map "a=package,b=service"
                                   Member profile assignments
  --python <version>               Python version (default: 3.13)
  --force                          Allow non-empty target directory
  --initial-commit                 Create initial git commit on success
  --no-git-init                    Skip git init (default is enabled)
  -h, --help                       Show help
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
  local run_cmds="$4"
  local test_cmds="$5"
  local notes="$6"

  sed \
    -e "s|__NAME__|$name|g" \
    -e "s|__TYPE__|workspace|g" \
    -e "s|__RUN_COMMANDS__|$run_cmds|g" \
    -e "s|__TEST_COMMANDS__|$test_cmds|g" \
    -e "s|__NOTES__|$notes|g" \
    "$template" >"$out"
}

profile_for_member() {
  local member="$1"
  local default_profile="$2"
  local map="$3"

  if [ -z "$map" ]; then
    printf '%s\n' "$default_profile"
    return
  fi

  local old_ifs="$IFS"
  IFS=','
  for entry in $map; do
    local key="${entry%%=*}"
    local value="${entry#*=}"
    if [ "$key" = "$member" ]; then
      IFS="$old_ifs"
      printf '%s\n' "$value"
      return
    fi
  done
  IFS="$old_ifs"

  printf '%s\n' "$default_profile"
}

NAME=""
TARGET=""
MEMBERS_CSV="core-lib,api-service"
PROFILE_MAP=""
PYTHON_VERSION="3.13"
FORCE=0
INITIAL_COMMIT=0
GIT_INIT=1

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --path) TARGET="$2"; shift 2 ;;
    --members) MEMBERS_CSV="$2"; shift 2 ;;
    --profile-map) PROFILE_MAP="$2"; shift 2 ;;
    --python) PYTHON_VERSION="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    --initial-commit) INITIAL_COMMIT=1; shift ;;
    --no-git-init) GIT_INIT=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown argument: $1" ;;
  esac
done

[ -n "$NAME" ] || fail "--name is required"

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

uv init --bare --name "$NAME" --python "$PYTHON_VERSION" --vcs none "$TARGET"
cd "$TARGET"

cat >> pyproject.toml <<'TOML'

[tool.uv.workspace]
members = ["packages/*"]
TOML

mkdir -p packages

MEMBERS=()
PACKAGE_MEMBERS=()
SERVICE_MEMBERS=()

old_ifs="$IFS"
IFS=','
for raw in $MEMBERS_CSV; do
  member="$(printf '%s' "$raw" | xargs)"
  [ -n "$member" ] || continue
  MEMBERS+=("$member")
done
IFS="$old_ifs"

[ "${#MEMBERS[@]}" -gt 0 ] || fail "No valid members provided"

for idx in "${!MEMBERS[@]}"; do
  member="${MEMBERS[$idx]}"
  default_profile="service"
  if [ "$idx" -eq 0 ]; then
    default_profile="package"
  fi

  profile="$(profile_for_member "$member" "$default_profile" "$PROFILE_MAP")"
  [ "$profile" = "package" ] || [ "$profile" = "service" ] || fail "Invalid profile '$profile' for member '$member'"

  member_path="packages/$member"
  module_name="$(normalize_module_name "$member")"
  if [ "$profile" = "package" ]; then
    uv init --package --lib --name "$member" --python "$PYTHON_VERSION" --vcs none "$member_path"
    PACKAGE_MEMBERS+=("$member")
  else
    uv init --app --name "$member" --python "$PYTHON_VERSION" --vcs none "$member_path"
    SERVICE_MEMBERS+=("$member")
  fi

  uv add --package "$member" --group dev pytest ruff mypy
  append_tooling_config "$member_path/pyproject.toml" "$PYTHON_VERSION"

  if [ "$profile" = "service" ]; then
    uv add --package "$member" fastapi --extra standard
    mkdir -p "$member_path/app" "$member_path/tests"
    touch "$member_path/app/__init__.py"

    cat > "$member_path/app/main.py" <<'PY'
from fastapi import FastAPI

app = FastAPI(title="Workspace Service")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
PY

    cat > "$member_path/tests/test_${module_name}_service.py" <<'PY'
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.main import app


def test_app_exists() -> None:
    assert app is not None
PY
  else
    mkdir -p "$member_path/tests"
    cat > "$member_path/tests/test_${module_name}_import.py" <<PY
from ${module_name} import __name__ as imported_name


def test_package_import() -> None:
    assert imported_name == "${module_name}"
PY
  fi
done

if [ "${#PACKAGE_MEMBERS[@]}" -gt 0 ] && [ "${#SERVICE_MEMBERS[@]}" -gt 0 ]; then
  shared_pkg="${PACKAGE_MEMBERS[0]}"
  for svc in "${SERVICE_MEMBERS[@]}"; do
    uv add --package "$svc" "$shared_pkg"
  done
fi

uv lock
uv sync --all-packages
uv run --all-packages pytest

for member in "${MEMBERS[@]}"; do
  (
    cd "packages/$member"
    uv run ruff check .
    uv run mypy .
  )
done

render_readme \
  "$README_TEMPLATE" \
  "README.md" \
  "$NAME" \
  "uv run --all-packages pytest" \
  "uv run --all-packages pytest; (cd packages/<member> && uv run ruff check . && uv run mypy .)" \
  "Members are created under packages/. If both package and service profiles exist, services depend on the first package member via workspace sources."

if [ "$GIT_INIT" -eq 1 ]; then
  if [ ! -d .git ]; then
    git init
  fi
  git add .
  if [ "$INITIAL_COMMIT" -eq 1 ]; then
    git commit -m "Initial workspace scaffold from bootstrap-uv-python-workspace"
  fi
fi

echo "[OK] Workspace scaffold complete: $TARGET"
