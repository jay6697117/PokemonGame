# Decisions

## Anime Arena Theme Implementation
- Date: 2026-02-12
- Decision: Implemented `AnimeArenaTheme` as a static GDScript constant file (`scripts/theme/anime_arena_theme.gd`) rather than a Godot `.tres` Resource.
  - Reason: The existing UI (`battle_screen.gd`) is purely code-driven. Using a script-based theme makes it easier to integrate directly into the code logic without overhauling the entire UI system to use Control nodes with Theme overrides extensively.
  - Impact: Future styling changes are centralized in one file, but we lose visual editor preview for now.
- Decision: Explicitly `preload` the theme script in `battle_screen.gd`.
  - Reason: `class_name` registration requires editor re-scan or `project.godot` updates which are brittle in headless/CI environments. Preload is robust.
