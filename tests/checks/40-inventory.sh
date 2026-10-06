#!/usr/bin/env bash
#
# AC9 — documented inventory counts vs disk.
#
# README.md's Layout block states how many agents, commands, and skills the
# framework ships, and the Agents, Commands, and Skills tables enumerate them.
# This check asserts both agreements: every documented count equals the on-disk
# count, every on-disk item appears in its README table, and every README table
# row resolves to an on-disk item. It fails on a stale count, an undocumented
# item, or a stale table row.
#
# Reads only live surfaces (never work/**); sourced by tests/run.sh, so it must
# not call exit. Prints ok/FAIL lines labelled with its stable AC9 token.

echo "== AC9 inventory agreement (README counts and tables vs disk) =="

# --- Layout counts -----------------------------------------------------------
layout_count() {
  # $1 = the Layout line's trailing unit phrase, e.g. "role prompts".
  # Prints the documented integer, or nothing when the line is absent.
  awk -v unit="$1" '
    $0 ~ ("# [0-9]+ " unit) {
      if (match($0, /# [0-9]+/)) { print substr($0, RSTART + 2, RLENGTH - 2); exit }
    }
  ' "$README"
}

check_count() {
  # $1 = label, $2 = unit phrase, $3 = actual on-disk count
  doc="$(layout_count "$2")"
  if [ -z "$doc" ]; then
    bad "AC9 README Layout does not state a count for '$2'"
  elif [ "$doc" = "$3" ]; then
    ok "AC9 README Layout count for '$2' equals disk ($doc)"
  else
    bad "AC9 README Layout count for '$2' is '$doc' but disk has $3"
  fi
}

check_count "agents"   "role prompts"    "$(agent_names | wc -l | tr -d ' ')"
check_count "commands" "slash commands"  "$(cmd_names   | wc -l | tr -d ' ')"
check_count "skills"   "knowledge skills" "$(skill_names | wc -l | tr -d ' ')"

# --- README table membership -------------------------------------------------
table_col1() {
  # $1 = exact section heading (e.g. "Agents"); prints the first cell of every
  # markdown table row in that section, one per line.
  awk -v heading="$1" '
    $0 == "## " heading { insec = 1; next }
    insec && /^## / { insec = 0 }
    !insec { next }
    /^\|/ {
      n = split($0, a, "|")
      if (n < 2) next
      print a[2]
    }
  ' "$README"
}

readme_agent_names() {
  table_col1 "Agents" | awk '
    { gsub(/`/, ""); gsub(/^[ \t]+|[ \t]+$/, "") }
    $0 != "" && $0 != "Agent" && $0 !~ /^-+$/ { print }
  '
}

readme_cmd_names() {
  table_col1 "Commands" | awk '
    { gsub(/`/, ""); t = $1; sub(/^\//, "", t); gsub(/^[ \t]+|[ \t]+$/, "", t) }
    t != "" && t != "Command" && t !~ /^-+$/ { print t }
  '
}

readme_skill_names() {
  table_col1 "Skills" | awk '
    { gsub(/`/, ""); gsub(/^[ \t]+|[ \t]+$/, "") }
    $0 != "" && $0 != "Skill" && $0 !~ /^-+$/ { print }
  '
}

check_membership() {
  # $1 = label, $2 = on-disk newline list, $3 = documented newline list
  for name in $2; do
    if printf '%s\n' "$3" | grep -qxF -- "$name"; then
      ok "AC9 $1 '$name' is on disk and documented"
    else
      bad "AC9 $1 '$name' is on disk but missing from the README table"
    fi
  done
  for name in $3; do
    if printf '%s\n' "$2" | grep -qxF -- "$name"; then
      :
    else
      bad "AC9 README $1 row '$name' resolves to no on-disk item"
    fi
  done
}

check_membership "agent"   "$(agent_names)"   "$(readme_agent_names)"
check_membership "command" "$(cmd_names)"     "$(readme_cmd_names)"
check_membership "skill"   "$(skill_names)"   "$(readme_skill_names)"
