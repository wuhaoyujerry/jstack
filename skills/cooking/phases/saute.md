# Saute

Builders build every unit until its check passes; you supervise from the ledger.

## 1. Plan the workers

The units form a graph. The **frontier** is every unit whose dependencies have passed.

- **Trivial task**: write the one unit and its check into the ledger yourself. Start one builder.
- **Coupled units**: one builder takes them in order, in the current worktree.
- **`parallel: yes` units on the frontier**: one builder each, in its own worktree: `orca worktree create --name <slug>-<unit> --json`.

## 2. Brief each builder

The worker spec points to files instead of repeating them: `recipe.md` (or the ledger for a trivial task), the unit ids, and the evidence folder. It gives the builder this loop for each unit:

1. If the unit fixes a defect, run its check first and save the failing output to `.jstack/<slug>/evidence/<unit>-repro.txt`. A check that passes here does not reproduce the defect: stop and report.
2. Build the unit as the **smallest complete change**:
   - Take the first source that fully works: code already in the repo, the standard library or platform, an installed dependency, then new code.
   - Build only what the unit names. Finish every caller, test and fixture the change breaks.
   - Keep validation at trust boundaries, error handling that prevents data loss, security and accessibility.
   - For a defect, read every caller of the function you change, then fix the cause once in the shared code.
   - Add only the test cases its check lists.
3. Run its check. Save the raw output to `.jstack/<slug>/evidence/<unit>-saute.txt`.
4. If the check passes, commit and take the next unit.
5. If it fails, fix and run it once more. On a second failure, stop and report both outputs.
6. If the unit needs something the recipe does not give (a parameter, a file, a different interface), stop and report the **deviation**.

The builder reports per unit: commit, check result, evidence path.

## 3. Handle each report

- **Pass**: set the unit to `pass` in the ledger. For a parallel unit, merge its branch, then run the checks of every unit already merged. Start builders for the new frontier.
- **Second failure**: the shape is wrong. Raise the size one step, record it, and return to the recipe gate with both outputs.
- **Deviation**: decide which is true, and record the event.
  - The recipe was wrong: change it and return to the recipe gate.
  - A requirement was missed: ask the user, add the decision and its done-check to the brief, then return to the recipe gate.
  - The change is doing too much: cut it back to the unit.
- **Destructive or production action**: get the user's approval for that exact action first.

## 4. Done

Saute is done when every unit is `pass` with an evidence file and all work is on one branch. Remove the worktrees you created, then run taste.
