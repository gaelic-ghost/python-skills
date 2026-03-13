#!/usr/bin/env zsh
set -euo pipefail

cd "$(dirname "$0")/../.."
uv run python scripts/validate_repo_metadata.py
