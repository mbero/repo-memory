# Project Knowledge Base Template

A vendor-neutral knowledge base that lives next to your code. Clone it into a
project, fill the placeholders, and every AI coding agent reads the same rules
and the same project facts.

Works with **Claude Code, GitHub Copilot, Cursor, Gemini CLI, Codex, Zed, Aider,
Windsurf, opencode** and any other agent that reads `AGENTS.md`.

---

## Why

An AI agent without a knowledge base explores the codebase on every question.
That is slow, expensive, and the answer disappears when the session ends.

This template gives the project a memory:

- **One canonical rule file** — `AGENTS.md`. Every tool reads it.
- **One place per question type** — why, how, what breaks, what is open.
- **Evidence over recall** — every claim cites `file:line`, a config key, or a log line.
- **Session memory** — a handoff log that survives a context reset.

---

## Install

```bash
# 1. Clone the template next to your project
git clone <this-repo> /tmp/kb-template

# 2. Install it into your project
/tmp/kb-template/bootstrap/init.sh /path/to/your/project

# 3. Answer the prompts, then verify
cd /path/to/your/project
bootstrap/check.sh
```

`init.sh` copies the structure, asks for the project facts, fills every
`{{PLACEHOLDER}}`, and lets you enable optional profiles.

---

## What gets installed

| Path | What it is |
|---|---|
| `AGENTS.md` | Canonical rules. ~150 lines. Every agent reads this. |
| `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/` | Stubs. They point to `AGENTS.md`. No duplicated content. |
| `.agents/procedures/` | Tool-neutral procedures in plain Markdown. |
| `.agents/bindings/` | Optional per-tool wrappers (skills, prompt files). |
| `docs/context/` | Stable facts: overview, architecture, conventions, setup, toolchain, glossary. |
| `docs/decisions/` | Architecture Decision Records. |
| `docs/knowledge/` | Answered questions. "How does X work." |
| `docs/lessons-learned/` | Incidents and diagnostic playbooks. |
| `docs/todo/` | Actionable gap lists with checkboxes. |
| `docs/published/` | Stakeholder-ready pages for a wiki. |
| `docs/analysis/` | Optional deep analysis of one domain area. |
| `docs/sessions/history.md` | Session handoff log. |
| `profiles/` | Optional add-ons: Kafka, monolith extraction, Obsidian, Jira, and more. |
| `bootstrap/` | `init.sh`, `sync.sh`, `check.sh`. |

---

## Why `AGENTS.md` is the canonical file

`AGENTS.md` is the cross-tool standard. More than 30 agents read it, and the
Agentic AI Foundation at the Linux Foundation stewards the format.

Some tools still prefer their own path:

| Tool | Prefers | How this template handles it |
|---|---|---|
| Claude Code | `CLAUDE.md` | A stub with `@AGENTS.md` import |
| GitHub Copilot | `.github/copilot-instructions.md` | A stub plus the 5 rules Copilot must see inline |
| Cursor | `.cursor/rules/*.mdc` | A stub with `alwaysApply: true` |
| Gemini CLI | `GEMINI.md` | A stub |

The stubs are **real files, not symlinks**. Symlinks break on Windows and in
several tools.

---

## Keep it honest

`bootstrap/check.sh` fails when:

- an unfilled `{{PLACEHOLDER}}` remains,
- a document under `docs/` has no frontmatter,
- an absolute home-directory path appears (`/Users/<name>/…`, `/home/<name>/…`, or the Windows equivalent),
- a document marked `status: draft` is older than 90 days.

Wire it into CI. The template ships a GitHub Actions workflow that does this.

---

## Upgrading

`bootstrap/sync.sh` pulls a newer template version into a project that already
uses it. It never overwrites a file you filled in. It reports what changed and
leaves the merge to you. `CHANGELOG.md` lists what each version changed.

---

## License

MIT. See [`LICENSE`](LICENSE).
