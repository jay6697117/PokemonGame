# Issues

Append-only list of blockers, warnings, and unresolved risks.

## Phase A Warnings (2026-02-12)
- `WARNING: ObjectDB instances leaked at exit` observed during:
  - Phase-1 hit-stop scale stability check
  - Phase-1 layout metrics scaling check
- These warnings do not block the release (verification passed), but should be investigated in a future cleanup phase.
