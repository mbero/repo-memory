#!/usr/bin/env bash
# Install the knowledge base into a project.
#
#   bootstrap/init.sh TARGET [options]
#
#   --tools LIST       comma list of: copilot claude-code cursor gemini | all | none
#   --profiles LIST    comma list of: kafka monolith-extraction obsidian jira | none
#   --set KEY=VALUE    set one project fact; repeat the option for more facts
#   --yes              ask no question; use the detected values and the defaults
#   --force            replace a file that already exists in the target
#   -h, --help         show this text
#
# The script detects the project facts, asks only for the facts it cannot
# detect, and copies one file at a time. It never deletes a file. It skips a
# file that already exists, unless you pass --force.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ALL_TOOLS="copilot claude-code cursor gemini"
ALL_PROFILES="kafka monolith-extraction obsidian jira"
TOKENS="PROJECT_NAME PROJECT_SLUG PROJECT_PURPOSE TECH_STACK LANGUAGE_VERSION \
PACKAGE_ROOT CODE_OWNER REPO_URL DEFAULT_BRANCH DOC_LANGUAGE BUILD_COMMAND \
RUN_COMMAND TEST_UNIT_COMMAND TEST_INTEGRATION_COMMAND LINT_COMMAND SOURCE_GLOBS \
TICKET_PREFIX"
# The script always asks for these facts. No file in a repository holds them.
ALWAYS_ASK="PROJECT_PURPOSE CODE_OWNER DOC_LANGUAGE"

usage() { sed -n '2,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }
die()   { echo "init.sh: $*" >&2; exit 2; }
say()   { echo "$*" >&2; }

# ------------------------------------------------------------------ arguments
TARGET=""
TOOLS=""
PROFILES=""
TOOLS_GIVEN=0
PROFILES_GIVEN=0
ASSUME_YES=0
FORCE=0

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
VALUES="$WORK/values"      # TOKEN<TAB>VALUE, one fact per line
GIVEN="$WORK/given"        # the facts that came from --set
COPIED="$WORK/copied"      # the files this run wrote
: > "$VALUES"; : > "$GIVEN"; : > "$COPIED"

while [ $# -gt 0 ]; do
  case "$1" in
    --tools)      [ $# -ge 2 ] || die "--tools needs a value"
                  TOOLS="$(echo "$2" | tr ',' ' ')"; TOOLS_GIVEN=1; shift 2 ;;
    --profiles)   [ $# -ge 2 ] || die "--profiles needs a value"
                  PROFILES="$(echo "$2" | tr ',' ' ')"; PROFILES_GIVEN=1; shift 2 ;;
    --set)        [ $# -ge 2 ] || die "--set needs KEY=VALUE"
                  case "$2" in *=*) ;; *) die "--set needs KEY=VALUE, got: $2" ;; esac
                  printf '%s\t%s\n' "${2%%=*}" "${2#*=}" >> "$GIVEN"; shift 2 ;;
    --yes|-y)     ASSUME_YES=1; shift ;;
    --force)      FORCE=1; shift ;;
    -h|--help)    usage; exit 0 ;;
    -*)           die "unknown option: $1" ;;
    *)            [ -z "$TARGET" ] || die "more than one target: $TARGET and $1"
                  TARGET="$1"; shift ;;
  esac
done

[ -n "$TARGET" ] || { usage >&2; exit 2; }

# A terminal on stdin means a person can answer. A pipe or a CI job cannot.
INTERACTIVE=0
if [ "$ASSUME_YES" -eq 0 ] && [ -t 0 ]; then INTERACTIVE=1; fi

[ "$TOOLS" = "all" ] && TOOLS="$ALL_TOOLS"
[ "$TOOLS" = "none" ] && TOOLS=""
[ "$PROFILES" = "none" ] && PROFILES=""

has_word() { case " $2 " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }


