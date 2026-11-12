---
applyTo: "docs/**/*.md"
---

# Writing a document in `docs/`

1. Start the file with the YAML frontmatter block defined in `docs/README.md`.
   `title`, `type`, `status`, `updated`, and `sources` are mandatory.
2. Put the file in the folder that matches its question:
   - `context/` — what the project is
   - `decisions/` — why it is built this way
   - `knowledge/` — how it works
   - `lessons-learned/` — what breaks and how to react
   - `todo/` — what is still open
   - `published/` — what the stakeholders read
   - `analysis/` — the deep domain analysis
3. Cite evidence for every claim: `file:line`, a configuration key, or an exact log line.
4. Separate a confirmed fact from a hypothesis. Label the hypothesis.
5. End the file with a section that names what you could not verify.
6. Use standard Markdown links. Do not use `[[wikilinks]]` unless the Obsidian profile is enabled.
7. Write in {{DOC_LANGUAGE}}.
8. Run `bootstrap/check.sh --index` after you add, rename, or retitle a document.
