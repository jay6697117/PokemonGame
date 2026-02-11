# Decisions

## 2026-02-11 Task 1
- Bootstrap uses `project.godot` + autoload `GameConfig` as the single source for baseline gameplay config values.
- Input baseline mapped for two local keyboard players (P1: WASD/FGH, P2: IJKL/UOP).
- Evidence logs are stored under `.sisyphus/evidence/` for deterministic QA token tracking.

## 2026-02-11 Task 2
- Implemented state machine in `scripts/combat/fighter_state_machine.gd` with explicit allowed-transition map and guard logging.
- Implemented fixed-step simulation in `scripts/combat/fixed_tick_combat_loop.gd` at 60 ticks/second.
- Task 2 QA scripts created under `qa/` and validated with deterministic output tokens.

## 2026-02-11 Task 3
- Input buffering implemented with default 6-frame window in `scripts/input/player_input_channel.gd`.
- Local dual-player manager implemented in `scripts/input/local_input_manager.gd`.
- Direction sequence capability added as a basic ordered matcher for future command recognition.

## 2026-02-11 Task 4
- Added collision resolver at `scripts/combat/collision/hitbox_resolver.gd` with overlap + registry-based duplicate-hit guard.
- Added damage facade at `scripts/combat/damage/hit_resolution_service.gd` to keep registry ownership centralized.
- QA contracts for Task 4 stabilized at tokens `QA_HITBOX_RESOLUTION_OK` and `QA_SINGLE_HIT_GUARD_OK`.

## 2026-02-11 Task 6
- Roster source of truth is `data/roster.json`, which references two fighter JSON files.
- Fighter contract enforcement is centralized in `scripts/roster/fighter_schema_validator.gd`.
- Roster loading path + schema validation + mirror-selection behavior are covered by dedicated QA scripts.

## 2026-02-11 Task 5
- Round rules implemented in `scripts/match/round_manager.gd` with phases `ROUND_ACTIVE`, `ROUND_END`, `MATCH_END`.
- Timeout tie policy fixed as round restart (no score increment), tracked by `tie_restart_count` and `last_event`.
- HUD baseline scaffold added at `scenes/ui/match_hud.tscn` with `scripts/match/match_hud.gd` + model snapshot syncing.

## 2026-02-11 Task 7
- Integrated flow in `scripts/flow/match_flow_controller.gd` with explicit phase transitions.
- Character select, battle, and result scene stubs now map to dedicated flow scripts.
- Rematch now guarantees transient reset through `LocalInputManager.reset_for_rematch()` and round restart.

## 2026-02-11 Task 8
- Added unified test runner at `tests/run_all_tests.gd` for module-level checks.
- Added regression suite `qa/qa_regression_suite.gd` covering 4 edge scenarios.
- Added private-prototype guard `qa/qa_private_prototype_guard.gd` to block unintended public-release pipeline artifacts.

- 2026-02-11: Added `GameConfig` as project autoload script containing task-1 baseline constants (`60 FPS`, `1000 HP`, `60s round`, `BO3`) and InputMap key bindings.
- 2026-02-11: Main flow baseline uses `scenes/main_menu.tscn` as `run/main_scene`, with `scripts/main_menu.gd` exposing `goto_character_select()` to enter `scenes/character_select.tscn`.
