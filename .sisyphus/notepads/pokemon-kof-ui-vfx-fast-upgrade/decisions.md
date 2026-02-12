# Decisions

- 2026-02-12: Established baseline manifest file at `data/assets_manifest.json` with schema `assets[]` entries requiring `source_url`, `license`, `attribution_required`, and `asset_path`.
- 2026-02-12: Locked allowed license set to `CC0` and `CC-BY`; `CC-BY` entries must set `attribution_required=true`.
- 2026-02-12: Added rule-based forbidden official-asset detection using normalized term matching (`pokemon`, `nintendo`, `gamefreak`, `thepokemoncompany`, `pokemon.com`) against both `asset_path` and `source_url`.

## Anime Arena Theme Implementation
- Date: 2026-02-12
- Decision: Implemented `AnimeArenaTheme` as a static GDScript constant file (`scripts/theme/anime_arena_theme.gd`) rather than a Godot `.tres` Resource.
  - Reason: The existing UI (`battle_screen.gd`) is purely code-driven. Using a script-based theme makes it easier to integrate directly into the code logic without overhauling the entire UI system to use Control nodes with Theme overrides extensively.
  - Impact: Future styling changes are centralized in one file, but we lose visual editor preview for now.
- Decision: Explicitly `preload` the theme script in `battle_screen.gd`.
  - Reason: `class_name` registration requires editor re-scan or `project.godot` updates which are brittle in headless/CI environments. Preload is robust.

## Battle Scene Refactoring
- Date: 2026-02-12
- Decision: Implemented `BackgroundLayer`, `FighterLayer`, `VfxLayer`, `HudLayer`, `OverlayLayer` as direct children of `Battle` root in `battle.tscn`.
- Decision: Maintained `HudLayer` as the primary layout driver via `VBoxContainer`, using a transparent `Control` spacer to reserve screen space for the `FighterLayer` content.
  - Reason: `FighterLayer` sits behind the HUD buttons visually but needs to align with the layout gap. A spacer ensures the buttons stay at the bottom without complex manual positioning logic.