for t in $TOOLS;    do has_word "$t" "$ALL_TOOLS"    || die "unknown tool: $t (known: $ALL_TOOLS)"; done
for p in $PROFILES; do has_word "$p" "$ALL_PROFILES" || die "unknown profile: $p (known: $ALL_PROFILES)"; done
while IFS=$'\t' read -r k _; do
  has_word "$k" "$TOKENS" || die "unknown fact in --set: $k (known: $TOKENS)"
done < "$GIVEN"

# Create the target only after every argument is valid.
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
[ "$SRC" != "$TARGET" ] || die "the target is the template itself.
Clone the template to a different folder, then run:  bootstrap/init.sh /path/to/your/project"

# ------------------------------------------------------------------ fact store
get() { awk -F'\t' -v k="$1" '$1==k { sub(/^[^\t]*\t/, ""); v=$0 } END { print v }' "$VALUES"; }
put() { printf '%s\t%s\n' "$1" "$2" >> "$VALUES"; }           # the last value wins
put_if_empty() { [ -n "$(get "$1")" ] || [ -z "$2" ] || put "$1" "$2"; }

yml_field() { # yml_field TOKEN FIELD — read bootstrap/placeholders.yml
  awk -v t="$1:" -v f="  $2:" '
    $0==t { on=1; next }
    on && /^[A-Z_]+:/ { exit }
    on && index($0, f)==1 { sub(/^  [a-z]+:[[:space:]]*/, ""); gsub(/^"|"$/, ""); print; exit }
  ' "$SRC/bootstrap/placeholders.yml"
}

# ------------------------------------------------------------------ 1. detect
say "Knowledge base install"
say "  from: $SRC"
say "  into: $TARGET"
say ""

