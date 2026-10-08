#!/usr/bin/env bash
#
# AC22 — command signature agreement ("signature sweep").
#
# The framework's slash-command signatures are duplicated across several
# surfaces: the always-loaded contracts (AGENTS.md, template/AGENTS.md), the
# workflow authority (docs/workflow.md), the README, the workflow-lifecycle
# skill, and the command usage strings. This check asserts that every stated
# signature on every in-scope surface equals the canonical signature, so the
# drift cannot return silently (0004-adoption-template-split/
# 0005-surface-consistency-sweep AC8).
#
#   canonical registry    — the single source of truth (spec "Canonical
#                           signatures"; the two incomplete command usage
#                           strings are repaired to it).
#   designated positions  — only the signature positions are scanned, so a
#                           concrete invocation such as `/plan 0001-add-dark-mode`
#                           or `/build T2` is never mistaken for a signature.
#   normalization         — trim, strip backticks, collapse whitespace, decode
#                           the markdown `\|` and mermaid `&lt;`/`&gt;` encodings.
#   comparison            — per surface and command: a present but divergent
#                           signature fails naming the file and command, and a
#                           required command absent from a surface also fails,
#                           so the check cannot pass vacuously.
#
# The suite token AC22 extends the monotonic namespace (AC18-AC20 packaging,
# AC21 adoption split); its mapping to this item's acceptance criteria is in
# tests/README.md.
#
# Reads only live surfaces (never work/**); sourced by tests/run.sh, so it must
# not call exit. Bash 3.2 compatible: no associative arrays, no mapfile.

echo "== AC22 signature agreement =="

# --- canonical registry -----------------------------------------------------

canonical_signature() {
  case "$1" in
    /spec)    printf '%s' '/spec <feature or problem description | item-ref>' ;;
    /plan)    printf '%s' '/plan <item-ref>' ;;
    /build)   printf '%s' '/build [item-ref or task-id]' ;;
    /test)    printf '%s' '/test [item-ref]' ;;
    /review)  printf '%s' '/review [item-ref]' ;;
    /ship)    printf '%s' '/ship [item-ref]' ;;
    /visual)  printf '%s' '/visual [url or item-ref]' ;;
    /fix)     printf '%s' '/fix <bug description>' ;;
    /roadmap) printf '%s' '/roadmap <initiative>' ;;
    /status)  printf '%s' '/status [item-ref]' ;;
    /conflicts) printf '%s' '/conflicts [item-ref]' ;;
    /doctor|/bootstrap) printf '%s' "$1" ;;
  esac
}

# --- normalization ----------------------------------------------------------

# normalize_sig <raw>  ->  the canonical comparison form: trimmed, backticks
# stripped, internal whitespace collapsed, and markdown/mermaid encodings
# decoded. The registry's literal `|` is written `\|` in tables and the
# canonical `<`/`>` are HTML entities in mermaid, so both must be decoded.
normalize_sig() {
  printf '%s' "$1" | sed \
    -e 's/^[[:space:]]*//' \
    -e 's/[[:space:]]*$//' \
    -e 's/^`//' -e 's/`$//' \
    -e 's/[[:space:]]\{2,\}/ /g' \
    -e 's/\\|/|/g' \
    -e 's/&lt;/</g' -e 's/&gt;/>/g'
}

# --- extraction (designated positions only) ---------------------------------

# Position 1 — AGENTS lifecycle table: the first backticked `/…` token (the
# Command cell) on every markdown table row.
extract_agents_table() {
  awk '
    /^\|/ {
      if (match($0, /`\/[^`]*`/))
        print substr($0, RSTART + 1, RLENGTH - 2)
    }
  ' "$1"
}

# Position 2 — AGENTS supporting commands: every backticked `/…` token on the
# `Supporting commands:` line and its continuation, up to the next blank line.
extract_agents_supporting() {
  awk '
    /^Supporting commands:/ { on = 1 }
    on {
      if ($0 ~ /^[ \t]*$/) exit
      s = $0
      while (match(s, /`\/[^`]*`/)) {
        print substr(s, RSTART + 1, RLENGTH - 2)
        s = substr(s, RSTART + RLENGTH)
      }
    }
  ' "$1"
}

