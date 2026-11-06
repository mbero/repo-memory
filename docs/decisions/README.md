---
title: Architecture Decision Records
type: context
status: current
updated: 2026-11-06
sources: []
tags: [meta, decisions]
---

# Architecture Decision Records

An ADR records **one choice, the alternatives, and the reason**. It answers the
question a new person asks six months later: *why is it built this way?*

## Rules

1. **One decision per file.** Never bundle two choices.
2. **Numbered and immutable.** `NNNN-kebab-slug.md`, numbers never reused.
   Once a record is `accepted`, you do not edit it.
3. **To change a decision, write a new ADR** that supersedes the old one. Then
   set the old record to `status: superseded` and link forward to the new one.
   That single edit is the only edit an accepted ADR ever receives.
4. **Record the alternatives you rejected.** An ADR without rejected options is
   a note, not a decision.
5. **Record the consequences, including the bad ones.** A decision with no cost
   was not a decision.
6. **Write it when the choice is made**, not at the end of the project.

## What deserves an ADR

- A choice between two libraries, patterns, or protocols.
- A boundary: what this service owns and what it does not.
- A deliberate exception to a convention.
- A choice to accept technical debt, and the trigger to revisit it.

**Not an ADR:** a bug fix, a rename, a dependency version bump, a task list.

## Status values

| Status | Meaning |
|---|---|
| `proposed` | Written, not yet agreed |
| `accepted` | In force |
| `superseded` | Replaced. The body names the replacement. |
| `deprecated` | No longer applies, with no replacement |

## Index

| # | Title | Status | Date |
|---|---|---|---|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | accepted | 2026-11-06 |

> Add a row for every new ADR. `bootstrap/check.sh` reports a file missing from
> this table.

Start from [`_template.md`](_template.md).
