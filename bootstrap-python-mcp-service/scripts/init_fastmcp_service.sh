#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  $(basename "$0") --name <service-name> [options]

Options:
  --name <name>                 Service/project/workspace name (required)
  --mode <project|workspace>    Bootstrap mode (default: project)
  --path <target-path>          Target directory (default: ./<name>)
  --python <version>            Python version (default: 3.13)
  --members "a,b,c"             Workspace members (workspace mode only)
  --profile-map "a=package,b=service"
                                Workspace profile assignments (workspace mode only)
  --force                       Allow non-empty target directory
  --initial-commit              Create an initial git commit after scaffold
  --no-git-init                 Skip git initialization
  -h, --help                    Show help
USAGE
}

fail() {
  echo "Error: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

abs_path() {
  local input="$1"
  if [[ -d "$input" ]]; then
    (cd "$input" && pwd)
  else
    local parent
    parent="$(dirname "$input")"
    local base
    base="$(basename "$input")"
    mkdir -p "$parent"
    (cd "$parent" && printf '%s/%s\n' "$(pwd)" "$base")
  fi
}

profile_for_member() {
  local member="$1"
  local default_profile="$2"
  local map="$3"

  if [[ -z "$map" ]]; then
    printf '%s\n' "$default_profile"
    return
  fi

  local old_ifs="$IFS"
  IFS=','
  for entry in $map; do
    local key="${entry%%=*}"
    local value="${entry#*=}"
    if [[ "$key" == "$member" ]]; then
      IFS="$old_ifs"
      printf '%s\n' "$value"
      return
    fi
  done
  IFS="$old_ifs"

  printf '%s\n' "$default_profile"
}

overlay_fastmcp_member() {
  local member_path="$1"
  local member_name="$2"
  local module_name
  module_name="$(printf '%s' "${member_name//-/_}" | tr -c '[:alnum:]_' '_')"

  [[ -d "$member_path" ]] || fail "member path not found: $member_path"

  (
    cd "$member_path"

    uv remove fastapi >/dev/null 2>&1 || true
    uv add fastmcp pydantic

    rm -f app/main.py main.py tests/test_service.py tests/test_tools.py tests/test_*_service.py
    mkdir -p app tests
    touch app/__init__.py

    cat > app/tools.py <<'PY'
import datetime


def health_payload() -> dict[str, str]:
    return {
        "status": "ok",
        "timestamp": datetime.datetime.now(datetime.UTC).isoformat(),
    }
PY

    cat > app/server.py <<PY
from fastmcp import FastMCP

from app.tools import health_payload

mcp = FastMCP("${member_name}")


@mcp.tool
def health() -> dict[str, str]:
    """Return a lightweight health payload for smoke testing."""
    return health_payload()


if __name__ == "__main__":
    mcp.run()
PY

    cat > "tests/test_${module_name}_tools.py" <<'PY'
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.tools import health_payload


def test_health_payload() -> None:
    payload = health_payload()
    assert payload["status"] == "ok"
    assert payload["timestamp"]
PY
  )
}

render_project_readme() {
  local service_name="$1"
  local output_path="$2"

  local script_dir
  script_dir="$(cd "$(dirname "$0")" && pwd)"
  local template
  template="$script_dir/../assets/README.md.tmpl"
  [[ -f "$template" ]] || fail "README template not found at '$template'"

  sed "s/__SERVICE_NAME__/$service_name/g" "$template" > "$output_path"
}

NAME=""
MODE="project"
TARGET_PATH=""
PYTHON_VERSION="3.13"
MEMBERS=""
PROFILE_MAP=""
FORCE=0
INITIAL_COMMIT=0
NO_GIT_INIT=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      NAME="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --path)
      TARGET_PATH="${2:-}"
      shift 2
      ;;
    --python)
      PYTHON_VERSION="${2:-}"
      shift 2
      ;;
    --members)
      MEMBERS="${2:-}"
      shift 2
      ;;
    --profile-map)
      PROFILE_MAP="${2:-}"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --initial-commit)
      INITIAL_COMMIT=1
      shift
      ;;
    --no-git-init)
      NO_GIT_INIT=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "unknown argument '$1'"
      ;;
  esac
done

[[ -n "$NAME" ]] || {
  usage >&2
  fail "--name is required"
}
[[ "$MODE" == "project" || "$MODE" == "workspace" ]] || fail "--mode must be 'project' or 'workspace'"
[[ "$NO_GIT_INIT" -eq 1 && "$INITIAL_COMMIT" -eq 1 ]] && fail "--initial-commit requires git initialization"

if [[ -z "$TARGET_PATH" ]]; then
  TARGET_PATH="./$NAME"
fi
TARGET_PATH="$(abs_path "$TARGET_PATH")"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHARED_PROJECT_SCRIPT="$SCRIPT_DIR/../../bootstrap-uv-python-workspace/scripts/init_uv_python_project.sh"
SHARED_WORKSPACE_SCRIPT="$SCRIPT_DIR/../../bootstrap-uv-python-workspace/scripts/init_uv_python_workspace.sh"