# Position 3 — docs/workflow.md phase headings: the first backticked `/…` token.
extract_wf_headings() {
  awk '
    /^### [0-9]+[.] / {
      if (match($0, /`\/[^`]*`/))
        print substr($0, RSTART + 1, RLENGTH - 2)
    }
  ' "$1"
}

# Position 4 — docs/workflow.md `/visual` routing bullet, scoped to the
# "Routing heuristics" section. The bare pattern `^- [*][*]` also matches the
# "Optional visual pass" phase bullet (which carries a bare `/visual`), so the
# section scope keeps extraction on the routing bullet the spec names.
extract_wf_visual() {
  awk '
    /^## Routing heuristics/ { on = 1; next }
    on && /^## / { on = 0 }
    on && /^- [*][*]/ && /`\/visual/ {
      if (match($0, /`\/[^`]*`/))
        print substr($0, RSTART + 1, RLENGTH - 2)
    }
  ' "$1"
}

# Position 5 — README.md Commands table: the first backticked `/…` token per row.
extract_readme_commands() {
  awk '
    $0 == "## Commands" { on = 1; next }
    on && /^## / { on = 0 }
    on && /^\|/ {
      if (match($0, /`\/[^`]*`/))
        print substr($0, RSTART + 1, RLENGTH - 2)
    }
  ' "$1"
}

# Position 6 — README.md lifecycle mermaid labels: the content of every
# `["/…"]` node label.
extract_readme_mermaid() {
  awk '
    {
      s = $0
      while (match(s, /\["\/[^"]*"\]/)) {
        print substr(s, RSTART + 2, RLENGTH - 4)
        s = substr(s, RSTART + RLENGTH)
      }
    }
  ' "$1"
}

# Position 7 — workflow-lifecycle skill routing block: the route target after
# each arrow, up to the next run of two-or-more spaces. This yields
# `/status [item-ref]` even on the `… → wait, or override explicitly; /status
# [item-ref]` line.
extract_skill_routes() {
  awk '
    $0 == "## Which command now?" { on = 1; next }
    on && /^```/ { if (infence) exit; infence = 1; next }
    on && infence && /→/ {
      p = index($0, "→")
      rest = substr($0, p)
      q = index(rest, "/")
      if (q == 0) next
      target = substr(rest, q)
      if (match(target, /[ \t][ \t]+/))
        target = substr(target, 1, RSTART - 1)
      gsub(/^[ \t]+|[ \t]+$/, "", target)
      if (target != "") print target
    }
  ' "$1"
}

# --- per-surface comparison -------------------------------------------------

# run_surface <file> <required-commands> <raw signature lines>
#
# Classify each extracted token: a bare command, or one whose argument begins
# with `<` or `[`, is a signature and is compared to the registry; anything
# else (e.g. `/ship fix`, `/build T2`) is a concrete invocation and is skipped.
# Every required command must have produced at least one signature occurrence.
run_surface() {
  local sfile="$1" required="$2" data="$3" raw sig cmd arg canon seen
  if [ ! -f "$sfile" ]; then
    bad "AC22 $sfile is missing; cannot verify its signatures"
    return
  fi
  seen=""
  while IFS= read -r raw; do
    [ -z "$raw" ] && continue
    sig="$(normalize_sig "$raw")"
    [ -z "$sig" ] && continue
    cmd="${sig%% *}"
    arg="${sig#* }"
    [ "$arg" = "$sig" ] && arg=""
    case "$arg" in
      ""|"<"*|"["*) : ;;
      *) continue ;;
    esac
    canon="$(canonical_signature "$cmd")"
    if [ -z "$canon" ]; then
      bad "AC22 $sfile states a signature for an unknown command '$cmd'"
      continue
    fi
    if [ "$sig" = "$canon" ]; then
      ok "AC22 $sfile states canonical $cmd"
    else
      bad "AC22 $sfile states a divergent signature for $cmd: found '$sig', expected '$canon'"
    fi
    seen="$seen $cmd"
  done <<EOF
$data
EOF

  for cmd in $required; do
    case " $seen " in
      *" $cmd "*) : ;;
      *) bad "AC22 $sfile does not state a signature for $cmd" ;;
    esac
  done
}

# --- required sets per surface ----------------------------------------------
# Root/template AGENTS.md: the six lifecycle commands plus the seven supporting
# commands. docs/workflow.md: the six phase commands plus `/visual`.
# README.md: the thirteen Commands-table commands (a superset of the mermaid
# labels). The skill: the ten routing targets.
AGENTS_REQUIRED="/spec /plan /build /test /review /ship /fix /status /roadmap /bootstrap /visual /doctor /conflicts"
WF_REQUIRED="/spec /plan /build /test /review /ship /visual"
README_REQUIRED="/spec /plan /build /test /visual /review /ship /fix /roadmap /status /doctor /bootstrap /conflicts"
MERMAID_REQUIRED="/spec /plan /build /test /review /ship /visual"
SKILL_REQUIRED="/roadmap /spec /plan /build /test /visual /review /ship /status /conflicts"

TEMPLATE_AGENTS="template/AGENTS.md"
SWEEP_SKILL="$SKILL_DIR/workflow-lifecycle/SKILL.md"

agents_data=""
[ -f "$AGENTS" ] && agents_data="$(extract_agents_table "$AGENTS"; extract_agents_supporting "$AGENTS")"
run_surface "$AGENTS" "$AGENTS_REQUIRED" "$agents_data"

template_data=""
[ -f "$TEMPLATE_AGENTS" ] && template_data="$(extract_agents_table "$TEMPLATE_AGENTS"; extract_agents_supporting "$TEMPLATE_AGENTS")"
run_surface "$TEMPLATE_AGENTS" "$AGENTS_REQUIRED" "$template_data"

wf_data=""
[ -f "$WF" ] && wf_data="$(extract_wf_headings "$WF"; extract_wf_visual "$WF")"
run_surface "$WF" "$WF_REQUIRED" "$wf_data"

# The README states signatures in two positions whose command sets overlap (the
# Commands table and the mermaid labels). Each position is checked against its
# own required set, so the table cannot silently drop a signature that a mermaid
# label happens to supply (design "Required sets per surface": the table carries
# all thirteen commands, the mermaid labels the seven lifecycle ones).
readme_table=""
[ -f "$README" ] && readme_table="$(extract_readme_commands "$README")"
run_surface "$README" "$README_REQUIRED" "$readme_table"

readme_mermaid=""
[ -f "$README" ] && readme_mermaid="$(extract_readme_mermaid "$README")"
run_surface "$README" "$MERMAID_REQUIRED" "$readme_mermaid"

skill_data=""
[ -f "$SWEEP_SKILL" ] && skill_data="$(extract_skill_routes "$SWEEP_SKILL")"
run_surface "$SWEEP_SKILL" "$SKILL_REQUIRED" "$skill_data"

# --- AC1 command usage strings ----------------------------------------------

# AC1 covers every command's own usage string, not only the two repaired here,
# so each command file's `description:` line must carry `Usage: <canonical>`.
# The two repaired commands (`/spec`, `/ship`) are included in the loop; the
# `/ship` fix-landing clause is asserted separately below.
ALL_COMMANDS='/spec /plan /build /test /review /ship /visual /fix /roadmap /status /doctor /bootstrap /conflicts'
for _cmd in $ALL_COMMANDS; do
  _cmd_file="$CMD_DIR/${_cmd#/}.md"
  _cmd_canon="$(canonical_signature "$_cmd")"
  if [ ! -f "$_cmd_file" ]; then
    bad "AC22 $_cmd_file is missing; cannot verify its usage string for $_cmd"
  elif grep -qF -- "Usage: $_cmd_canon" "$_cmd_file"; then
    ok "AC22 $_cmd_file usage string states canonical $_cmd"
  else
    bad "AC22 $_cmd_file usage string does not state 'Usage: $_cmd_canon'"
  fi
done

# `/ship` additionally documents its fix-landing mode on the usage line.
SHIP_CMD="$CMD_DIR/ship.md"
if [ ! -f "$SHIP_CMD" ]; then
  bad "AC22 $SHIP_CMD is missing; cannot verify its fix-landing usage"
elif grep -qF -- 'Usage: /ship [item-ref] | /ship fix [short description]' "$SHIP_CMD"; then
  ok "AC22 $SHIP_CMD usage string documents the /ship fix landing form"
else
  bad "AC22 $SHIP_CMD usage string does not document 'Usage: /ship [item-ref] | /ship fix [short description]'"
fi

# --- AC7 ask agent description ----------------------------------------------

# The `ask` agent must carry the `<Role> agent. <capability>. Read-only.`
# description and never the stale `Ultra-Basic Read-Only Agent.` text.
ASK_AGENT="$AGENT_DIR/ask.md"
ASK_DESCRIPTION='Q&A agent. Answers whatever the user has on their mind with plain, thorough explanations. Read-only.'

if [ ! -f "$ASK_AGENT" ]; then
  bad "AC22 $ASK_AGENT is missing; cannot verify its description"
elif grep -qF -- "$ASK_DESCRIPTION" "$ASK_AGENT"; then
  ok "AC22 $ASK_AGENT description follows the agent-description convention"
else
  bad "AC22 $ASK_AGENT description is not the canonical agent-description text"
fi

if grep -qF -- 'Ultra-Basic Read-Only Agent.' "$ASK_AGENT" 2>/dev/null; then
  bad "AC22 $ASK_AGENT still carries the stale 'Ultra-Basic Read-Only Agent.' description"
fi
