# Draft: Pokemon KOF UI/VFX Upgrade

## Requirements (confirmed)
- User feedback: current prototype UI and game feel are far from expected Pokemon-style battle experience.
- Priority pain points: visual quality (UI) and combat feel (effects/feedback).
- Current state: playable prototype with placeholder visuals and simple rectangular fighters.

## Technical Decisions
- Keep Godot 4 prototype architecture and improve presentation layer first.
- Preserve private-learning legal boundary: no official Pokemon image/audio assets packaged.

## Research Findings
- No visual asset files currently present (`png/jpg/webp/ogg/wav/mp3` not found).
- No `assets/` directory exists yet.
- Current flow scripts are present under `scripts/flow/` with runtime playable loop.

## Open Questions
- Desired visual direction is not finalized (anime-card UI, pixel retro, or clean modern arena).
- Scope depth for first visual upgrade pass is not finalized.

## Scope Boundaries
- INCLUDE: UI style uplift, HUD redesign, stage atmosphere, hit feedback, VFX, camera shake cues.
- EXCLUDE (unless user asks): netcode, ranked systems, story mode, public release pipeline.
