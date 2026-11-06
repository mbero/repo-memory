# `.agents/` — the portable capability layer

A procedure holds the **logic**. A binding holds only the **trigger**.

```text
.agents/
├── manifest.yml      what is installed, which profiles are on, template version
├── procedures/       plain Markdown. Any agent, or any person, can follow these.
└── bindings/         optional per-tool wrappers that invoke a procedure
    ├── claude-code/  slash commands and skills
    ├── copilot/      *.prompt.md files
    └── cursor/       rule files
```

## Why this split

Tool-specific features do not port. A Claude skill means nothing to Copilot. A
Copilot prompt file means nothing to Gemini.

So the behaviour lives in a Markdown procedure that every agent can read. A
binding is a three-line wrapper that says *"follow `../../procedures/x.md`"*.

**A project with no bindings still works.** The agent reads `AGENTS.md`, which
links the procedures. The binding only makes the trigger convenient.

## Rules

1. **Never put logic in a binding.** If you change behaviour, change the procedure.
2. **A procedure is written for a reader, not a parser.** Numbered steps, plain
   language, no tool-specific syntax.
3. **A procedure states its trigger** in its first section, so an agent knows
   when to apply it without being told.

## Installing the bindings

`bootstrap/init.sh` asks which tools you use and copies the matching bindings
into place:

| Tool | Binding source | Installed to |
|---|---|---|
| Claude Code | `bindings/claude-code/` | `.claude/commands/` |
| GitHub Copilot | `bindings/copilot/` | `.github/prompts/` |
| Cursor | `bindings/cursor/` | `.cursor/rules/` |

Skip a tool and nothing breaks. The procedures stay reachable from `AGENTS.md`.
