# Learnings

- 2026-02-11: For Godot headless `--script` QA entry points, autoload nodes are not guaranteed to be mounted as `/root/<name>`; validating `ProjectSettings` autoload entries and instantiating config explicitly keeps QA deterministic.
- 2026-02-11: Baseline InputMap setup is reliable when actions are declared in `project.godot` and key events are enforced from a startup config script.
