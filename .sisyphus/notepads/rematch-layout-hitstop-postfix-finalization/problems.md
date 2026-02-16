# Problems

Append-only deep-dive problem records and root causes.

## ObjectDB Leak Warning Root Cause (2026-02-16)
- Symptom: target headless QA scripts printed `ObjectDB instances leaked at exit` despite functional pass tokens.
- Root cause: script exit could happen before intro-time timers/nodes fully drained from the scene tree lifecycle.
- Fix approach: delay exit (`create_timer(INTRO_SETTLE_SECONDS)`) and drain additional frames after `queue_free()`.
- Validation: warning disappeared in both scripts (single-run + 5x loops) and stayed clear in final full regression.
