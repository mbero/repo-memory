# GitHub Copilot bindings

Copy these files to `.github/prompts/` in the project. Each becomes a prompt
file you invoke with `/save-knowledge` in Copilot Chat.

Repository-wide rules live in `.github/copilot-instructions.md`, and
path-specific rules live in `.github/instructions/*.instructions.md`.

**Precedence note:** Copilot ranks `.github/instructions/**` and
`.github/copilot-instructions.md` **above** `AGENTS.md`. That is why the
copilot-instructions stub repeats the five non-negotiable rules inline.
