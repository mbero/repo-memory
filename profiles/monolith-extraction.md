# Profile — monolith extraction

**Read this when the project extracts a domain area out of a monolith into a
standalone service.**

## Goal of the analysis

For each area, produce the four documents in `docs/analysis/<area>/`:

| File | Question it answers |
|---|---|
| `business-rules.md` | What must the new service do? Implementation-free. |
| `data-model.md` | What data does it own, and what must move? |
| `dependencies.md` | What calls it, and what does it call? |
| `migration-plan.md` | How does the change happen, phase by phase? |

Copy `docs/analysis/_template/` to start an area.

## Rules

1. **Business rules carry no class name.** A reader must be able to reimplement
   on any stack from `business-rules.md` alone.
2. **Every rule gets an identifier** (`BR-001`) and a source (`file:line`), so
   the other three documents can cite it.
3. **Mark a rule `inferred`** when you read it out of the code rather than a
   specification. A business owner must confirm it.
4. **Find the second writer.** The hardest dependency is another component that
   writes the same table. List every one in `dependencies.md`.
5. **Every migration phase ships independently and rolls back independently.**
   A phase with no rollback is a risk, not a plan.
6. **Removal is a phase.** The old path does not disappear on its own. Give it
   a phase, an owner, and an exit criterion.
7. **Record a boundary choice as an ADR.** "This belongs to the new service and
   that stays behind" is a decision, not a note.

## Strangler Fig, when you use it

Route a slice of traffic to the new service, keep the old path alive, and widen
the slice as confidence grows.

| Phase | What exists | How you verify |
|---|---|---|
| 0 Preparation | Old path only, plus seams | The seam compiles and tests pass |
| 1 Parallel | Both paths, new one receives shadow traffic | Outputs match for N days |
| 2 Cutover | New path serves real traffic, old path on standby | Error rate and latency hold |
| 3 Cleanup | Old path deleted | No reference remains |

**Do not skip phase 1.** A comparison of real outputs is the only evidence that
the extraction preserved behaviour.
