#!/usr/bin/env bash
# Install the knowledge base into a project.
#
#   bootstrap/init.sh /path/to/your/project
#
# It copies the structure, asks for the project facts, fills every
# {{PLACEHOLDER}}, enables the profiles you choose, and installs tool bindings.
# It never overwrites an existing file without asking.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"

if [ -z "$TARGET" ]; then
  echo "usage: bootstrap/init.sh /path/to/your/project" >&2
  exit 2
fi
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

if [ "$SRC" = "$TARGET" ]; then
  echo "Target must differ from the template directory." >&2
  exit 2
fi

TODAY="$(date '+%Y-%m-%d')"

echo "Installing the knowledge base"
echo "  from: $SRC"
echo "  into: $TARGET"
echo

# ------------------------------------------------------------------ 1. copy
COPY_LIST="AGENTS.md CLAUDE.md GEMINI.md .github .cursor .agents docs profiles bootstrap .editorconfig .template-version"
SKIPPED=0
for item in $COPY_LIST; do
  if [ -e "$TARGET/$item" ]; then
    printf 'exists, keep it? %s [K/o] ' "$item"
    read -r ans </dev/tty || ans="K"
    case "$ans" in
      o|O) rm -rf "${TARGET:?}/$item" ;;
      *) echo "  kept $item"; SKIPPED=$((SKIPPED+1)); continue ;;
    esac
  fi
  cp -R "$SRC/$item" "$TARGET/$item"
done
echo "Copied the structure. $SKIPPED item(s) kept as they were."
echo

# ------------------------------------------------------------------ 2. answers
echo "Project facts. Press Enter to accept the default in brackets."
echo

TOKENS="PROJECT_NAME PROJECT_SLUG PROJECT_PURPOSE TECH_STACK LANGUAGE_VERSION \
PACKAGE_ROOT CODE_OWNER REPO_URL DEFAULT_BRANCH DOC_LANGUAGE BUILD_COMMAND \
RUN_COMMAND TEST_UNIT_COMMAND TEST_INTEGRATION_COMMAND LINT_COMMAND TICKET_PREFIX"

ask() { # ask TOKEN
  local token="$1" prompt example default answer
  prompt=$(awk -v t="$token:" '$0==t{f=1;next} f&&/^  prompt:/{sub(/^  prompt:[[:space:]]*/,"");gsub(/^"|"$/,"");print;exit}' "$SRC/bootstrap/placeholders.yml")
  example=$(awk -v t="$token:" '$0==t{f=1;next} f&&/^  example:/{sub(/^  example:[[:space:]]*/,"");gsub(/^"|"$/,"");print;exit}' "$SRC/bootstrap/placeholders.yml")
  default=$(awk -v t="$token:" '$0==t{f=1;next} f&&/^  default:/{sub(/^  default:[[:space:]]*/,"");gsub(/^"|"$/,"");print;exit}' "$SRC/bootstrap/placeholders.yml")
  while :; do
    if [ -n "$default" ]; then
      printf '%s [%s] (e.g. %s): ' "$prompt" "$default" "$example"
    else
      printf '%s (e.g. %s): ' "$prompt" "$example"
    fi
    read -r answer </dev/tty || answer=""
    [ -z "$answer" ] && answer="$default"
    [ -n "$answer" ] && { printf '%s' "$answer"; return 0; }
    echo "  required." >&2
  done
}

VALUES_FILE="$(mktemp)"
trap 'rm -f "$VALUES_FILE"' EXIT
for t in $TOKENS; do
  v="$(ask "$t")"
  printf '%s\t%s\n' "$t" "$v" >> "$VALUES_FILE"
done
printf 'TODAY\t%s\n' "$TODAY" >> "$VALUES_FILE"
echo

