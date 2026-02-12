# Issues

- 2026-02-12: `lsp_diagnostics` for `.gd` is currently unavailable in this environment because configured server `my-lsp` is not installed (`Command not found: my-lsp`).

## UI Architecture Limitations
- Date: 2026-02-12
- Issue: `scenes/ui/match_hud.tscn` is empty, and all UI logic resides in `scripts/flow/battle_screen.gd`. This couples game flow logic with presentation logic.
- Resolution: Extracted style constants to `scripts/theme/anime_arena_theme.gd`, but the structure remains coupled. Future refactoring should move UI construction to `match_hud.tscn` or a dedicated view class.
