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
  [[ "$INITIAL_COMMIT" -eq 1 ]] && cmd+=(--initial-commit)
  [[ "$NO_GIT_INIT" -eq 1 ]] && cmd+=(--no-git-init)

  "${cmd[@]}"

  echo "Bootstrap complete: $TARGET_PATH"
  echo "Run (dev): cd $TARGET_PATH && uv run fastapi dev app/main.py"
  echo "Run (prod-style): cd $TARGET_PATH && uv run fastapi run app/main.py"
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
[[ "$INITIAL_COMMIT" -eq 1 ]] && cmd+=(--initial-commit)
[[ "$NO_GIT_INIT" -eq 1 ]] && cmd+=(--no-git-init)

"${cmd[@]}"

echo "Workspace bootstrap complete: $TARGET_PATH"
echo "Dev run example: cd $TARGET_PATH/packages/<service-member> && uv run fastapi dev app/main.py"
echo "Checks: cd $TARGET_PATH && uv run --all-packages pytest; (cd packages/<member> && uv run ruff check . && uv run mypy .)"
