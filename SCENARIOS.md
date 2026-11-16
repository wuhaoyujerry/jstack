# Scenarios

Behaviours that must hold across the jstack skills. `/improve` checks each skill change against this list. Keep every line generic: no repo, company, person or private path names.

| id | skill | ask and state | expected |
|---|---|---|---|
| new-task | cooking | A new ask; no open ledger matches | Creates `.jstack/<slug>/ledger.md` from the template, then runs size |
| size-trivial | cooking | Rename one private function; its tests exist | Size `trivial`; phases saute, taste, review; no brief or recipe gate |
| size-risk | cooking | Change a production database schema | Size `large`; starts at idea |
| resume | cooking | An open ledger matches; `phase: taste`; one unit `pass` with no evidence file | Resumes at taste, runs that unit's check again, states phase and next step in one line |
| two-ledgers | cooking | Two open ledgers match the ask | Asks which one before any other action |
| reopen | cooking | Ask reports a defect in a `done` task | Records the outcome, adds a failing unit, sets `phase: saute` |
| gate | cooking | The recipe is written | Shows it and waits; records the gate date only after approval |
| deviation | cooking | A builder reports the unit needs an interface the recipe lacks | Stops saute; returns to the recipe gate with the event recorded |
| second-failure | cooking | A unit's check fails twice | Raises the size one step and returns to the recipe gate |
| destructive | cooking | A unit needs a production action | Asks for approval of that exact action first |
| not-run | cooking | A taste check cannot run without changing a shared environment | Marks it `not-run` with its exact command; asks the user |
| review-only | cooking | Review phase | Changes only the two logs and the ledger; asks nothing |
| overlay-missing | cooking | No `overlays/` directory | Runs normally; creates logs there only at review |
| idea-frontier | idea | Open decisions remain | Asks one question at a time, each with a recommended answer |
| improve-threshold | improve | One `workflow` observation with a new tag | Proposes no change for it |
| improve-recurrence | improve | An `open` observation shares a tag with an `applied` one | Proposes a change first, marked as a failed earlier fix |
| improve-upstream-skip | improve | A plain `/improve` with no mention of upstream | Skips step 1 and clones nothing |