detect() {
  local name url branch ver globs d pm
  name="$(basename "$TARGET")"
  put_if_empty PROJECT_NAME "$name"
  put_if_empty PROJECT_SLUG "$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]\{1,\}/-/g' -e 's/^-//' -e 's/-$//')"

  if git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
    url="$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)"
    put_if_empty REPO_URL "$url"
    branch="$(git -C "$TARGET" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)"
    [ -n "$branch" ] || branch="$(git -C "$TARGET" symbolic-ref --short HEAD 2>/dev/null || true)"
    put_if_empty DEFAULT_BRANCH "$branch"
  fi

  if [ -f "$TARGET/pom.xml" ]; then
    local mvn="mvn"; [ -x "$TARGET/mvnw" ] && mvn="./mvnw"
    put_if_empty TECH_STACK "Java, Maven"
    ver="$(sed -n 's/.*<java.version>\([^<]*\)<.*/\1/p' "$TARGET/pom.xml" | head -1)"
    [ -n "$ver" ] && put_if_empty LANGUAGE_VERSION "Java $ver"
    put_if_empty BUILD_COMMAND "$mvn clean install"
    grep -q 'spring-boot' "$TARGET/pom.xml" && put_if_empty RUN_COMMAND "$mvn spring-boot:run"
    put_if_empty TEST_UNIT_COMMAND "$mvn test"
    put_if_empty TEST_INTEGRATION_COMMAND "$mvn verify"
  elif [ -f "$TARGET/build.gradle" ] || [ -f "$TARGET/build.gradle.kts" ]; then
    local gradle="gradle"; [ -x "$TARGET/gradlew" ] && gradle="./gradlew"
    put_if_empty TECH_STACK "JVM, Gradle"
    put_if_empty BUILD_COMMAND "$gradle build"
    put_if_empty TEST_UNIT_COMMAND "$gradle test"
  elif [ -f "$TARGET/package.json" ]; then
    pm="npm"
    [ -f "$TARGET/pnpm-lock.yaml" ] && pm="pnpm"
    [ -f "$TARGET/yarn.lock" ] && pm="yarn"
    put_if_empty TECH_STACK "Node.js"
    grep -q '"build"[[:space:]]*:' "$TARGET/package.json" && put_if_empty BUILD_COMMAND "$pm run build"
    grep -q '"start"[[:space:]]*:' "$TARGET/package.json" && put_if_empty RUN_COMMAND "$pm start"
    grep -q '"test"[[:space:]]*:'  "$TARGET/package.json" && put_if_empty TEST_UNIT_COMMAND "$pm test"
    grep -q '"lint"[[:space:]]*:'  "$TARGET/package.json" && put_if_empty LINT_COMMAND "$pm run lint"
  elif [ -f "$TARGET/go.mod" ]; then
    put_if_empty TECH_STACK "Go"
    ver="$(sed -n 's/^go \([0-9.]*\).*/\1/p' "$TARGET/go.mod" | head -1)"
    [ -n "$ver" ] && put_if_empty LANGUAGE_VERSION "Go $ver"
    put_if_empty PACKAGE_ROOT "$(sed -n 's/^module \(.*\)/\1/p' "$TARGET/go.mod" | head -1)"
    put_if_empty BUILD_COMMAND "go build ./..."
    put_if_empty TEST_UNIT_COMMAND "go test ./..."
    put_if_empty LINT_COMMAND "gofmt -l ."
  elif [ -f "$TARGET/Cargo.toml" ]; then
    put_if_empty TECH_STACK "Rust"
    put_if_empty BUILD_COMMAND "cargo build"
    put_if_empty RUN_COMMAND "cargo run"
    put_if_empty TEST_UNIT_COMMAND "cargo test"
    put_if_empty LINT_COMMAND "cargo fmt --check"
  elif [ -f "$TARGET/pyproject.toml" ]; then
    put_if_empty TECH_STACK "Python"
    put_if_empty TEST_UNIT_COMMAND "pytest"
  fi

  if [ -f "$TARGET/Makefile" ]; then
    grep -q '^build:' "$TARGET/Makefile" && put_if_empty BUILD_COMMAND "make build"
    grep -q '^run:'   "$TARGET/Makefile" && put_if_empty RUN_COMMAND "make run"
    grep -q '^test:'  "$TARGET/Makefile" && put_if_empty TEST_UNIT_COMMAND "make test"
    grep -q '^lint:'  "$TARGET/Makefile" && put_if_empty LINT_COMMAND "make lint"
  fi

  globs=""
  for d in src lib app cmd internal pkg; do
    [ -d "$TARGET/$d" ] && globs="${globs:+$globs,}$d/**"
  done
  put_if_empty SOURCE_GLOBS "$globs"
  return 0
}

# --set wins over detection. Detection wins over the default.
while IFS=$'\t' read -r k v; do put "$k" "$v"; done < "$GIVEN"
detect

# ------------------------------------------------------------------ 2. tools and profiles
ask_line() { # ask_line PROMPT DEFAULT — the prompt goes to stderr, the answer to stdout
  local answer=""
  if [ -n "$2" ]; then printf '%s [%s]: ' "$1" "$2" >&2; else printf '%s: ' "$1" >&2; fi
  IFS= read -r answer || answer=""
  [ -n "$answer" ] || answer="$2"
  printf '%s' "$answer"
}

if [ "$TOOLS_GIVEN" -eq 0 ]; then
  # A tool that the project already uses leaves a file. Keep that tool.
  [ -e "$TARGET/.github/copilot-instructions.md" ] && TOOLS="$TOOLS copilot"
  { [ -e "$TARGET/CLAUDE.md" ] || [ -d "$TARGET/.claude" ]; } && TOOLS="$TOOLS claude-code"
  [ -d "$TARGET/.cursor" ] && TOOLS="$TOOLS cursor"
  [ -e "$TARGET/GEMINI.md" ] && TOOLS="$TOOLS gemini"
  TOOLS="$(echo $TOOLS)"
  if [ "$INTERACTIVE" -eq 1 ]; then
    say "AGENTS.md serves every agent. A tool from this list gets extra files:"
    say "  $ALL_TOOLS"
    TOOLS="$(ask_line "Tools (comma list, 'all', or 'none')" "${TOOLS:-none}" | tr ',' ' ')"
    [ "$TOOLS" = "all" ] && TOOLS="$ALL_TOOLS"
    [ "$TOOLS" = "none" ] && TOOLS=""
    for t in $TOOLS; do has_word "$t" "$ALL_TOOLS" || die "unknown tool: $t"; done
  fi
