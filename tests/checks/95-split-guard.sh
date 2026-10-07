#!/usr/bin/env bash
#
# AC21 — adoption split guard.
#
# The adoption split (child 0001-adopter-template-split, PR #13) keeps the three
# bootstrap-mutable files' adopter-pristine sources under `template/` and the
# framework repository's own bootstrapped copies at the root. The documented
# quickstart (README.md) copies the pristine sources to their destination names,
# and the `bootstrap` agent denies edits under `template/`. This check statically
# asserts that split so it cannot silently rot:
#
#   AC2 — quickstart source/destination: README.md's first ```bash block sources
#         `template/AGENTS.md`, `template/opencode.json`, and `template/.gitignore`
#         to `./AGENTS.md`, `./opencode.json`, and `./.gitignore`, never from a
#         framework root copy, and never by copying the whole `template/`
#         directory (spec AC2).
#   AC3 — pristine placeholder profile: `template/AGENTS.md`'s Project profile is
#         the unfilled placeholder (spec AC3).
#   AC4 — copy-set surfaces: README.md, docs/customization.md, tests/README.md,
#         and CONTRIBUTING.md name the pristine sources and never claim an
#         adopter receives a root copy (spec AC4).
#   AC5 — quickstart <-> contract: docs/customization.md's split contract names
#         the same `template/<file>` source as the quickstart (spec AC5).
#   AC6 — bootstrap deny guard: an edit under `template/` resolves to deny while
#         the adopter's own root files stay allowed (spec AC6).
#
# The suite token AC21 extends the monotonic namespace: AC6-AC13 are the areas
# from child 0006-committed-tests-ci, AC14-AC17 harness behavior, and AC18-AC20
# packaging. The mapping to this item's acceptance criteria is in tests/README.md.
#
# Reads only live surfaces (never work/**); sourced by tests/run.sh, so it must
# not call exit. Prints ok/FAIL lines labelled with its stable AC21 token.

echo "== AC21 adoption split guard =="

# The three bootstrap-mutable files whose adopter-pristine source lives under
# `template/`; this is the literal set the split guards.
SPLIT_FILES="AGENTS.md opencode.json .gitignore"

# --- shared parsers ---------------------------------------------------------

# quickstart_pairs <README>   ->  "source<TAB>destination" per copy pair.
#
# Extract README's first ```bash block, then recognize the documented copy
# commands. A copy command's first non-blank word is `cp`, optionally reached
# through a same-line `for <var> in <words>; do ... done` loop, in which case the
# loop variable is expanded per word. Operands are read after `cp`, skipping
# `-*` flags; the last operand is the destination and the rest are sources.
# Quotes are stripped and a leading `$FRAMEWORK/` or `${FRAMEWORK}/` is removed.
# This is a bounded recognizer for the documented quickstart, not a shell
# evaluator: multi-line `for` lists are out of scope.
quickstart_pairs() {
  awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    function strip_prefix(s) {
      sub(/^\$FRAMEWORK\//, "", s)
      sub(/^\$\{FRAMEWORK\}\//, "", s)
      return s
    }
    # Split a shell-ish command into tok[1..ntok], dropping double quotes.
    function tokenize(s,   i, c, q, out) {
      ntok = 0; out = ""; q = 0
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (q) {
          if (c == "\"") { q = 0 } else { out = out c }
        } else if (c == "\"") {
          q = 1
        } else if (c == " " || c == "\t") {
          if (out != "") { ntok++; tok[ntok] = out; out = "" }
        } else {
          out = out c
        }
      }
      if (out != "") { ntok++; tok[ntok] = out }
      return ntok
    }
    # Emit one "source<TAB>destination" pair per source operand of a cp command.
    function emit_pairs(cmd,   n, i, start, dst) {
      n = tokenize(cmd)
      if (n < 2 || tok[1] != "cp") return
      start = 2
      while (start <= n && tok[start] ~ /^-/) start++
      if (start >= n) return
      dst = strip_prefix(tok[n])
      for (i = start; i < n; i++) printf "%s\t%s\n", strip_prefix(tok[i]), dst
    }
    /^```bash[ \t]*$/ { if (!infence) { infence = 1; next } }
    infence && /^```/ { exit }
    !infence { next }
    {
      line = trim($0)
      if (line == "") next
      # Same-line `for <var> in <words>; do <cmd>; done` loop.
      if (line ~ /^for[ \t]/ && line ~ /;[ \t]*do[ \t]/) {
        rest = line
        sub(/^for[ \t]+/, "", rest)
        var = rest
        sub(/[ \t].*/, "", var)
        sub(/^[A-Za-z_][A-Za-z0-9_]*[ \t]+in[ \t]+/, "", rest)
        pos = index(rest, "; do")
        if (pos == 0) pos = index(rest, ";do")
        if (pos == 0) next
        words = substr(rest, 1, pos - 1)
        cmd = substr(rest, pos)
        sub(/^;[ \t]*do[ \t]*/, "", cmd)
        sub(/;?[ \t]*done[ \t]*$/, "", cmd)
        nw = split(words, warr, /[ \t]+/)
        for (i = 1; i <= nw; i++) {
          expanded = cmd
          gsub("[$][{]" var "[}]", warr[i], expanded)
          gsub("[$]" var, warr[i], expanded)
          emit_pairs(expanded)
        }
        next
      }
      w = line
      sub(/[ \t].*/, "", w)
      if (w != "cp") next
      emit_pairs(line)
    }
  ' "$1"
}

# contract_sources <CUST>   ->  "file<TAB>template/<file>" per contract row.
#
# Parse the "Adopter-pristine sources and framework copies" table in
# docs/customization.md: the first cell is the copied file and the first
# `template/...` token in the second cell is its adopter-pristine source.
contract_sources() {
  awk -F'|' '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    /^\|/ {
      first = trim($2); gsub(/`/, "", first)
      if (first == "AGENTS.md" || first == "opencode.json" || first == ".gitignore") {
        second = $3
        if (match(second, /`template\/[^`]*`/)) {
          src = substr(second, RSTART + 1, RLENGTH - 2)
          printf "%s\t%s\n", first, src
        }
      }
    }
  ' "$1"
}

