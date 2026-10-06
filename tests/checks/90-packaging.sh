#!/usr/bin/env bash
#
# AC18-AC20 — packaging agreement.
#
# The framework ships four framework-repo/maintainer-only root packaging files
# (`LICENSE`, `CONTRIBUTING.md`, `CHANGELOG.md`, `VERSION`) that must never be
# copied into an adopted repository. This check guards the agreement among them
# and with the surfaces that describe the adopter quickstart:
#
#   AC18 — manifest <-> changelog: `VERSION` holds exactly one valid SemVer and
#          equals the newest released version in `CHANGELOG.md`; `CONTRIBUTING.md`
#          names `VERSION` the single source of truth. Failures name both
#          surfaces (spec AC12).
#   AC19 — copy-set: `README.md`, `tests/README.md`, and `docs/customization.md`
#          each name all four packaging files as maintainer-only / not copied,
#          the quickstart ```` ```bash ```` block and the copy-set sentences list
#          none of them, and no `cp` command copies one. A surface that wrongly
#          claims one is copied fails and names that surface (spec AC13).
#   AC20 — Layout <-> disk: `README.md`'s `## Layout` block documents the four
#          packaging files and matches the on-disk root (spec AC14).
#
# These suite tokens extend the monotonic namespace: AC6-AC13 belong to the
# areas from child 0006-committed-tests-ci; AC14-AC17 describe harness behavior.
# The mapping to this item's acceptance criteria is recorded in tests/README.md.
#
# Reads only live surfaces (never work/**); sourced by tests/run.sh, so it must
# not call exit. Prints ok/FAIL lines labelled with its stable AC tokens.

echo "== AC18 packaging manifest <-> changelog agreement =="

# The one literal list of packaging files; this check is the guard for the set.
PACKAGING_FILES="LICENSE CONTRIBUTING.md CHANGELOG.md VERSION"

# Newest released changelog heading: `## [<semver>] - <YYYY-MM-DD>`.
RELEASED_HEADING_RE='^## \[[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$'
SEMVER_RE='^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'

# (i) VERSION exists and holds exactly one non-empty line that is a valid SemVer.
ver=""
if [ ! -f VERSION ]; then
  bad "AC18 VERSION is missing; VERSION and CHANGELOG.md cannot be compared"
elif [ ! -s VERSION ]; then
  bad "AC18 VERSION is empty; VERSION and CHANGELOG.md cannot be compared"
elif ver="$(awk 'NF { n++; v = $0 } END { if (n == 1) print v; else exit 1 }' VERSION)"; then
  if printf '%s' "$ver" | grep -qE "$SEMVER_RE"; then
    ok "AC18 VERSION holds exactly one valid SemVer ($ver)"
  else
    bad "AC18 VERSION is not a single valid SemVer (got '$ver')"
    ver=""
  fi
else
  bad "AC18 VERSION does not hold exactly one non-empty line"
  ver=""
fi

# (ii) CHANGELOG.md carries Unreleased and a dated released heading.
rel_ver=""
if [ ! -f CHANGELOG.md ]; then
  bad "AC18 CHANGELOG.md is missing; VERSION ('${ver:-missing}') cannot be compared"
else
  need CHANGELOG.md '## [Unreleased]' "AC18 CHANGELOG.md has an Unreleased section"
  rel_line="$(awk '/^## \[[0-9]/{ print; exit }' CHANGELOG.md)"
  if [ -n "$rel_line" ] && printf '%s\n' "$rel_line" | grep -qE "$RELEASED_HEADING_RE"; then
    ok "AC18 CHANGELOG.md newest released heading is versioned and ISO-dated"
  else
    bad "AC18 CHANGELOG.md has no '## [<semver>] - <YYYY-MM-DD>' released heading"
  fi
  rel_ver="$(printf '%s\n' "$rel_line" | sed -n 's/^## \[\([^]]*\)\].*/\1/p')"
fi

# (iii) The two surfaces must agree; the failure names both.
if [ "$rel_ver" != "" ] && [ "$ver" != "" ] && [ "$rel_ver" = "$ver" ]; then
  ok "AC18 VERSION and CHANGELOG.md agree on $ver"
