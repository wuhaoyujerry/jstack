# Build

Builders build every unit until its check passes; you supervise from the ledger.

## 1. Plan the workers

The units form a graph. The **frontier** is every unit whose dependencies have passed.

- **Trivial task**: write the one unit and its check into the ledger yourself. Start one builder.
- **Coupled units**: one builder takes them in order, in the current worktree.
- **`parallel: yes` units on the frontier**: one builder each, in its own worktree: `orca worktree create --name <slug>-<unit> --json`.

## 2. Brief each builder

The worker spec points to files instead of repeating them: `spec.md` (or the ledger for a trivial task), the unit ids, and the evidence folder. It gives the builder this loop for each unit:

1. Build the unit.
2. Run its check. Save the raw output to `.jstack/<slug>/evidence/<unit>-build.txt`.
3. If the check passes, commit and take the next unit.
4. If it fails, fix and run it once more. On a second failure, stop and report both outputs.
5. If the unit needs something the spec does not give (a parameter, a file, a different interface), stop and report the **deviation**.

The builder reports per unit: commit, check result, evidence path.

## 3. Handle each report

- **Pass**: set the unit to `pass` in the ledger. For a parallel unit, merge its branch, then run the checks of every unit already merged. Start builders for the new frontier.
- **Second failure**: the shape is wrong. Raise the size one step, record it, and return to the spec gate with both outputs.
- **Deviation**: decide which is true: the spec was wrong, a requirement was missed, or the build is doing too much. A spec change goes back to the spec gate. Record the event.
- **Destructive or production action**: get the user's approval for that exact action first.

## 4. Done

Build is done when every unit is `pass` with an evidence file and all work is on one branch. Remove the worktrees you created, then run verify.