# --- AC2 quickstart source/destination --------------------------------------

# The first ```bash block must be readable; an absent/unreadable block fails
# naming README.md rather than passing vacuously.
quickstart_block="$(awk '
  /^```bash[ \t]*$/ { infence = 1; next }
  infence && /^```/ { exit }
  infence { print }
' "$README")"

if [ -z "$quickstart_block" ]; then
  bad "AC21 $README has no readable bash quickstart block"
fi

quickstart_pairs_data="$(quickstart_pairs "$README")"

whole_dir_offender=0
while IFS="$(printf '\t')" read -r src dst; do
  [ -z "$src" ] && continue
  case "$src" in
    template|template/|template/.) whole_dir_offender=1 ;;
  esac
done <<EOF
$quickstart_pairs_data
EOF

for f in $SPLIT_FILES; do
  # The adopter-pristine source named by the quickstart must exist on disk.
  if [ ! -f "template/$f" ]; then
    bad "AC21 template/$f is missing; README.md cannot source it"
  fi

  found_dst=""
  root_offender=0
  while IFS="$(printf '\t')" read -r src dst; do
    [ -z "$src" ] && continue
    base="${src##*/}"
    if [ "$base" = "$f" ] && [ "${src#template/}" = "$src" ]; then
      root_offender=1
    fi
    if [ "$src" = "template/$f" ] && { [ "$dst" = "./$f" ] || [ "$dst" = "$f" ]; }; then
      found_dst="$dst"
    fi
  done <<EOF
$quickstart_pairs_data
EOF

  if [ -n "$found_dst" ]; then
    ok "AC21 README.md quickstart sources $f from template/$f"
  else
    bad "AC21 README.md quickstart does not source $f from template/$f"
  fi
  if [ "$root_offender" -eq 1 ]; then
    bad "AC21 README.md quickstart sources $f from a root copy"
  fi
done

if [ "$whole_dir_offender" -eq 1 ]; then
  bad "AC21 README.md quickstart copies the whole template/ directory, not the three named files"
else
  ok "AC21 README.md quickstart copies no whole template/ directory"
fi

# --- AC5 quickstart <-> contract agreement ----------------------------------

contract_data="$(contract_sources "$CUST")"

for f in $SPLIT_FILES; do
  qsrc="$(printf '%s\n' "$quickstart_pairs_data" | awk -F'\t' -v want="template/$f" '$1 == want { print $1; exit }')"
  csrc="$(printf '%s\n' "$contract_data" | awk -F'\t' -v want="$f" '$1 == want { print $2; exit }')"
  if [ -z "$csrc" ]; then
    bad "AC21 $CUST contract does not name a template/ source for $f"
  elif [ "$csrc" != "$qsrc" ]; then
    bad "AC21 $f contract source ($csrc) disagrees with README.md quickstart source (${qsrc:-none})"
  else
    ok "AC21 $CUST contract agrees with README.md quickstart for $f"
  fi
