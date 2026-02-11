# Decisions

- 2026-02-11: Added `GameConfig` as project autoload script containing task-1 baseline constants (`60 FPS`, `1000 HP`, `60s round`, `BO3`) and InputMap key bindings.
- 2026-02-11: Main flow baseline uses `scenes/main_menu.tscn` as `run/main_scene`, with `scripts/main_menu.gd` exposing `goto_character_select()` to enter `scenes/character_select.tscn`.
