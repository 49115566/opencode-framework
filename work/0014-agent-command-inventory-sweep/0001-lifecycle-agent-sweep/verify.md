---
feature: 0014-agent-command-inventory-sweep/0001-lifecycle-agent-sweep
phase: test
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
---

# Verification — Lifecycle-agent recursive sweep

## Summary

The sweep of the six lifecycle agent prompts (`product`, `architect`, `builder`,
`tester`, `reviewer`, `shipper`) is **correct and complete for AC1–AC9**. The
committed suite passes (503 passed, 0 failed, 0 skipped, exit `0`), the
documented inventory is unchanged (13 agents / 12 commands / 11 skills), and a
mechanical inspection harness of 58 checks passes 58/58.

No defect was found. No test was weakened, skipped, or deleted.

**Verification method.** This is a prose-only prompt/doc sweep. The spec's
"Non-goals" explicitly defers *"any new committed fixture, guard, or executable
checker"* to Roadmap 5, and the design's "Test strategy" fixes AC1–AC7 and AC9
as **inspection** and AC8 as the suite. In keeping with that boundary, no
committed guard was added; the acceptance criteria are verified by mechanically
extracting/byte-comparing the swept surfaces (an inline, uncommitted `python3`
inspection harness plus verbatim `grep`/`git diff` commands). The verbatim
harness is reproduced in the Appendix so the evidence is reproducible.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 503 passed, 0 failed, 0 skipped`; exit `0` (AC8) |
| `FRAMEWORK_TEST_AREAS='40-inventory,96-signature-sweep,30-permissions,50-instructions,60-default-agent' bash tests/run.sh` | PASS | `TOTAL: 151 passed, 0 failed, 0 skipped`; exit `0` — the areas that read the swept agent surfaces stay green |
| Inline inspection harness (Appendix) | PASS | `58 checks … TOTAL: 58 passed, 0 failed`; exit `0` (AC1–AC7, AC9) |
| `grep -n roadmap .opencode/agent/product.md` | PASS | prints nothing; exit `1` (AC1, AC6) |
| `grep -n roadmap .opencode/agent/shipper.md` | PASS | prints nothing; exit `1` (AC3, AC6) |
| `grep -n roadmap .opencode/agent/builder.md` | PASS | prints nothing; exit `1` (AC6) |
| `grep -n roadmap .opencode/agent/tester.md .opencode/agent/reviewer.md` | PASS | prints nothing; exit `1` (AC6) |
| `grep -c roadmap .opencode/agent/architect.md` | PASS | prints `1` (AC6 edge case) |
| `grep -n 'legacy `roadmap.md`' .opencode/agent/architect.md` | PASS | `102:   - an existing \`work/<item-ref>/manifest.md\` (or the legacy \`roadmap.md\`` — labelled `legacy` |
| `grep -rn 'roadmap child' .opencode/agent/{product,architect,builder,tester,reviewer,shipper}.md` | PASS | prints nothing; exit `1` (AC4) |
| `grep -rno roadmap .opencode/agent/{product,architect,builder,tester,reviewer,shipper}.md` | PASS | exactly one hit: `.opencode/agent/architect.md:102:roadmap` (AC6) |
| `git diff --stat` | PASS | only the six prompts (+ `tasks.md` check boxes) changed — disjoint from `0002`/`0004` (edge case) |
| `ls .opencode/agent/*.md \| wc -l`, `ls .opencode/command/*.md \| wc -l`, `ls .opencode/skill/*/SKILL.md \| wc -l` | PASS | `13`, `12`, `11` (AC8) |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 | harness `AC1 *` (7 checks) over `product.md`; verbatim `grep -n roadmap product.md` | PASS |
| AC2 | harness `AC2 step6 *` (6 checks): step 6 resolves `work/<NNNN-slug>/manifest.md`, cites the manifest template and "Dependencies and readiness", and the readiness/override tail is byte-identical to `HEAD` | PASS |
| AC3 | harness `AC3 *` (6 checks): "manifest dependency-graph fault", "manifest \`Children\`", zero `roadmap`; plan-publication/recall `manifest.md` wording preserved vs `HEAD` | PASS |
| AC4 | harness `AC4 *` (13 checks): the canonical sentence occurs exactly once in each of the six inputs and all six are the identical fixed string; no "roadmap child" | PASS |
| AC5 | harness `AC5 tester/reviewer *` (8 checks): each names `manifest.md`, nested children by canonical reference, a hybrid node, and cites "Work item references" | PASS |
| AC6 | harness `AC6 *` (2 checks) + `grep -rno roadmap` over the six: exactly one token, `architect.md:102`, labelled `legacy` | PASS |
| AC7 | harness `AC7 *` (12 checks): YAML frontmatter and the `<handoff>` block are byte-identical to `HEAD` for all six | PASS |
| AC8 | `bash tests/run.sh` → exit `0`; inventory counts `13/12/11` | PASS |
| AC9 | harness `AC9 *` (3 checks) + inspection: every changed recursive-model statement cites an authority section by name; no new `phase` value, finding code, or reference grammar | PASS |

