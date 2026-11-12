---
title: Session history
type: context
status: current
updated: {{TODAY}}
sources: []
tags: [meta, sessions]
---

# Session history

Append-only log of agent sessions. It carries the context that a reset would
destroy: decisions, dead ends, and open questions.

**Read this file at the start of every session.**
**Append to it before every session ends.**

Procedure: [`.agents/procedures/session-handoff.md`](../../.agents/procedures/session-handoff.md).

## Rules

1. **Append. Never rewrite an earlier entry.**
2. **Record the dead ends.** The approach that failed saves the next session
   more time than the approach that worked.
3. **Name files, not feelings.** "Explored auth" is useless. "Read
   `AuthFilter.java:88`, confirmed the token is validated twice" is useful.
4. **An open question must name who or what can answer it.**
5. Keep the newest entry at the top.
6. **Keep ten entries here.** The handoff procedure moves an older entry,
   unchanged, to `archive/YYYY.md`. Every session reads this file, so its
   size is a cost that every session pays.

---

<!-- NEW ENTRIES GO DIRECTLY BELOW THIS LINE -->

## Session template — copy this block

### Session N — YYYY-MM-DD

**Goal:** <!-- what the session set out to do -->

**Done:**

- <!-- outcome, with the file it touched -->

**Key decisions:**

- <!-- decision → where it is recorded (ADR number, or "not recorded yet") -->

**Output files:**

- `<!-- path -->` — <!-- what it contains -->

**Key files and classes for later work:**

| Path | Why it matters |
|---|---|
| | |

**Dead ends — do not repeat:**

- <!-- what was tried, why it failed -->

**Open questions:**

| Question | Who or what can answer it |
|---|---|
| | |

**Not done:**

- <!-- what was in scope and got left out, and why -->
