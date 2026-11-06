# Cursor bindings

Copy these files to `.cursor/rules/` in the project.

`00-project.mdc` points at `AGENTS.md` and carries the short rule list.
`10-procedures.mdc` maps a trigger to a procedure.

Both use `alwaysApply: true`. Keep them short — Cursor inlines an always-applied
rule into every request.
