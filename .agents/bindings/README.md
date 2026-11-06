# Bindings

A binding is a **trigger**, not logic. It tells one tool when to follow a
procedure from `.agents/procedures/`.

Keep every binding under ten lines. If you need more, the procedure is missing
something — fix the procedure.

| Tool | Folder | Installed to | Mechanism |
|---|---|---|---|
| Claude Code | `claude-code/` | `.claude/commands/` | Slash commands |
| GitHub Copilot | `copilot/` | `.github/prompts/` | Prompt files |
| Cursor | `cursor/` | `.cursor/rules/` | Rule files |

`bootstrap/init.sh` copies the folders you choose. Skipping a tool breaks
nothing — `AGENTS.md` links every procedure directly.
