---
name: cooking
description: "Jerry's dev workflow: size, idea, recipe, saute, taste and review. Invoke /cooking DISH."
disable-model-invocation: true
metadata:
  author: Jerry Wu
---

# cooking

A **dish** is one piece of work that cooking takes from the ask to review. The **cookbook** is `.cookbook/` at the root of the **main checkout**: the first worktree that `git worktree list` prints. Every worktree of the repo shares that one cookbook. Each dish keeps its state in its **dish folder**: `.cookbook/dishes/<slug>/`, or `.cookbook/meals/<meal>/<slug>/` for a dish of a meal. In this skill's files, `.cookbook/` is that directory and `<dish>` is that folder. Give workers absolute paths to it.

A **meal** is one goal cooked as several dishes. Its **meal folder**, `.cookbook/meals/<meal>/`, holds the folders of its dishes and the meal file, `meal.md`, that lists them. When the ask names a meal, or a ledger names one on its `meal` line, read [`meal.md`](meal.md) before you resume or start a dish.

## 1. Resume or start

If the ask reports what happened to a `done` dish after its run, follow step 5 of `phases/review.md` on that ledger; if it reports an issue to fix, also **reopen** the dish. Otherwise, if a `.cookbook/{dishes,meals/*}/*/ledger.md` matches this ask and is not `done`, **resume** it. Otherwise choose a short slug that no dish folder has and create `.cookbook/dishes/<slug>/ledger.md` from the template below. Before you create it, run `git check-ignore -q .cookbook/x`; if that fails, append `.cookbook/` to the file that `git rev-parse --git-path info/exclude` prints.

To **resume**, rebuild the position from disk, not from the session. A dish whose ledger names a worktree continues only in a session there: anywhere else, tell the user the worktree and change nothing. Read the ledger and the dish's files, then check `git status`, the dish's worktrees and its workers. A gate is passed only when the ledger has its date. A unit is `pass` only when its evidence file exists; run the check of every other started unit again. If several open ledgers match, ask which. Tell the user the phase and the next step in one line, then continue.

To **reopen**, add one unit to the ledger for each issue, with a check that fails now. Set `phase` to `saute` and record the event, then run saute, taste and review again. An issue that is a missed requirement takes the deviation route in `phases/saute.md`.

Write each state change to the ledger before the next action.

Resolve symlinks to find this skill's real directory. The optional private overlay directory is `../../overlays/` relative to it, outside the synced skill. Each `.md` file at the top of that directory is an **overlay** that starts with an applicability rule; apply an overlay only to the repos it matches. Missing overlays are normal. Give workers absolute overlay paths when needed.

Keep work-specific rules in that private overlay directory, never inside this skill.

## 2. Run the phases

A new dish starts with the `size` phase, which chooses the phases that follow. On entering a phase, read `phases/<phase>.md` and set `phase` in the ledger. When idea or recipe lacks a fact, follow `../research/SKILL.md` from this skill's real directory. Before you start any worker, read [`models.md`](models.md).

When you write a test command, in a check or a worker spec, write it **scoped**: at most the test files that reach the code the dish changes, directly or through its callers. Find them by a search for callers; go wider only when that search is unreliable, and record the reason in the ledger events. Have the command print progress as it runs.

When a phase ends, run its **hooks**: each `after <phase>` entry under `## Hooks` in an overlay that applies, in listed order. Read the file the entry names, follow it with the entry's note, and record the result in the ledger events. Then hand off the dish if this is its handoff point (step 3); otherwise enter the next phase.

A dish has two **gates**: the brief and the recipe. The user approves the brief; the recipe gate waits for the user only on a gap (`phases/recipe.md`, step 5). At each gate, test for a split, record the gate's date in the ledger and correct the size (`phases/size.md`, steps 2 and 3). Between gates, run to completion. Also stop for a destructive or production action, for a recipe deviation, and for a second return from taste (`phases/taste.md`, step 6).

A **deploy unit** changes production: a push, a deploy, a migration there. A dish that has one runs saute and taste twice:

1. **Code saute**: every other unit, until each is `pass` with an evidence file and all work is on one branch. It ends no phase: run no hook.
2. **Code taste**: set `phase: taste`; taste runs the diff review and every check that neither deploys nor needs the deployed system. When it is done, record `code taste passed <commit>` in the ledger events and set `phase: saute`. It ends no phase: run no hook and no review.
3. **Deploy saute**: the deploy ships commits, not the working tree. Run `git status --porcelain`. If it prints a file of the dish, that edit was not tasted: reopen in the ledger the code units it touches, commit only the dish's edits and start again at 1. Otherwise ask for approval of the exact deploy action, then build the deploy units. Saute is then done.
4. **Live taste**: the **live checks**, those that need the deployed system. Taste is then done, with the checks of both passes in its table. A live failure that needs changed code reopens the deploy units: start again at 1.

On resume, `phase: taste` with a deploy unit not `pass` is the code taste; `phase: saute` is the deploy saute only when the events hold `code taste passed` for the current commit.

## 3. Hand off to a dish worktree

Each dish is built in its own **dish worktree**, by a session there, so the main checkout keeps its branch and files. A session in the main checkout **hands off** the dish at its **handoff point**: the end of the size phase for a trivial dish, the end of the idea phase for any other. A session in another worktree writes that worktree to the ledger at the handoff point and cooks the dish there. A meal is handed off whole, to its meal agent: `meal.md`, step 2.

1. Start the worktree and its agent from the current branch:

   ```bash
   orca worktree create --name <slug> --base-branch "$(git branch --show-current)" \
     --agent pi --model "$PI_PROVIDER/$PI_MODEL" --effort "$PI_REASONING_LEVEL" \
     --prompt "Read <this skill's real directory>/SKILL.md and follow it. Ask: continue the dish <slug>." --json
   ```

2. Write the worktree `path` of the reply to the `worktree` line of the ledger, and record the handoff and `$PI_SESSION_FILE` in the events.
3. Tell the user in one line which worktree continues the dish, then end your turn.

If the command fails, show the error and stop.

## Ledger template

```markdown
# <slug>
ask: <one line>
meal: <meal|none>
worktree: <path|none>
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