done

# --- AC3 pristine placeholder profile ---------------------------------------

# The adopter-pristine `template/AGENTS.md` must present the *unfilled* Project
# profile: every documented field carries a `_placeholder_`, never a
# maintainer-bootstrapped value. Only `template/AGENTS.md` is inspected, so the
# framework's own bootstrapped root `AGENTS.md` is never flagged for holding
# real values (spec AC3).
TEMPLATE_AGENTS="template/AGENTS.md"
PROFILE_FIELDS="Purpose
Primary language(s)
Package manager
Install
Test
Lint
Typecheck
Format
Build
Key directories"

if [ ! -f "$TEMPLATE_AGENTS" ]; then
  bad "AC21 $TEMPLATE_AGENTS is missing; cannot verify its placeholder Project profile"
else
  if grep -qE '^## Project profile[[:space:]]*$' "$TEMPLATE_AGENTS"; then
    ok "AC21 $TEMPLATE_AGENTS has a Project profile section"
  else
    bad "AC21 $TEMPLATE_AGENTS has no '## Project profile' section"
  fi

  fields_missing=""
  fields_concrete=""
  while IFS= read -r label; do
    [ -z "$label" ] && continue
    line="$(grep -F -- "- **$label**: " "$TEMPLATE_AGENTS" | head -n 1)"
    prefix="- **$label**: "
    if [ -z "$line" ]; then
      fields_missing="$fields_missing $label"
      continue
    fi
    value="${line#"$prefix"}"
    value="$(printf '%s' "$value" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    case "$value" in
      _*_) ;;
      *) fields_concrete="$fields_concrete $label" ;;
    esac
  done <<EOF
$PROFILE_FIELDS
EOF

  if [ -z "$fields_missing" ]; then
    ok "AC21 $TEMPLATE_AGENTS Project profile names all ten fields"
  else
    bad "AC21 $TEMPLATE_AGENTS Project profile is missing field(s):$fields_missing"
  fi

  if [ -z "$fields_concrete" ]; then
    ok "AC21 $TEMPLATE_AGENTS Project profile fields are unfilled placeholders"
  else
    bad "AC21 $TEMPLATE_AGENTS Project profile field(s) carry a concrete value, not a placeholder:$fields_concrete"
  fi
fi

# --- AC6 bootstrap deny guard -----------------------------------------------

