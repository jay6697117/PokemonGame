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

run_step_with_tokens() {
  local title="$1"
  local expected_tokens="$2"
  shift 2

  printf "\n[STEP] %s\n" "$title"

  local output
  if ! output=$("$@" 2>&1); then
    printf "%s\n" "$output"
    return 1
  fi

  printf "%s\n" "$output"

  local token
  local -a tokens
  IFS='|' read -r -a tokens <<< "$expected_tokens"
  for token in "${tokens[@]}"; do
    if [[ "$output" != *"$token"* ]]; then
      printf "TOKEN_MISSING:%s\n" "$token" >&2
      return 1
    fi
    printf "TOKEN_OK:%s\n" "$token"
  done
}

run_step "Godot version check" \
  godot4 --version

run_step "Headless boot check" \
  godot4 --headless --path . --quit

run_step_with_tokens "Full match flow check" \
  "QA_FULL_MATCH_FLOW_OK|FLOW:SELECT->FIGHT->RESULT->REMATCH" \
  godot4 --headless --path . --script "res://qa/qa_full_match_flow.gd"

run_step_with_tokens "Rematch reset check" \
  "QA_REMATCH_RESET_OK|HP_RESET:true|INPUT_BUFFER_CLEARED:true" \
  godot4 --headless --path . --script "res://qa/qa_rematch_state_reset.gd"

run_step_with_tokens "Regression suite check" \
  "QA_REGRESSION_OK|EDGE_CASES:4/4" \
  godot4 --headless --path . --script "res://qa/qa_regression_suite.gd"

run_step_with_tokens "Core test runner check" \
  "TESTS_ALL_PASS" \
  godot4 --headless --path . --script "res://tests/run_all_tests.gd"

run_step_with_tokens "Phase-1 visual contract check" \
  "HUD_THEME_PROFILE:ANIME_ARENA|REQUIRED_NODES_PRESENT:true|FIGHTER_VISUALS_BOUND:true|STAGE_ATMOSPHERE_ACTIVE:true|ROUND_TRANSITION_STYLE_OK|QA_PHASE1_VISUAL_CONTRACT_OK" \
  godot4 --headless --path . --script "res://qa/qa_phase1_visual_contract.gd"

run_step_with_tokens "Phase-1 asset license check" \
  "UNLICENSED_ASSETS:0|FORBIDDEN_OFFICIAL_ASSETS:0|QA_ASSET_LICENSE_OK" \
  godot4 --headless --path . --script "res://qa/qa_asset_license_manifest.gd"

run_step_with_tokens "Phase-1 placeholder visuals check" \
  "LEGACY_PLACEHOLDER_REFERENCES:0|FIGHTER_VISUAL_BINDINGS_OK:true|QA_PLACEHOLDER_VISUALS_REMOVED_OK" \
  godot4 --headless --path . --script "res://qa/qa_placeholder_visuals_removed.gd"

run_step_with_tokens "Phase-1 hit feedback check" \
  "QA_HIT_FEEDBACK_OK|HIT_TO_VFX_RATIO:1.00" \
  godot4 --headless --path . --script "res://qa/qa_hit_feedback_pipeline.gd"

run_step_with_tokens "Phase-1 rematch visual reset check" \
  "QA_REMATCH_VISUAL_RESET_OK|ACTIVE_VFX_NODES_AFTER_RESET:0" \
  godot4 --headless --path . --script "res://qa/qa_rematch_visual_reset.gd"

run_step_with_tokens "Phase-1 rematch transition race guard check" \
  "KO_STALE_BLOCKED:true|TIMEUP_STALE_BLOCKED:true|QA_REMATCH_TRANSITION_RACE_GUARD_OK" \
  godot4 --headless --path . --script "res://qa/qa_rematch_transition_race_guard.gd"

run_step_with_tokens "Phase-1 hit-stop scale stability check" \
  "QA_HIT_STOP_SCALE_STABILITY_OK" \
  godot4 --headless --path . --script "res://qa/qa_hit_stop_scale_stability.gd"

run_step_with_tokens "Phase-1 layout metrics scaling check" \
  "QA_LAYOUT_METRICS_SCALING_OK" \
  godot4 --headless --path . --script "res://qa/qa_layout_metrics_scaling.gd"

run_step_with_tokens "Private prototype guard check" \
  "QA_PRIVATE_GUARD_OK|PUBLIC_RELEASE_STEPS_PRESENT:false" \
  godot4 --headless --path . --script "res://qa/qa_private_prototype_guard.gd"

printf "\nDEMO_CHECKLIST_PASS\n"

if [[ "$MODE" == "--verify-only" ]]; then
  printf "Verification finished.\n"
  exit 0
fi

printf "\nLaunching game window...\n"
exec godot4 --path .