else
  bad "AC18 VERSION (${ver:-missing/invalid}) and CHANGELOG.md newest released version (${rel_ver:-missing}) disagree"
fi

# (iv) CONTRIBUTING.md names VERSION the single source of truth. The phrase may
# wrap across lines, so match against the flattened file (flat is in lib.sh).
if [ -f CONTRIBUTING.md ] && \
   flat CONTRIBUTING.md | grep -qE 'VERSION.*single source of truth|single source of truth.*VERSION'; then
  ok "AC18 CONTRIBUTING.md names VERSION as the single source of truth"
else
  bad "AC18 CONTRIBUTING.md does not name VERSION as the single source of truth"
fi

echo "== AC19 packaging copy-set agreement =="

TESTS_README="tests/README.md"
SURFACES="$README $TESTS_README $CUST"

# A surface must state the packaging files are not part of the copied set.
NOTCOPIED_RE='not part of the copied set|outside the .{0,40}cop(y|ied) set|never copies'
# A surface must not positively claim a packaging file is copied.
CLAIMED_RE='(is|are|be|and|,) +((included )?in|part of) the cop(y|ied) set|cop(y|ies) (the )?`?(LICENSE|CONTRIBUTING\.md|CHANGELOG\.md|VERSION)'

# (i) Every copy-set surface names all four files and states they are not copied.
for surface in $SURFACES; do
  if [ ! -f "$surface" ]; then
    bad "AC19 $surface is missing; cannot verify its copy-set statement"
    continue
  fi
  missing=""
  for f in $PACKAGING_FILES; do
    grep -qF -- "$f" "$surface" || missing="$missing $f"
  done
  if [ -z "$missing" ]; then
    ok "AC19 $surface names all four packaging files"
  else
    bad "AC19 $surface does not name packaging file(s):$missing"
  fi
  if grep -qiE 'maintainer-only' "$surface" && grep -qiE "$NOTCOPIED_RE" "$surface"; then
    ok "AC19 $surface states the packaging files are maintainer-only and not copied"
  else
    bad "AC19 $surface lacks a maintainer-only / not-copied statement"
  fi
done

# (ii) The quickstart copy commands in README.md's first ```bash block never
# name a packaging file (spec AC10).
quickstart_block="$(awk '
  /^```bash[ \t]*$/ { infence = 1; next }
  infence && /^```/ { exit }
  infence { print }
' "$README")"
block_offenders=""
for f in $PACKAGING_FILES; do
  printf '%s\n' "$quickstart_block" | grep -qF -- "$f" && block_offenders="$block_offenders $f"
done
if [ -z "$quickstart_block" ]; then
  bad "AC19 $README has no readable bash quickstart block"
elif [ -z "$block_offenders" ]; then
  ok "AC19 $README quickstart copy commands never name a packaging file"
else
  bad "AC19 $README quickstart copy commands copy packaging file(s):$block_offenders"
fi

# (iii) The copied-set enumeration does not list a packaging file (spec AC13).
# tests/README.md enumerates the set in a parenthetical naming `.opencode/`;
# additionally, in either surface a copy marker and a packaging filename must
# not share a line. Both scopes stop at the sentence/clause, unlike a fixed
# character window that would bleed into the adjacent packaging statement.
for surface in "$TESTS_README" "$CUST"; do
  if [ ! -f "$surface" ]; then
    continue
  fi
  enum_offenders=""
  groups="$(flat "$surface" | grep -oE '\([^)]*\)')"
  while IFS= read -r group; do
    [ -z "$group" ] && continue
    printf '%s\n' "$group" | grep -qF -- '.opencode/' || continue
    for f in $PACKAGING_FILES; do
      printf '%s\n' "$group" | grep -qF -- "$f" && enum_offenders="$enum_offenders $f"
    done
  done <<EOF
$groups
EOF
  line_offenders=""
  while IFS= read -r line; do
    printf '%s\n' "$line" | grep -qiE 'cop(y|ied) set|quickstart copies' || continue
    for f in $PACKAGING_FILES; do
      printf '%s\n' "$line" | grep -qF -- "$f" && line_offenders="$line_offenders $f"
    done
  done < "$surface"
  if [ -z "$enum_offenders$line_offenders" ]; then
    ok "AC19 $surface copy-set sentence lists no packaging file"
  else
    bad "AC19 $surface copy-set sentence wrongly lists packaging file(s):$enum_offenders$line_offenders"
  fi