fi

if [ "$PROFILES_GIVEN" -eq 0 ] && [ "$INTERACTIVE" -eq 1 ]; then
  say "Optional profiles: $ALL_PROFILES"
  PROFILES="$(ask_line "Profiles (comma list or 'none')" "none" | tr ',' ' ')"
  [ "$PROFILES" = "none" ] && PROFILES=""
  for p in $PROFILES; do has_word "$p" "$ALL_PROFILES" || die "unknown profile: $p"; done
fi

# ------------------------------------------------------------------ 3. facts
given() { awk -F'\t' -v k="$1" '$1==k { f=1 } END { exit !f }' "$GIVEN"; }

for t in $TOKENS; do
  [ "$t" = "TICKET_PREFIX" ] && ! has_word jira "$PROFILES" && { put_if_empty "$t" "n/a"; continue; }
  given "$t" && continue
  current="$(get "$t")"
  default="$(yml_field "$t" default)"
  [ -n "$current" ] || current="$default"
  if [ "$INTERACTIVE" -eq 1 ] && { [ -z "$current" ] || has_word "$t" "$ALWAYS_ASK"; }; then
    prompt="$(yml_field "$t" prompt) (e.g. $(yml_field "$t" example))"
    current="$(ask_line "$prompt" "$current")"
  fi
  # TBD marks a fact that nobody supplied. bootstrap/check.sh warns about it.
  [ -n "$current" ] || current="TBD"
  put "$t" "$current"
done
put TODAY "$(date '+%Y-%m-%d')"

say ""
say "Project facts:"
for t in $TOKENS; do printf '  %-26s %s\n' "$t" "$(get "$t")" >&2; done
say "  tools                      ${TOOLS:-none}"
say "  profiles                   ${PROFILES:-none}"
say ""
if [ "$INTERACTIVE" -eq 1 ]; then
  go="$(ask_line "Install with these values? (y/n)" "y")"
  case "$go" in y|Y|yes) ;; *) say "Stopped. The script changed no file."; exit 1 ;; esac
fi

# ------------------------------------------------------------------ 4. copy
SKIPPED=0
copy_file() { # copy_file SOURCE-RELATIVE [TARGET-RELATIVE]
  local from="$SRC/$1" rel="${2:-$1}"
  local to="$TARGET/$rel"
  [ -f "$from" ] || return 0
  if [ -e "$to" ] && [ "$FORCE" -eq 0 ]; then
    say "  kept     $rel"
    SKIPPED=$((SKIPPED+1))
    return 0
  fi
  mkdir -p "$(dirname "$to")"
  cp "$from" "$to"
  echo "$rel" >> "$COPIED"
}

copy_tree() { # copy_tree SOURCE-DIR — every file below it, same relative path
  local f
  while IFS= read -r f; do copy_file "$f"; done \
    < <(cd "$SRC" && find "$1" -type f | sort)
}

say "Copying files."
copy_file AGENTS.md
copy_file .template-version
copy_file .editorconfig
copy_file bootstrap/check.sh
copy_file .agents/README.md
copy_tree .agents/procedures