[[ -x "$SHARED_PROJECT_SCRIPT" ]] || fail "shared script not found or not executable: $SHARED_PROJECT_SCRIPT"
[[ -x "$SHARED_WORKSPACE_SCRIPT" ]] || fail "shared script not found or not executable: $SHARED_WORKSPACE_SCRIPT"

require_cmd uv
if [[ "$NO_GIT_INIT" -eq 0 || "$INITIAL_COMMIT" -eq 1 ]]; then
  require_cmd git
fi

if [[ "$MODE" == "project" ]]; then
  [[ -z "$MEMBERS" ]] || fail "--members is only valid with --mode workspace"
  [[ -z "$PROFILE_MAP" ]] || fail "--profile-map is only valid with --mode workspace"

  cmd=(
    "$SHARED_PROJECT_SCRIPT"
    --name "$NAME"
    --profile service
    --path "$TARGET_PATH"
    --python "$PYTHON_VERSION"
  )
  [[ "$FORCE" -eq 1 ]] && cmd+=(--force)
  [[ "$NO_GIT_INIT" -eq 1 ]] && cmd+=(--no-git-init)

  "${cmd[@]}"

  overlay_fastmcp_member "$TARGET_PATH" "$NAME"
  render_project_readme "$NAME" "$TARGET_PATH/README.md"

  (
    cd "$TARGET_PATH"
    uv lock
    uv sync
    uv run pytest
    uv run ruff check .
    uv run mypy .

    if [[ "$NO_GIT_INIT" -eq 0 ]]; then
      if [[ ! -d .git ]]; then
        git init
      fi
      git add .
      if [[ "$INITIAL_COMMIT" -eq 1 ]]; then
        git commit -m "Initial scaffold from bootstrap-python-mcp-service"
      fi
    fi
  )

  echo "Bootstrap complete: $TARGET_PATH"
  echo "Run: cd $TARGET_PATH && uv run python app/server.py"
  echo "Checks: cd $TARGET_PATH && uv run pytest && uv run ruff check . && uv run mypy ."
  exit 0
fi

cmd=(
  "$SHARED_WORKSPACE_SCRIPT"
  --name "$NAME"
  --path "$TARGET_PATH"
  --python "$PYTHON_VERSION"
)
[[ -n "$MEMBERS" ]] && cmd+=(--members "$MEMBERS")
[[ -n "$PROFILE_MAP" ]] && cmd+=(--profile-map "$PROFILE_MAP")
[[ "$FORCE" -eq 1 ]] && cmd+=(--force)
[[ "$NO_GIT_INIT" -eq 1 ]] && cmd+=(--no-git-init)

"${cmd[@]}"

members_csv="$MEMBERS"
if [[ -z "$members_csv" ]]; then
  members_csv="core-lib,api-service"
fi

declare -a WORKSPACE_MEMBERS=()
declare -a SERVICE_MEMBERS=()

old_ifs="$IFS"
IFS=','
for raw in $members_csv; do
  member="$(printf '%s' "$raw" | xargs)"
  [[ -n "$member" ]] || continue
  WORKSPACE_MEMBERS+=("$member")
done
IFS="$old_ifs"

[[ "${#WORKSPACE_MEMBERS[@]}" -gt 0 ]] || fail "no valid members provided"

for idx in "${!WORKSPACE_MEMBERS[@]}"; do
  member="${WORKSPACE_MEMBERS[$idx]}"
  default_profile="service"
  if [[ "$idx" -eq 0 ]]; then
    default_profile="package"
  fi

  profile="$(profile_for_member "$member" "$default_profile" "$PROFILE_MAP")"
  [[ "$profile" == "package" || "$profile" == "service" ]] || fail "invalid profile '$profile' for member '$member'"

  if [[ "$profile" == "service" ]]; then
    SERVICE_MEMBERS+=("$member")
  fi
done

[[ "${#SERVICE_MEMBERS[@]}" -gt 0 ]] || fail "workspace mode requires at least one service profile member"

for svc in "${SERVICE_MEMBERS[@]}"; do
  overlay_fastmcp_member "$TARGET_PATH/packages/$svc" "$svc"
done

(
  cd "$TARGET_PATH"
  uv lock
  uv sync --all-packages
  uv run --all-packages pytest

  for member in "${WORKSPACE_MEMBERS[@]}"; do
    (
      cd "packages/$member"
      uv run ruff check .
      uv run mypy .
    )
  done

  if [[ "$NO_GIT_INIT" -eq 0 ]]; then
    if [[ ! -d .git ]]; then
      git init
    fi
    git add .
    if [[ "$INITIAL_COMMIT" -eq 1 ]]; then
      git commit -m "Initial workspace scaffold from bootstrap-python-mcp-service"
    fi
  fi
)

echo "Workspace bootstrap complete: $TARGET_PATH"
echo "Run example: cd $TARGET_PATH/packages/<service-member> && uv run python app/server.py"
echo "Checks: cd $TARGET_PATH && uv run --all-packages pytest; (cd packages/<member> && uv run ruff check . && uv run mypy .)"