### Edge cases

| Edge case | Test(s) | Result |
| --------- | ------- | ------ |
| `product.md` stale wording in two places (inputs + "Allocate the canonical reference") | `grep -n roadmap product.md` (0 hits); harness `AC1 zero roadmap tokens`, `AC4 product` | PASS |
| `architect.md` keeps exactly one sanctioned labelled legacy alias | `grep -c roadmap architect.md` → `1`; `grep -n 'legacy `roadmap.md`'` → labelled `legacy`; harness `AC6 *` | PASS |
| hybrid node readable by `tester`/`reviewer` | harness `AC5 tester/reviewer hybrid`, `nested+ref` | PASS |
| canonical boilerplate stable for `0003-command-sweep` | harness `AC4 byte-identical` — one fixed string replicated six times | PASS |
| `shipper.md` plan/recall `manifest.md` wording not regressed | harness `AC3 preserved *`; shipper diff hunks are only at inputs, precondition, reconcile step, renumber rule | PASS |
| file set disjoint from `0002`/`0004` | `git status --porcelain` and `git diff --stat` — only the six prompts + `tasks.md` | PASS |

## Gaps and residual risk

- **Inspection, not a committed guard.** AC1–AC7 and AC9 are verified by
  mechanical inspection, not by a committed `tests/checks/` area. This is by
  design: the spec's non-goal defers committed recursive-workflow guards to
  Roadmap 5, and the design's test strategy fixes inspection as the method. A
  future Roadmap 5 fixture (e.g. a signature-sweep analogue for the canonical
  item-ref sentence) would pin AC4/AC6 permanently; until then a later edit could
  drift silently, caught only by review.
- **AC9 has a subjective edge.** "No new `phase` value, finding code, or reference
  grammar" is checked by inspecting the added statements and confirming they cite
  the authority; it is a prose property with no exhaustive machine oracle. The
  substantive risk (a new grammar leaking in) is low here because the change is
  term replacement and one fixed sentence, all citing existing sections.
- **Suite does not read live `work/**`.** `bash tests/run.sh` is read-only and
  never reads a work item, so AC8 proves the swept live surfaces still satisfy the
  inventory/permission/signature agreements, not the content of this item's
  artifacts. That is exactly the intended division and is covered by the harness.
- **`0003`-consumed sentence is a coordination point.** AC4's canonical sentence
  is mirrored by `0003-command-sweep`; this item's copy is verified byte-identical
  across its own six files, but cross-child identity with `0003` is outside this
  item's surface and is `0003`'s own verification.

## Appendix — inline inspection harness

Run from the repository root. Uncommitted; reported here for reproducibility.

