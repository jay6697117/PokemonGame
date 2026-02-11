# Issues

## 2026-02-11 Task 1
- Plan commands use `godot4`, but this environment exposes the CLI as `godot` (`/opt/homebrew/bin/godot`).
- Workaround used for execution: run equivalent commands with `godot --headless ...` and preserve expected QA tokens.

## 2026-02-11 Task 2
- Initial Task 2 QA attempt failed because `class_name` symbols were not resolved in standalone headless scripts.
- Resolved by switching to explicit `preload` references for combat scripts in all QA entry scripts.

## 2026-02-11 Task 3
- No blocking implementation issues after initial integration; QA scripts passed on first run.

## 2026-02-11 Task 4
- Initial resolver implementation failed because warnings were elevated to errors for inferred Variant numeric types.
- Resolved by explicit integer typing and `maxi` usage in damage/hitstun/HP calculations.

## 2026-02-11 Task 6
- No blocking issues encountered; roster/schema validation scripts passed on first run.

## 2026-02-11 Task 5
- No blocking issues encountered; both KO and timeout-tie QA scripts passed on first run.

## 2026-02-11 Task 7
- No blocking issues encountered; full flow and rematch-reset QA scripts passed on first run.

## 2026-02-11 Task 8
- No blocking issues encountered; test runner, regression suite, and private guard checks all passed.

- 2026-02-11: Environment does not expose a `godot4` binary name; only `godot`/`Godot` exists in PATH. Verification was executed with a shell-level `godot4()` shim mapped to `godot`.