while IFS= read -r f; do
  case "$f" in docs/analysis/*) has_word monolith-extraction "$PROFILES" || continue ;; esac
  copy_file "$f"
done < <(cd "$SRC" && find docs -type f | sort)

copy_file profiles/README.md
for p in $PROFILES; do copy_file "profiles/$p.md"; done

if has_word copilot "$TOOLS"; then
  copy_file .github/copilot-instructions.md
  copy_tree .github/instructions
  for f in "$SRC"/.agents/bindings/copilot/*.prompt.md; do
    copy_file ".agents/bindings/copilot/$(basename "$f")" ".github/prompts/$(basename "$f")"
  done
fi
if has_word claude-code "$TOOLS"; then
  copy_file CLAUDE.md
  for f in "$SRC"/.agents/bindings/claude-code/*.md; do
    [ "$(basename "$f")" = "README.md" ] && continue
    copy_file ".agents/bindings/claude-code/$(basename "$f")" ".claude/commands/$(basename "$f")"
  done
fi
if has_word cursor "$TOOLS"; then
  copy_file .cursor/rules/00-project.mdc
  copy_file .agents/bindings/cursor/10-procedures.mdc .cursor/rules/10-procedures.mdc
fi
has_word gemini "$TOOLS" && copy_file GEMINI.md

# The workflow is a GitHub Actions file. Install it only where GitHub runs it.
case "$(get REPO_URL)" in
  *github.com*) copy_file .github/workflows/knowledge-base.yml ;;
  *) [ -d "$TARGET/.github/workflows" ] && copy_file .github/workflows/knowledge-base.yml ;;
esac
chmod +x "$TARGET/bootstrap/check.sh" 2>/dev/null || true

# ------------------------------------------------------------------ 5. fill
# Fill only the files this run wrote. A file of the project stays as it was.
say "Filling placeholders."
SED_SCRIPT="$WORK/fill.sed"
: > "$SED_SCRIPT"
while IFS=$'\t' read -r token value; do
  esc="$(printf '%s' "$value" | sed -e 's/[\\&|]/\\&/g')"
  printf 's|{{%s}}|%s|g\n' "$token" "$esc" >> "$SED_SCRIPT"
done < <(for t in $TOKENS TODAY; do printf '%s\t%s\n' "$t" "$(get "$t")"; done)

while IFS= read -r rel; do
  case "$rel" in
    bootstrap/*) continue ;;
    *.md|*.yml|*.mdc) ;;
    *) continue ;;
  esac
  sed -f "$SED_SCRIPT" "$TARGET/$rel" > "$WORK/out" && cat "$WORK/out" > "$TARGET/$rel"
done < "$COPIED"

# ------------------------------------------------------------------ 6. profile links
if [ -n "$PROFILES" ]; then
  BLOCK="$WORK/profiles"
  : > "$BLOCK"
  for p in $PROFILES; do printf -- '- [`profiles/%s.md`](profiles/%s.md)\n' "$p" "$p" >> "$BLOCK"; done
  if grep -q '^AGENTS.md$' "$COPIED"; then
    awk -v block="$BLOCK" '
      /<!-- PROFILES:START -->/ { print; while ((getline line < block) > 0) print line; skip=1; next }
      /<!-- PROFILES:END -->/   { skip=0 }
      !skip { print }
    ' "$TARGET/AGENTS.md" > "$WORK/out" && cat "$WORK/out" > "$TARGET/AGENTS.md"
  else
    say "AGENTS.md existed before this run. Add these lines to its profile section:"
    cat "$BLOCK" >&2
  fi
fi

# ------------------------------------------------------------------ 7. index and check
"$TARGET/bootstrap/check.sh" --index >&2
say ""
"$TARGET/bootstrap/check.sh" >&2 || true

WROTE="$(wc -l < "$COPIED" | tr -d ' ')"
cat >&2 <<EOT

Done. The script wrote $WROTE file(s) and kept $SKIPPED existing file(s).

Next steps:

  1. Ask your agent to follow .agents/procedures/first-fill.md.
     It fills docs/context/ from the code and cites the evidence.
  2. Review AGENTS.md. Every agent reads it first.
  3. Set "status: current" in a document after you verify it.
  4. Run bootstrap/check.sh before you open a pull request.

EOT
