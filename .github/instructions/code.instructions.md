---
applyTo: "src/**,lib/**,app/**"
---

# Writing code in this repository

1. Read `docs/context/conventions.md` before the first edit.
2. Match the style of the surrounding file: naming, comment density, and layering.
3. Do not write a fully qualified class name in a method body. Import it.
4. Add a test for every new unit of observable behaviour.
5. Review error handling before you hand the change over.
6. Run `{{LINT_COMMAND}}` and `{{TEST_UNIT_COMMAND}}` before you report completion.
7. Never commit or push without an explicit request.

Full checklist: `.agents/procedures/pre-commit-review.md`.
