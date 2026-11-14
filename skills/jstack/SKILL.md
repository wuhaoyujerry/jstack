---
name: jstack
description: "Jerry's dev workflow: size, grill, research, spec, build, verify and retro. Invoke /jstack TASK or /jstack PHASE."
disable-model-invocation: true
metadata:
  author: Jerry Wu
---

# jstack

Task state lives in `.jstack/<slug>/` at the repo root; Git ignores it globally. Give workers absolute paths to it.

## 1. Resume or start

If a `.jstack/*/ledger.md` matches this ask and is not `done`, continue at its phase. Otherwise choose a short slug and create `.jstack/<slug>/ledger.md` from the template below. If the ask names a phase, run that phase on the open task.

Resolve symlinks to find this skill's real directory. The optional private overlay directory is `../../overlays/` relative to it, outside the synced skill. If `work.md` exists there, read its applicability rule and apply it only to matching repos. Missing overlays are normal. Give workers absolute overlay paths when needed.

Keep work-specific rules and generated workflow logs in that private overlay directory, never inside this skill. Task artifacts stay in the working repo's `.jstack/`.

## 2. Size

Answer five signals from the ask and a short repo look. Read files yourself; start no worker.

| Signal | Question |
|---|---|
| Done-check | Can I write the passing check now, with no open decision? |
| Units | Is the work one unit, or several that can run apart? |
| Reach | Does it change a public interface, or more than one module or repo? |
| Risk | Does it change a shared or production environment, or data that cannot be restored? |
| Shape | Is there more than one reasonable design, or a fact to research? |

- **trivial**: Done-check clear, one unit, no Reach, no Risk. Phases: build, verify.
- **large**: several units, wide Reach, Risk, or open Shape. Phases: all.
- **standard**: everything else. Phases: grill, spec, build, verify, retro.

Tell the user the size and the five answers in one line. The user may override.

## 3. Run the phases

On entering a phase, read `phases/<phase>.md` and set `phase` in the ledger. The `research` phase runs when grill or spec lacks a fact. Before you start any worker, read [`models.md`](models.md).

The user approves at two **gates**: the brief and the spec. Between gates, run to completion. Also stop for a destructive or production action, and for a spec deviation.

## 4. Correct the size

Each gate answers some signals again. During build the size only goes up; only the user lowers it.

## Ledger template

```markdown
# <slug>
ask: <one line>
phase: <phase, or done>
size: <size>, <five answers>
size changes: <from> -> <to>, <reason>
gates: brief <open|date>, spec <open|date>

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
- <decision after a gate, deviation, return from verify>
```
