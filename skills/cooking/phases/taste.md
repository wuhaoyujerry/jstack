# Taste

Prove each done-check on the real surface. Every check ends in one of three states: **pass**, **fail**, or **not-run**.

## 1. Choose the verifier

| Size | Verifier |
|---|---|
| trivial | the builder already ran the check; go to step 5 |
| standard | a fresh `verifier` worker |
| large, or any judgement check | a `judge` worker |

The verifier receives the recipe, the diff and the brief's done-checks, without the builder's reports.

## 2. Find the drive script

Use `.cookbook/taste/<surface>.md` if it exists. If the surface will be checked again and has no drive script, the verifier writes one from the repo:

- **Launch**: the exact command, and the sign that the app is usable.
- **Doctor**: one read-only check that the instance is worth driving.
- **Drive**: real commands and stable handles from this repo.
- **Evidence**: what to capture and where.
- **Cleanup**: stop only what the run started; keep the evidence.

A drive script counts only after one full run of it.

## 3. Run the checks

The verifier's loop, for each done-check and each unit check:

1. Start from a clean state: a fresh checkout or a rebuilt artifact.
2. Run the check through the real user path. Capture the action, the resulting state and the side effects.
3. Save the raw output to `<dish>/evidence/<check>-taste.txt`.
4. Record the state. A check that was skipped, was unavailable, or could not fail is **not-run**, with the reason.

Verification is **read-only**. A check that must change a shared environment is **not-run**, with its exact command, until the user approves it.

When a check fails, suspect the method of observation before the system.

## 4. Review the diff

The verifier then reads the diff and the code it touches: the tests, and every caller of a changed function or signature. It looks for a defect that no check covers, in this order: correct, safe, holds under load, tested, fast, lean. It finds the expected load in the repo and states which load it assumed.

A **finding** names its case: this input or situation gives this wrong result. No case, no finding. A finding is `must-fix` when it is a security hole, data loss, a break at the expected load, or a bug that normal use of the product meets; every other finding is a `suggestion`. Save the findings to `<dish>/evidence/review.txt`.

A case is **rare** when normal use meets it seldom or never: it needs a hand-made record, a one-off import of bad data, or timing that the expected load does not reach. Before the verifier writes a finding, it decides this from evidence: the count of the case in the real data it can read, set beside the expected load, or the path that leads to the case. A count of zero proves nothing for a case that only the dish's new code can create: there the path decides. A rare case is a finding only as a security hole, data loss or a break at the expected load. Any other rare case gets one line under `Rare, not reported:` at the end of `review.txt`, with that evidence, and it is closed: `taste.md` and the user get the findings only.

## 5. Read the raw output

Read each evidence file yourself; the verifier's summary only points to it. Write `<dish>/taste.md`, with the findings below the table:

```markdown
| check | state | evidence | reason |
```

## 6. Close

- **fail** or **must-fix**: return the unit to saute. It counts as a failure of that unit. Record the event.
- **Second return**: when the events already hold a return from taste, ask the user before you return anything. Show each `fail` and `must-fix` as its case; for each they choose to fix it, accept it by name, revert its unit or move it to a new dish. Record the choices in the events and in `taste.md`; one they accept, revert or move is closed. Return to saute only what they chose to fix.
- **suggestion**: the user decides.
- **not-run**: show the user the command. They approve the run, or accept the gap by name.
- Taste is done when no `fail` or `must-fix` is open, and each `not-run` is run or accepted.

Report the table to the user, then run review; after a code taste, return to saute instead (`../SKILL.md`, step 2).
