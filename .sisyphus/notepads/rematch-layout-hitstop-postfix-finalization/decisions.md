# Decisions

Append-only decisions and rationale.

## 2026-02-16
- Keep Phase A and Phase B separated by commit history: functional lock-in stays in earlier commit(s), warning cleanup tracked in later QA-focused commit.
- Apply minimal-risk warning fix only inside target QA scripts (no runtime gameplay script expansion).
- Use `INTRO_SETTLE_SECONDS := 1.7` + extra frame drain before `quit(0)` as canonical teardown pattern for these two scripts.
- Completion gate remains command-driven only: target single-run checks + 5x loops + final `./start-demo.sh --verify-only`.