done

# (iv) No `cp` command anywhere in a copy-set surface copies a packaging file,
# and no surface positively claims one is copied.
cp_offenders=""
claim_offenders=""
for surface in $SURFACES; do
  [ -f "$surface" ] || continue
  if grep -qE '^[[:space:]]*cp[[:space:]]' "$surface"; then
    for f in $PACKAGING_FILES; do
      if grep -E '^[[:space:]]*cp[[:space:]]' "$surface" | grep -qF -- "$f"; then
        cp_offenders="$cp_offenders $surface($f)"
      fi
    done
  fi
  if grep -qiE "$CLAIMED_RE" "$surface"; then
    claim_offenders="$claim_offenders $surface"
  fi
done
if [ -z "$cp_offenders" ]; then
  ok "AC19 no cp command in a copy-set surface names a packaging file"
else
  bad "AC19 cp command(s) copy packaging file(s):$cp_offenders"
fi
if [ -z "$claim_offenders" ]; then
  ok "AC19 no copy-set surface claims a packaging file is copied"
else
  bad "AC19 surface(s) claim a packaging file is included in the copied set:$claim_offenders"
fi

echo "== AC20 README Layout <-> on-disk root agreement =="

# Resolve each documented entry against the root, honoring indentation: a
# non-indented line sets the current directory prefix, an indented line is
# relative to it. Output is `path<TAB>ignored|tracked`, where `ignored` marks a
# line whose inline comment says `git-ignored`.
layout_rows="$(awk '
  $0 ~ /^## Layout[ \t]*$/ { insec = 1; next }
  insec && /^## / { insec = 0 }
  !insec { next }
  /^```/ { if (infence) { exit } infence = 1; next }
  infence {
    raw = $0
    body = raw
    sub(/#.*/, "", body)
    gsub(/^[ \t]+|[ \t]+$/, "", body)
    if (body == "") next
    indented = (raw ~ /^[ \t]/)
    tok = body
    sub(/[ \t].*/, "", tok)
    if (!indented) dir = tok
    if (dir == "") next
    path = indented ? dir tok : tok
    ignored = (raw ~ /git-ignored/) ? "ignored" : "tracked"
    printf "%s\t%s\n", path, ignored
  }
' "$README")"

# (i) Forward: every documented entry exists at the root, except lines marked
# git-ignored and except work/ (the mutation copy deliberately has no work/).
layout_missing=""
while IFS="$(printf '\t')" read -r path ignored; do
  [ -z "$path" ] && continue
  [ "$path" = "work/" ] && continue
  [ "$ignored" = "ignored" ] && continue
  [ -e "$path" ] || layout_missing="$layout_missing $path"
done <<EOF
$layout_rows
EOF
if [ -z "$layout_missing" ]; then
  ok "AC20 README Layout documents only entries present on disk"
else
  bad "AC20 README Layout documents missing entry(ies):$layout_missing"
fi

# (ii) Reverse: every non-hidden root entry except the git-ignored scratch/ is
# documented.
layout_undoc=""
for entry in $(ls -A1); do
  case "$entry" in
    .*) continue ;;
  esac
  [ "$entry" = "scratch" ] && continue
  found=0
  while IFS="$(printf '\t')" read -r path ignored; do
    if [ "$path" = "$entry" ] || [ "$path" = "$entry/" ]; then
      found=1
      break
    fi
  done <<EOF
$layout_rows
EOF
  [ "$found" -eq 1 ] || layout_undoc="$layout_undoc $entry"
done
if [ -z "$layout_undoc" ]; then
  ok "AC20 every non-hidden root entry (except scratch/) is documented"
else
  bad "AC20 root entry(ies) undocumented in README Layout:$layout_undoc"
fi

# (iii) The four packaging files are documented in the Layout block.
for f in $PACKAGING_FILES; do
  if printf '%s\n' "$layout_rows" | awk -F'\t' -v t="$f" '$1 == t { found = 1 } END { exit !found }'; then
    ok "AC20 README Layout documents packaging file $f"
  else
    bad "AC20 README Layout does not document packaging file $f"
  fi
done
