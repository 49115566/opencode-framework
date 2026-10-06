#!/usr/bin/env bash
#
# AC10 — always-loaded instruction-set agreement.
#
# opencode.json's `instructions` array is the authority for which files load on
# every request. This check asserts that every path named there exists, that
# docs/customization.md's "Always-loaded instructions" table names exactly that
# set, and that README.md's Configuration section names the same set, so a
# divergent always-loaded path fails the run and names the surface.
#
# Reads only live surfaces (never work/**); sourced by tests/run.sh, so it must
# not call exit. Prints ok/FAIL lines labelled with its stable AC10 token.

echo "== AC10 always-loaded instruction-set agreement =="

# Extract the authority set from opencode.json without jq or python: scan the
# `instructions` array only, emitting each quoted string.
instructions_from_cfg() {
  awk '
    {
      line = $0
      if (!inarr) {
        if (line ~ /"instructions"[[:space:]]*:[[:space:]]*\[/) {
          inarr = 1
          sub(/.*"instructions"[[:space:]]*:[[:space:]]*\[/, "", line)
        } else { next }
      }
      while (match(line, /"[^"]*"/)) {
        print substr(line, RSTART + 1, RLENGTH - 2)
        line = substr(line, RSTART + RLENGTH)
      }
      if (line ~ /\]/) inarr = 0
    }
  ' "$CFG"
}

# Extract the first cell of every row in docs/customization.md's always-loaded
# instructions table, keeping only path-shaped cells (a `.md` suffix or a slash),
# which drops the "File" header, the separator, and the "Total" row.
cust_instruction_paths() {
  awk '
    $0 == "## Always-loaded instructions" { insec = 1; next }
    insec && /^## / { insec = 0 }
    !insec { next }
    /^\|/ {
      n = split($0, a, "|")
      if (n < 2) next
      cell = a[2]
      gsub(/`/, "", cell)
      gsub(/^[ \t]+|[ \t]+$/, "", cell)
      if (cell ~ /\.md$/ || cell ~ /\//) print cell
    }
  ' "$CUST"
}

# Extract the paths named on the README Configuration section's dedicated
# always-loaded marker line.
readme_instruction_paths() {
  grep -F 'Always-loaded instruction files:' "$README" \
    | grep -oE '`[^`]+`' | tr -d '`' | grep -E '\.md$'
}

cfg_list="$(instructions_from_cfg | sort -u)"
cust_list="$(cust_instruction_paths | sort -u)"
readme_list="$(readme_instruction_paths | sort -u)"

# (i) The authority declares a non-empty set.
if [ -n "$cfg_list" ]; then
  n="$(printf '%s\n' "$cfg_list" | wc -l | tr -d ' ')"
  ok "AC10 $CFG declares $n always-loaded instruction file(s)"
else
  bad "AC10 $CFG declares no always-loaded instruction set"
fi

# (ii) Every named path exists on disk.
for p in $cfg_list; do
  if [ -f "$p" ]; then
    ok "AC10 instruction path '$p' named in $CFG exists"
  else
    bad "AC10 instruction path '$p' named in $CFG does not exist"
  fi
done
for p in $cust_list; do
  if [ ! -f "$p" ]; then
    bad "AC10 instruction path '$p' named in $CUST does not exist"
  fi
done

# (iii) Each other surface names exactly the authority set. Membership is
# checked in both directions so the failure names the diverging path.
compare_sets() {
  # $1 = surface label, $2 = surface's newline-separated sorted path list
  surf="$1"; slist="$2"
  extra=0
  absent=0
  for p in $slist; do
    if ! printf '%s\n' "$cfg_list" | grep -qxF -- "$p"; then
      bad "AC10 $surf claims always-loaded path '$p' not in $CFG"
      extra=$((extra+1))
    fi
  done
  for p in $cfg_list; do
    if ! printf '%s\n' "$slist" | grep -qxF -- "$p"; then
      bad "AC10 $surf is missing always-loaded path '$p'"
      absent=$((absent+1))
    fi
  done
  if [ "$extra" -eq 0 ] && [ "$absent" -eq 0 ]; then
    ok "AC10 $surf names exactly the $CFG instruction set"
  fi
}

compare_sets "$CUST" "$cust_list"
compare_sets "$README Configuration" "$readme_list"
