---
name: cooking
description: "Jerry's dev workflow: size, idea, recipe, saute, taste and review. Invoke /cooking DISH."
disable-model-invocation: true
metadata:
  author: Jerry Wu
---

# cooking

A **dish** is one piece of work that cooking takes from the ask to review. The **cookbook** is `.cookbook/` at the repo root; each dish keeps its state in its own folder there, `.cookbook/<slug>/`. Give workers absolute paths to it.

## 1. Resume or start

If the ask reports what happened to a `done` dish after its run, follow step 5 of `phases/review.md` on that ledger; if it reports an issue to fix, also **reopen** the dish. Otherwise, if a `.cookbook/*/ledger.md` matches this ask and is not `done`, **resume** it. Otherwise choose a short slug and create `.cookbook/<slug>/ledger.md` from the template below. Before you create it, run `git check-ignore -q .cookbook/x`; if that fails, append `.cookbook/` to the file that `git rev-parse --git-path info/exclude` prints.

To **resume**, rebuild the position from disk, not from the session. Read the ledger and the dish's files, then check `git status`, the dish's worktrees and its workers. A gate is passed only when the ledger has its date. A unit is `pass` only when its evidence file exists; run the check of every other started unit again. If several open ledgers match, ask which. Tell the user the phase and the next step in one line, then continue.

To **reopen**, add one unit to the ledger for each issue, with a check that fails now. Set `phase` to `saute` and record the event, then run saute, taste and review again. An issue that is a missed requirement takes the deviation route in `phases/saute.md`.

Write each state change to the ledger before the next action.

Resolve symlinks to find this skill's real directory. The optional private overlay directory is `../../overlays/` relative to it, outside the synced skill. Each `.md` file at the top of that directory is an **overlay** that starts with an applicability rule; apply an overlay only to the repos it matches. Missing overlays are normal. Give workers absolute overlay paths when needed.

Keep work-specific rules in that private overlay directory, never inside this skill.

## 2. Run the phases

A new dish starts with the `size` phase, which chooses the phases that follow. On entering a phase, read `phases/<phase>.md` and set `phase` in the ledger. When idea or recipe lacks a fact, follow `../research/SKILL.md` from this skill's real directory. Before you start any worker, read [`models.md`](models.md).

When you write a test command, in a check or a worker spec, write it **scoped**: at most the test files that reach the code the dish changes, directly or through its callers. Find them by a search for callers; go wider only when that search is unreliable, and record the reason in the ledger events. Have the command print progress as it runs.

When a phase ends, run its **hooks**: each `after <phase>` entry under `## Hooks` in an overlay that applies, in listed order. Read the file the entry names, follow it with the entry's note, and record the result in the ledger events. Then enter the next phase.

The user approves at two **gates**: the brief and the recipe. At each gate, record its date in the ledger and correct the size (`phases/size.md`, step 2). Between gates, run to completion. Also stop for a destructive or production action, and for a recipe deviation.

## Ledger template

```markdown
# <slug>
ask: <one line>
phase: <phase, or done>
size: <size>, <five answers>
size changes: <from> -> <to>, <reason>
overlays: <directory>, <each overlay that applies|none applies|missing>
gates: brief <open|date>, recipe <open|date>

| unit | check | parallel | status | fails | evidence |
|---|---|---|---|---|---|

events:
- <decision after a gate, deviation, return from taste, user correction, slow lookup, blocked access>
```
