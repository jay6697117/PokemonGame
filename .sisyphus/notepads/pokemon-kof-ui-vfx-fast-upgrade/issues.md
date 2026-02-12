# Issues

- 2026-02-12: `lsp_diagnostics` for `.gd` is currently unavailable in this environment because configured server `my-lsp` is not installed (`Command not found: my-lsp`).

## UI Architecture Limitations
- Date: 2026-02-12
- Issue: `scenes/ui/match_hud.tscn` is empty, and all UI logic resides in `scripts/flow/battle_screen.gd`. This couples game flow logic with presentation logic.
- Resolution: Extracted style constants to `scripts/theme/anime_arena_theme.gd`, but the structure remains coupled. Future refactoring should move UI construction to `match_hud.tscn` or a dedicated view class.

- 2026-02-12: `qa_phase1_visual_contract.gd` needed update to verify new visual layer binding.
- 2026-02-12: `edit` tool requires boolean for `replaceAll`, not string.
- 2026-02-12: `FileAccess` in Godot 4 used for verifying script content in QA.
- 2026-02-12: New `hit_feedback_pipeline.gd` failed parse when using `FighterVisual` type hints in this environment; resolved by switching to `Node2D` + `has_method` calls for compatibility.
- 2026-02-12: `lsp_diagnostics` remains unavailable for `.gd` due missing `my-lsp` binary, so script verification relied on headless QA execution.
