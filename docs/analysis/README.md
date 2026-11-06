---
title: Domain analysis
type: context
status: current
updated: 2026-11-06
sources: []
tags: [meta, analysis]
---

# Domain analysis

**Optional.** Use this folder only when the project runs a deep analysis of one
domain area — an extraction, a rewrite, a large refactor, or a due-diligence
review. Delete the folder when the project does none of that.

## Shape

One directory per area. Four files per area, always the same four:

```text
docs/analysis/<area>/
├── business-rules.md   what the area must do, free of implementation detail
├── data-model.md       what data it owns and what must move
├── dependencies.md     what it calls, and who calls it
└── migration-plan.md   how the change happens, in phases
```

Copy `_template/` when you start a new area.

## Rules

1. **Business rules stay implementation-agnostic.** No class name in
   `business-rules.md`. A reader must be able to reimplement from it.
2. **Every rule gets an identifier** (`BR-001`), so other documents can cite it.
3. **Cite the source for every rule:** `file:line`.
4. **Record open business questions.** An unanswered rule is a risk, not a gap
   in the document.
5. **The migration plan names a rollback for every phase.**

## Related profile

A monolith-to-service extraction has extra rules. Enable
[`profiles/monolith-extraction.md`](../../profiles/monolith-extraction.md).
