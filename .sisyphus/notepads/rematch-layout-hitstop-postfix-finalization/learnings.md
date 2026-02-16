# Learnings

Append-only notes for reusable technical findings.

## Phase A Verification (2026-02-12)
- Baseline verification passed with `./start-demo.sh --verify-only`.
- All required tokens (KO_STALE_BLOCKED, TIMEUP_STALE_BLOCKED, QA_HIT_STOP_SCALE_STABILITY_OK, QA_LAYOUT_METRICS_SCALING_OK) were present.
- `DEMO_CHECKLIST_PASS` confirmed.

## Warning Cleanup Verification (2026-02-16)
- Exhaustive local pattern sweep confirmed both target QA scripts now use intro settle wait plus multi-frame drain before `quit(0)`.
- `qa/qa_hit_stop_scale_stability.gd` and `qa/qa_layout_metrics_scaling.gd` both passed single-run checks without `ObjectDB instances leaked at exit`.
- 5x stability loops passed for both target scripts with no leak warning output.
- Full `./start-demo.sh --verify-only` passed with `DEMO_CHECKLIST_PASS`, no `TOKEN_MISSING:`, and no leak warning.
- Tooling note: shell `rg` and `sg` are not available in this environment; repository search was completed with `grep`/`glob` and AST tool fallback constraints.
