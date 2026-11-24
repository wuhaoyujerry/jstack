# Saute

Every unit is built until its check passes: by you in order, or by parallel builders that you supervise from the ledger.

## 1. Plan the workers

The units form a graph. The **frontier** is every unit whose dependencies have passed; a deploy unit joins it only after the code taste (`../SKILL.md`, step 2). For a trivial task, write the one unit and its check into the ledger yourself.

1. Put frontier units that share files into one **group**; a unit that shares none is a group of its own.
2. Estimate each group in minutes. Serial time is the sum. Parallel time is the longest group plus 10 to 15 minutes for worker starts, specs, merges and rechecks.
3. Take the shorter plan.
   - **Serial**: you are the builder, also for the judge rule in `models.md`. Take the units in order in the current worktree, by the loop in step 2, and handle each result as step 3 does.
   - **Parallel**: one builder worker per group, each in its own worktree: `orca worktree create --name <slug>-<group> --json`.
4. Record the groups, the estimates and the choice in the ledger events.

## 2. Brief each builder

The worker spec points to files instead of repeating them: `recipe.md` (or the ledger for a trivial dish), the unit ids, and the evidence folder. It gives the builder this loop for each unit:

1. If the unit fixes a defect, run its check first and save the failing output to `<dish>/evidence/<unit>-repro.txt`. A check that passes here does not reproduce the defect: stop and report.
2. Build the unit as the **smallest complete change**:
   - Take the first source that fully works: code already in the repo, the standard library or platform, an installed dependency, then new code.
   - Build only what the unit names. Finish every caller, test and fixture the change breaks.
   - Keep validation at trust boundaries, error handling that prevents data loss, security and accessibility.
   - For a defect, read every caller of the function you change, then fix the cause once in the shared code.
   - Add only the test cases its check lists.
3. Run its check. Save the raw output to `<dish>/evidence/<unit>-saute.txt`.
4. If taste returned the unit with a `must-fix`, prove the fix before the next taste round:
   - Run the verifier's own probe for the finding again: the command or steps in its evidence file, through the same path. If the finding names only a case, first write a probe that drives that case through the real user path. Save the output beside it. A new unit test alone is not this proof.
   - Read every caller of the code the fix changes. In the unit's check, list one case the finding did not name (another step order, a retry or re-entry, another caller path), then add or reuse its test.
5. If the check passes, run the **scope check** before you commit: `scope.sh <cases>` in the unit's working tree, by the absolute path of the script in the cooking skill's real directory. `<cases>` is the number of test cases the unit's check lists. Save its output to `<dish>/evidence/<unit>-scope.txt`.
   - Revert each change in a file it prints that the unit does not name and that no caller, test or fixture needs.
   - On exit 1 the unit adds more tests than its check lists. Remove each added test that covers no listed case. If each covers one, keep them and write the reason as the last line of the scope file.
   - After a revert or a removal, run the check and the scope check again.

   Then commit and take the next unit.
6. If it fails, fix and run it once more. On a second failure, stop and report both outputs.
7. If the unit needs something the recipe does not give (a parameter, a file, a different interface), stop and report the **deviation**.

The builder reports per unit: commit, check result, evidence path.

## 3. Handle each report

- **Pass**: set the unit to `pass` in the ledger. When the last unit of a parallel group passes, merge its branch, then run the checks of every unit already merged. When no builder is working and units remain, plan the new frontier by step 1.
- **Second failure**: the shape is wrong. Raise the size one step, record it, and return to the recipe gate with both outputs.
- **Deviation**: decide which is true, and record the event.
  - The recipe was wrong: change it and return to the recipe gate.
  - A requirement was missed: ask the user, add the decision and its done-check to the brief, then return to the recipe gate.
  - The change is doing too much: cut it back to the unit.
- **Destructive or production action**: get the user's approval for that exact action first.

## 4. Done

Saute is done when every unit is `pass` with an evidence file and all work is on one branch. Remove the worktrees you created, then run taste.
