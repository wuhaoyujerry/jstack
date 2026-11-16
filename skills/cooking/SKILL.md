---
name: cooking
description: "Jerry's dev workflow: size, idea, recipe, saute, taste and review. Invoke /cooking TASK."
disable-model-invocation: true
metadata:
  author: Jerry Wu
---

# cooking

Task state lives in `.jstack/<slug>/` at the repo root; Git ignores it globally. Give workers absolute paths to it.

## 1. Resume or start

If the ask reports what happened to a `done` task after its run, follow step 5 of `phases/review.md` on that ledger; if it reports an issue to fix, also **reopen** the task. Otherwise, if a `.jstack/*/ledger.md` matches this ask and is not `done`, **resume** it. Otherwise choose a short slug and create `.jstack/<slug>/ledger.md` from the template below.

To **resume**, rebuild the position from disk, not from the session. Read the ledger and the task's files, then check `git status`, the task's worktrees and its workers. A gate is passed only when the ledger has its date. A unit is `pass` only when its evidence file exists; run the check of every other started unit again. If several open ledgers match, ask which. Tell the user the phase and the next step in one line, then continue.

To **reopen**, add one unit to the ledger for each issue, with a check that fails now. Set `phase` to `saute` and record the event, then run saute, taste and review again. An issue that is a missed requirement takes the deviation route in `phases/saute.md`.

Write each state change to the ledger before the next action.

Resolve symlinks to find this skill's real directory. The optional private overlay directory is `../../overlays/` relative to it, outside the synced skill. If `work.md` exists there, read its applicability rule and apply it only to matching repos. Missing overlays are normal. Give workers absolute overlay paths when needed.

Keep work-specific rules and generated workflow logs in that private overlay directory, never inside this skill.

## 2. Run the phases

A new task starts with the `size` phase, which chooses the phases that follow. On entering a phase, read `phases/<phase>.md` and set `phase` in the ledger. When idea or recipe lacks a fact, follow `../research/SKILL.md` from this skill's real directory. Before you start any worker, read [`models.md`](models.md).

The user approves at two **gates**: the brief and the recipe. At each gate, record its date in the ledger and correct the size (`phases/size.md`, step 2). Between gates, run to completion. Also stop for a destructive or production action, and for a recipe deviation.

## Ledger template

```markdown
# <slug>
ask: <one line>
phase: <phase, or done>
size: <size>, <five answers>
size changes: <from> -> <to>, <reason>
gates: brief <open|date>, recipe <open|date>

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
- <decision after a gate, deviation, return from taste>
```