# The `bootstrap` agent may fill an adopter's own root copies (`AGENTS.md`,
# `opencode.json`, `.gitignore`) but must never touch the framework's
# adopter-pristine sources under `template/`. This parses the agent's
# `permission.edit` map into an ordered rule list and resolves a path the way
# opencode does — last-match-wins, with POSIX `case` pattern matching where `*`
# spans `/` — and asserts the template/ denies survive the broader root-file
# allows while the adopter's own root files stay editable (spec AC6).
#
# edit_rules <agent-file>  ->  "pattern<TAB>action" in file order.
edit_rules() {
  awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    function unq(s)  { gsub(/"/, "", s); return s }
    /^---[ \t]*$/ { if (infm) { infm = 0; inperm = 0; cap = 0 } else { infm = 1 }; next }
    !infm { next }
    /^permission:[ \t]*$/ { inperm = 1; next }
    inperm && /^[^ ]/ { inperm = 0; cap = 0 }
    inperm && /^  edit:/ {
      v = $0; sub(/^  edit:/, "", v); v = trim(v)
      if (v != "") { scalar = v; cap = 0 } else { cap = 1 }
      next
    }
    inperm && cap {
      if ($0 ~ /^  [^ ]/) { cap = 0; next }
      if ($0 ~ /^    /) {
        line = $0
        i = index(line, ":")
        k = unq(trim(substr(line, 1, i - 1)))
        val = unq(trim(substr(line, i + 1)))
        if (k != "") printf "%s\t%s\n", k, val
      }
    }
  ' "$1"
}

# resolve_edit <path>  ->  the action of the last matching rule, or "unmatched".
# Reads the bootstrap rule list in file order and remembers the last pattern
# that matches the path via `case`; an unmatched path never reaches an allow.
resolve_edit() {
  path="$1"
  action=""
  while IFS="$(printf '\t')" read -r pattern rule_action; do
    [ -z "$pattern" ] && continue
    # shellcheck disable=SC2254
    case "$path" in
      $pattern) action="$rule_action" ;;
    esac
  done <<EOF
$(edit_rules "$BOOTSTRAP_AGENT")
EOF
  printf '%s\n' "${action:-unmatched}"
}

BOOTSTRAP_AGENT=".opencode/agent/bootstrap.md"

if [ ! -f "$BOOTSTRAP_AGENT" ]; then
  bad "AC21 $BOOTSTRAP_AGENT is missing; cannot verify its template/ edit guard"
elif [ -z "$(edit_rules "$BOOTSTRAP_AGENT")" ]; then
  bad "AC21 bootstrap declares no permission.edit rules to guard template/"
else
  for guarded in \
    template/AGENTS.md template/opencode.json template/.gitignore \
    template/sub/AGENTS.md /repo/template/AGENTS.md
  do
    action="$(resolve_edit "$guarded")"
    if [ "$action" = "deny" ]; then
      ok "AC21 bootstrap denies an edit to $guarded"
    else
      bad "AC21 bootstrap does not deny an edit to $guarded (resolved $action)"
    fi
  done

  for editable in AGENTS.md opencode.json .gitignore /repo/AGENTS.md; do
    action="$(resolve_edit "$editable")"
    if [ "$action" = "allow" ]; then
      ok "AC21 bootstrap still allows an edit to $editable"
    else
      bad "AC21 bootstrap does not allow an edit to $editable (resolved $action)"
    fi
  done
fi

# --- AC4 copy-set surfaces --------------------------------------------------

# Every copy-set surface must name all three adopter-pristine sources, so a
# surface that stops describing the split cannot pass vacuously, and must not
# claim or imply that an adopter receives the framework's root copy. The
# wrong-claim scan is line-scoped and split at sentence boundaries: a negated
# statement that ends one sentence ("... not from the framework's root copies.")
# cannot bridge a filename in the next ("The framework's root `AGENTS.md` ...")
# to produce a false positive (spec AC4). COPY_VERB/ROOT_MARKER/NEG mirror the
# AC19 copy-marker style while exempting the surfaces' correct negated sentences
# ("never copied", "maintainer-bootstrapped ... never copied").
TESTS_README="tests/README.md"
CONTRIBUTING="CONTRIBUTING.md"
COPY_SET_SURFACES="$README $CUST $TESTS_README $CONTRIBUTING"
COPY_VERB_RE='cop(y|ies|ied)|receiv(e|es|ed)|give(s|n)?|get(s)?'
ROOT_MARKER_RE='root|maintainer'
NEG_RE='never|not|no |outside|excluding|neither'
FILE_RE='agents[.]md|opencode[.]json|[.]gitignore'

for surface in $COPY_SET_SURFACES; do
  if [ ! -f "$surface" ]; then
    bad "AC21 $surface is missing; cannot verify its copy-set statement"
    continue
  fi

  # Positive anchor: the surface must still name all three pristine sources.
  missing=""
  for f in $SPLIT_FILES; do
    grep -qF -- "template/$f" "$surface" || missing="$missing template/$f"
  done
  if [ -z "$missing" ]; then
    ok "AC21 $surface names all three adopter-pristine sources"
  else
    bad "AC21 $surface does not name pristine source(s):$missing"
  fi

  # Wrong-claim scan: a sentence that names one of the three files, contains a
  # copy verb and a root marker, and carries no negation is an offending claim.
  offenders="$(awk \
    -v file_re="$FILE_RE" -v verb_re="$COPY_VERB_RE" \
    -v root_re="$ROOT_MARKER_RE" -v neg_re="$NEG_RE" '
      function wrong_claim(s,   l) {
        l = tolower(s)
        return (l ~ file_re && l ~ verb_re && l ~ root_re && l !~ neg_re)
      }
      {
        n = split($0, clause, /[.][ ]/)
        for (i = 1; i <= n; i++)
          if (wrong_claim(clause[i])) print clause[i]
      }
    ' "$surface")"

  if [ -z "$offenders" ]; then
    ok "AC21 $surface has no claim that a root copy is an adopter source"
  else
    while IFS= read -r offender; do
      [ -z "$offender" ] && continue
      bad "AC21 $surface wrong-claim line: $offender"
    done <<EOF
$offenders
EOF
  fi
done
