# Verify

Prove each done-check on the real surface. Every check ends in one of three states: **pass**, **fail**, or **not-run**.

## 1. Choose the verifier

| Size | Verifier |
|---|---|
| trivial | the builder already ran the check; go to step 4 |
| standard | a fresh `verifier` worker |
| large, or any judgement check | a `judge` worker |

The verifier receives the spec, the diff and the brief's done-checks, without the builder's reports.

## 2. Find the drive recipe

Use `.jstack/verify/<surface>.md` if it exists. If the surface will be checked again and has no recipe, the verifier writes one from the repo:

- **Launch**: the exact command, and the sign that the app is usable.
- **Doctor**: one read-only check that the instance is worth driving.
- **Drive**: real commands and stable handles from this repo.
- **Evidence**: what to capture and where.
- **Cleanup**: stop only what the run started; keep the evidence.

A recipe counts only after one full run of it.

## 3. Run the checks

The verifier's loop, for each done-check and each unit check:

1. Start from a clean state: a fresh checkout or a rebuilt artifact.
2. Run the check through the real user path. Capture the action, the resulting state and the side effects.
3. Save the raw output to `.jstack/<slug>/evidence/<check>-verify.txt`.
4. Record the state. A check that was skipped, was unavailable, or could not fail is **not-run**, with the reason.

Verification is **read-only**. A check that must change a shared environment is **not-run**, with its exact command, until the user approves it.

When a check fails, suspect the method of observation before the system.

## 4. Read the raw output

Read each evidence file yourself; the verifier's summary only points to it. Write `.jstack/<slug>/verify.md`:

```markdown
| check | state | evidence | reason |
```

## 5. Close

- **fail**: return the unit to build. It counts as a failure of that unit. Record the event.
- **not-run**: show the user the command. They approve the run, or accept the gap by name.
- Verify is done when no check is `fail`, and each `not-run` is run or accepted.

Report the table to the user. For a standard or large task, run retro.
