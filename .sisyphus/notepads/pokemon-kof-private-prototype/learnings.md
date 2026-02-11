# Learnings

## 2026-02-11 Task 1
- Empty Godot input actions in `project.godot` can be safely populated at runtime via autoload (`GameConfig._ensure_input_actions`).
- Headless QA with `SceneTree` scripts works well for bootstrap checks and produces stable token output for CI-style verification.
- A minimal scene skeleton (`main_menu.tscn` + `character_select.tscn`) is enough to unblock downstream combat/state/input tasks.

## 2026-02-11 Task 2
- For headless QA scripts, explicit `preload("res://...")` is more reliable than relying on `class_name` symbol discovery.
- A strict transition table plus guard message (`BLOCKED: KO->ATTACK`) gives deterministic invalid-transition verification.
- Fixed-tick determinism is easy to assert by running the same scripted input trace twice and doing exact per-index comparison.

## 2026-02-11 Task 3
- Separating per-player input channels (`p1` / `p2`) keeps local-versus input conflicts isolated.
- A frame-window buffer with consume-once semantics prevents duplicated buffered actions.
- Focus-loss recovery should clear pressed-action maps centrally to avoid sticky input state.

## 2026-02-11 Task 4
- Using an explicit hit registry key (`attack_instance_id:defender_id`) is an effective guard against same-instance multi-hit bugs.
- Rect2-based hitbox/hurtbox overlap is sufficient for MVP and easy to test in headless QA.
- Godot project warnings treated as errors require explicit numeric typing (`maxi`, typed ints) in combat math paths.

## 2026-02-11 Task 6
- JSON-first roster data is fast for MVP and easy to validate via headless scripts.
- Mirror selection handling is clearer when isolated in a dedicated `CharacterSelectState` object.
- Schema validator with explicit error codes (`ERR_SCHEMA_FIELD_MISSING`) simplifies QA assertions.

## 2026-02-11 Task 5
- Round flow is easier to verify when KO and timeout are modeled as explicit events (`last_event`).
- Tie timeout handling should reset round state without score changes to prevent accidental winner assignment.
- A lightweight HUD model synced from snapshot decouples display data from round-rule logic.

## 2026-02-11 Task 7
- Flow control is easiest to validate with a linear phase trace (`SELECT->FIGHT->RESULT->REMATCH`).
- Rematch reset should explicitly clear both HP state and input transient buffers.
- Keeping flow as a standalone controller class makes headless end-to-end QA straightforward.

## 2026-02-11 Task 8
- A single headless test entry (`tests/run_all_tests.gd`) is useful as an always-on regression gate.
- Regression suites are more stable when they target explicit edge-case contracts (`EDGE_CASES:4/4`).
- Private-prototype guardrails can be enforced with a dedicated QA script checking forbidden release artifacts.

- 2026-02-11: For Godot headless `--script` QA entry points, autoload nodes are not guaranteed to be mounted as `/root/<name>`; validating `ProjectSettings` autoload entries and instantiating config explicitly keeps QA deterministic.
- 2026-02-11: Baseline InputMap setup is reliable when actions are declared in `project.godot` and key events are enforced from a startup config script.
