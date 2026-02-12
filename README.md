# Pokemon KOF Private Prototype

Godot 4 local 1v1 fighting-game prototype (private learning project).

## Godot command compatibility

This repo provides a local compatibility wrapper at `bin/godot4`.

- If your system only has `godot` (no `godot4`), run:

```bash
PATH="$(pwd)/bin:$PATH" godot4 --version
```

- The wrapper forwards all arguments to your installed `godot` binary.

## Quick verification

```bash
PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script "res://qa/qa_full_match_flow.gd"
PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script "res://qa/qa_regression_suite.gd"
PATH="$(pwd)/bin:$PATH" godot4 --headless --path . --script "res://tests/run_all_tests.gd"
```

## One-click demo script

```bash
chmod +x ./start-demo.sh

# Run full checklist, then launch game window
./start-demo.sh

# Run checklist only (no game window)
./start-demo.sh --verify-only
```
