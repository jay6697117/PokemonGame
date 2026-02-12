#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

export PATH="$ROOT_DIR/bin:$PATH"

MODE="${1:-}"

run_step() {
  local title="$1"
  shift
  printf "\n[STEP] %s\n" "$title"
  "$@"
}

run_step "Godot version check" \
  godot4 --version

run_step "Headless boot check" \
  godot4 --headless --path . --quit

run_step "Full match flow check" \
  godot4 --headless --path . --script "res://qa/qa_full_match_flow.gd"

run_step "Rematch reset check" \
  godot4 --headless --path . --script "res://qa/qa_rematch_state_reset.gd"

run_step "Regression suite check" \
  godot4 --headless --path . --script "res://qa/qa_regression_suite.gd"

run_step "Core test runner check" \
  godot4 --headless --path . --script "res://tests/run_all_tests.gd"

run_step "Private prototype guard check" \
  godot4 --headless --path . --script "res://qa/qa_private_prototype_guard.gd"

printf "\nDEMO_CHECKLIST_PASS\n"

if [[ "$MODE" == "--verify-only" ]]; then
  printf "Verification finished.\n"
  exit 0
fi

printf "\nLaunching game window...\n"
exec godot4 --path .