```sh
python3 - <<'PYEOF'
import re, subprocess, sys, os
from pathlib import Path
ROOT=Path(os.getcwd()); AGENTS=ROOT/".opencode"/"agent"
FILES=["product","architect","builder","tester","reviewer","shipper"]
CANON=("`NNNN-slug` for a standalone item, or a nested `NNNN-slug/MMMM-slug` at "
       "any depth; a canonical reference per `docs/artifact-conventions.md` \u2192 "
       '"Work item references", resolving to the directory `work/<item-ref>/`.')
res=[]
def check(t,ok,d): res.append((t,ok,d))
def read(n): return (AGENTS/f"{n}.md").read_text()
def norm(s): return re.sub(r"\s+"," ",s)
def head(n):
    p=subprocess.run(["git","show",f"HEAD:.opencode/agent/{n}.md"],cwd=ROOT,capture_output=True,text=True)
    assert p.returncode==0,p.stderr; return p.stdout
def fm(t):
    ls=t.splitlines(keepends=True)
    if not ls or ls[0].strip()!="---": return None
    o=[ls[0]]
    for ln in ls[1:]:
        o.append(ln)
        if ln.strip()=="---": return "".join(o)
    return None
def blk(t,tag):
    m=re.search(rf"<{tag}>.*?</{tag}>",t,re.S); return m.group(0) if m else None
for n in FILES:
    c=read(n).count(CANON); check(f"AC4 {n}",c==1,f"occurrences={c}")
check("AC4 byte-identical", len({read(n).count(CANON) for n in FILES})==1 and all(read(n).count(CANON)==1 for n in FILES), "six sentences identical")
for n in FILES: check(f"AC4 no-roadmap-child {n}", "roadmap child" not in read(n),"absent")
hits=[(n,i,l.strip()) for n in FILES for i,l in enumerate(read(n).splitlines(),1) if "roadmap" in l.lower()]
check("AC6 one-token",len(hits)==1,f"hits={hits}")
if hits:
    n,i,l=hits[0]; check("AC6 legacy-label",n=="architect" and "legacy" in l,f"{n}:{i} labelled legacy")
prod=read("product")
check("AC1 manifest path","work/<parent-ref>/manifest.md" in prod,"present")
check("AC1 target phase manifest",re.search(r"target phase\s+`manifest`",prod) is not None,"present")
check("AC1 /plan route","/plan <parent-ref>" in prod,"present")
check("AC1 Revising a decomposition","Revising a decomposition" in prod,"present")
for bad in ["parent roadmap","/roadmap revise","work/<parent-ref>/roadmap.md"]:
    check(f"AC1 absent '{bad}'",bad not in prod,"absent")
check("AC1 zero roadmap tokens","roadmap" not in prod.lower(),"zero")
a=prod.find("6. If the reference is a nested child"); b=prod.find("7. Allocate the canonical reference"); s6=prod[a:b]
check("AC2 step6 manifest","work/<NNNN-slug>/manifest.md" in s6,"present")
check("AC2 step6 no roadmap","roadmap" not in s6.lower(),"absent")
check("AC2 step6 cites template","`manifest.md` — the manifest of a" in s6 and "decomposing node" in s6,"present")
check("AC2 step6 readiness cite","Dependencies and readiness" in s6,"present")
check("AC2 step6 override","Proceed only on an explicit user override" in s6 and "blocking dependencies" in s6,"present")
def sl(t):
    x=t.find("run the readiness algorithm in"); y=t.find("Refusing must touch no existing file."); return t[x:y]
check("AC2 step6 tail identical",sl(prod)==sl(head("product")),"readiness+override tail == HEAD")
ship=read("shipper")
check("AC3 dep-graph",("manifest dependency-graph fault" in ship) or ("manifest's dependency graph" in ship),"present")
check("AC3 manifest Children","manifest `Children`" in ship,"present")
check("AC3 zero roadmap","roadmap" not in ship.lower(),"zero")
for needle in ["`work/<item-ref>/manifest.md`","manifest-only plan","`manifest.md`, its own phase artifacts when present"]:
    check(f"AC3 preserved '{needle}'", needle in norm(ship),"present (whitespace-normalized)")
for n in ["tester","reviewer"]:
    t=read(n)
    check(f"AC5 {n} manifest.md","manifest.md" in t,"present")
    check(f"AC5 {n} nested+ref","nested children" in t and "canonical reference" in t,"present")
    check(f"AC5 {n} hybrid","hybrid node" in t,"present")
    check(f"AC5 {n} cite Work item refs",'"Work item references"' in t,"present")
for n in FILES:
    cur,old=read(n),head(n)
    check(f"AC7 {n} frontmatter identical",fm(cur)==fm(old),"byte-identical to HEAD")
    check(f"AC7 {n} handoff identical",blk(cur,"handoff")==blk(old,"handoff"),"byte-identical to HEAD")
check("AC9 canon cites authority",'"Work item references"' in CANON,"present")
check("AC9 shipper cites authority",'"Dependencies and readiness"' in ship,"present")
check("AC9 no roadmap phase in product/shipper","roadmap" not in (prod+ship).lower(),"absent")
fails=sum(1 for _,ok,_ in res if not ok)
for t,ok,d in res: print(f"{'PASS' if ok else 'FAIL'} {t} — {d}")
print(f"\nTOTAL: {len(res)-fails} passed, {fails} failed")
sys.exit(1 if fails else 0)
PYEOF
```
