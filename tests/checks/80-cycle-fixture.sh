#!/usr/bin/env bash
#
# AC13 — roadmap cycle rule and committed fixture.
#
# The cycle diagnostic (`CYCLIC-DEP`) is prose-only in the framework; this check
# pins it to behavior. It reads the committed fixture
# tests/fixtures/cyclic-roadmap/roadmap.md, parses the Children table's
# `Depends on` column with pure awk (no optional runtime), proves the graph is
# genuinely cyclic, then asserts the documented rule contract: a child in a cycle
# is never `ready`, and a cycle is reported as a non-fatal integrity finding
# named `CYCLIC-DEP`.
#
# The residual — that a live LLM `/status` run actually emits the finding — is not
# executable in CI and is documented in tests/README.md and verify.md.
#
# The fixture lives under tests/, never under work/, and the suite is read-only,
# so repeated runs are idempotent. Reads only live surfaces (never work/**);
# sourced by tests/run.sh, so it must not call exit. Prints ok/FAIL lines labelled
# with its stable AC13 token.

echo "== AC13 roadmap cycle rule and committed fixture =="

# Resolved relative to the repo root the suite was pointed at (run.sh cds to it),
# so a mutated copy in tests/mutation.sh is observed. Never under work/.
CYCLE_FIXTURE="tests/fixtures/cyclic-roadmap/roadmap.md"

# (i) The committed fixture exists and is shaped like a roadmap artifact.
if [ -f "$CYCLE_FIXTURE" ]; then
  ok "AC13 committed cycle fixture exists at $CYCLE_FIXTURE"
  need "$CYCLE_FIXTURE" 'phase: roadmap' "AC13 cycle fixture declares phase: roadmap"
  need "$CYCLE_FIXTURE" '| Local id | Title | Scope | Depends on | Canonical reference |' \
    "AC13 cycle fixture has a Children table header"
else
  bad "AC13 committed cycle fixture missing at $CYCLE_FIXTURE"
fi

# (ii) Parse the Children `Depends on` graph and prove it is cyclic. Kahn's
# algorithm: repeatedly drop nodes whose in-degree reaches zero; any node left
# over is in a cycle. A `Depends on` cell is a local id `NNNN-slug` (or an em
# dash for none); any cell that is not a local id is a non-dependency and ignored.
cycle_out=""
if [ -f "$CYCLE_FIXTURE" ]; then
  cycle_out="$(awk '
    /^## Children[ \t]*$/ { insec = 1; next }
    insec && /^## / { insec = 0 }
    !insec { next }
    /^\|/ {
      n = split($0, a, "|")
      if (n < 6) next
      id = a[2]; dep = a[5]
      gsub(/^[ \t]+|[ \t]+$/, "", id)
      gsub(/^[ \t]+|[ \t]+$/, "", dep)
      if (id == "" || id == "Local id" || id ~ /^-+$/) next
      if (id !~ /^[0-9][0-9][0-9][0-9]-[a-z0-9-]+$/) next
      nodes[id] = 1
      m = split(dep, ds, ",")
      for (i = 1; i <= m; i++) {
        d = ds[i]
        gsub(/^[ \t]+|[ \t]+$/, "", d)
        if (d !~ /^[0-9][0-9][0-9][0-9]-[a-z0-9-]+$/) continue
        nodes[d] = 1
        edges[id] = edges[id] " " d
        indeg[d]++
      }
    }
    END {
      for (k in nodes) if (indeg[k] == 0) queue[++tail] = k
      removed = 0
      while (++head <= tail) {
        u = queue[head]
        removed++
        n = split(edges[u], succ, " ")
        for (i = 1; i <= n; i++) {
          v = succ[i]
          if (v == "") continue
          indeg[v]--
          if (indeg[v] == 0) queue[++tail] = v
        }
      }
      total = 0
      for (k in nodes) total++
      if (removed < total) {
        for (k in nodes) if (indeg[k] > 0) print "CYCLE " k
      } else {
        print "ACYCLIC"
      }
    }
  ' "$CYCLE_FIXTURE")"

  if printf '%s\n' "$cycle_out" | grep -q '^ACYCLIC$'; then
    bad "AC13 fixture dependency graph is acyclic; it no longer proves a cycle"
  elif printf '%s\n' "$cycle_out" | grep -q '^CYCLE '; then
    members="$(printf '%s\n' "$cycle_out" | awk '/^CYCLE /{print $2}' | sort | tr '\n' ' ')"
    ok "AC13 fixture dependency graph is genuinely cyclic (members: ${members% })"
  else
    bad "AC13 could not parse the fixture's Children dependency graph"
  fi
fi

# (iii) Rule text: a child in a cycle is never ready, in the authority and the
# deferring surfaces. `need`/`needE` come from tests/lib.sh.
need "$WF" 'A child in a cycle is never `ready`' \
  "AC13 $WF states a child in a cycle is never ready"
need "$AGENT_DIR/status.md" 'A child in a cycle is never `ready`' \
  "AC13 $AGENT_DIR/status.md states a child in a cycle is never ready"
need "$CMD_DIR/status.md" 'a child in a cycle is never `ready`' \
  "AC13 $CMD_DIR/status.md states a child in a cycle is never ready"

# (iv) Finding contract: a cycle is a non-fatal integrity finding named
# CYCLIC-DEP, reported rather than failing.
need "$WF" 'integrity findings rather than failing' \
  "AC13 $WF reports integrity findings without failing"
need "$WF" 'CYCLIC-DEP' "AC13 $WF names the CYCLIC-DEP finding"
need "$WF" 'cycle members are never reported ready' \
  "AC13 $WF states cycle members are never reported ready"
need "$AGENT_DIR/status.md" 'CYCLIC-DEP' \
  "AC13 $AGENT_DIR/status.md names the CYCLIC-DEP finding"
need "$AGENT_DIR/status.md" 'informational and never fatal' \
  "AC13 $AGENT_DIR/status.md states findings are never fatal"
# The phrase wraps across two lines in the agent prompt, so match it against the
# flattened file ('flat' is defined in tests/lib.sh).
if flat "$AGENT_DIR/status.md" | grep -qF -- 'members of a cycle are never reported'; then
  ok "AC13 $AGENT_DIR/status.md states cycle members are never reported ready"
else
  bad "AC13 $AGENT_DIR/status.md does not state cycle members are never reported ready"
fi
need "$CMD_DIR/status.md" 'CYCLIC-DEP' \
  "AC13 $CMD_DIR/status.md names the CYCLIC-DEP finding"
need "$CMD_DIR/status.md" 'Report them without failing' \
  "AC13 $CMD_DIR/status.md reports findings without failing"