# ------------------------------------------------------------------ 3. substitute
echo "Filling placeholders."
while IFS=$'\t' read -r token value; do
  esc=$(printf '%s' "$value" | sed -e 's/[\/&|]/\\&/g')
  find "$TARGET" -type f \( -name '*.md' -o -name '*.yml' -o -name '*.mdc' \) \
    -not -path '*/.git/*' -not -path "$TARGET/bootstrap/*" -print0 \
    | xargs -0 sed -i.bak "s|{{$token}}|$esc|g"
done < "$VALUES_FILE"
find "$TARGET" -name '*.bak' -not -path '*/.git/*' -delete
echo

# ------------------------------------------------------------------ 4. profiles
echo "Optional profiles. Answer y to enable."
ENABLED=""
for p in kafka monolith-extraction spring-boot frontend obsidian jira; do
  printf '  enable %-20s [y/N] ' "$p"
  read -r a </dev/tty || a="n"
  case "$a" in y|Y) ENABLED="$ENABLED $p" ;; esac
done

if [ -n "$ENABLED" ]; then
  BLOCK=""
  for p in $ENABLED; do
    BLOCK="${BLOCK}- [\`profiles/${p}.md\`](profiles/${p}.md)\n"
  done
  awk -v block="$BLOCK" '
    /<!-- PROFILES:START -->/ { print; printf "%s", block; skip=1; next }
    /<!-- PROFILES:END -->/   { skip=0 }
    !skip { print }
  ' "$TARGET/AGENTS.md" > "$TARGET/AGENTS.md.new"
  mv "$TARGET/AGENTS.md.new" "$TARGET/AGENTS.md"
  yaml=""
  for p in $ENABLED; do yaml="${yaml}  - ${p}\n"; done
  awk -v y="$yaml" '/^profiles: \[\]$/ { print "profiles:"; printf "%s", y; next } { print }' \
    "$TARGET/.agents/manifest.yml" > "$TARGET/.agents/manifest.yml.new"
  mv "$TARGET/.agents/manifest.yml.new" "$TARGET/.agents/manifest.yml"
fi
# Remove the profiles the project did not enable.
for p in kafka monolith-extraction spring-boot frontend obsidian jira; do
  case " $ENABLED " in *" $p "*) ;; *) rm -f "$TARGET/profiles/$p.md" ;; esac
done
echo

# ------------------------------------------------------------------ 5. bindings
echo "Tool bindings. Answer y to install."
install_binding() { # install_binding NAME SRCDIR DSTDIR GLOB
  printf '  install %-16s [y/N] ' "$1"
  read -r a </dev/tty || a="n"
  case "$a" in
    y|Y)
      mkdir -p "$TARGET/$3"
      cp "$TARGET/$2"/$4 "$TARGET/$3"/ 2>/dev/null || true
      rm -f "$TARGET/$3/README.md"
      echo "    -> $3"
      BOUND="$BOUND $1"
      ;;
  esac
}
BOUND=""
install_binding "claude-code" ".agents/bindings/claude-code" ".claude/commands" "*.md"
install_binding "copilot"     ".agents/bindings/copilot"     ".github/prompts"  "*.prompt.md"
install_binding "cursor"      ".agents/bindings/cursor"      ".cursor/rules"    "*.mdc"
if [ -n "$BOUND" ]; then
  yaml=""
  for b in $BOUND; do yaml="${yaml}  - ${b}\n"; done
  awk -v y="$yaml" '/^bindings: \[\]$/ { print "bindings:"; printf "%s", y; next } { print }' \
    "$TARGET/.agents/manifest.yml" > "$TARGET/.agents/manifest.yml.new"
  mv "$TARGET/.agents/manifest.yml.new" "$TARGET/.agents/manifest.yml"
fi
echo

# ------------------------------------------------------------------ 6. verify
echo "Running the health check."
echo
"$TARGET/bootstrap/check.sh" || true

cat <<EOT

Done. Next steps:

  1. Fill docs/context/overview.md and docs/context/conventions.md.
     Those two carry most of the value.
  2. Set status: current in a document once you verified it.
  3. Run bootstrap/check.sh before you open a pull request.
  4. Review AGENTS.md. It is what every agent reads first.

EOT
