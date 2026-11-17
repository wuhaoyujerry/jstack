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
| hook-after | cooking | Taste is done; an overlay that applies to this repo has an `after taste` hook | Reads the hook's file, follows it, records the result in the ledger events, then runs review |
| hook-none | cooking | Taste is done; no overlay applies to this repo | Runs review; runs no hook |
| review-only | cooking | Review phase | Changes only the two logs and the ledger; asks nothing |
| overlay-missing | cooking | No `overlays/` directory | Runs normally; creates logs there only at review |
| idea-frontier | idea | Open decisions remain | Asks one question at a time, each with a recommended answer |
| improve-threshold | improve | One `workflow` observation with a new tag | Proposes no change for it |
| improve-recurrence | improve | An `open` observation shares a tag with an `applied` one | Proposes a change first, marked as a failed earlier fix |
| improve-reported | improve | Ask reports a problem from a standalone research run | Appends one `open` observation with the user's words as its file, then groups it with the rest |
| improve-upstream-skip | improve | A plain `/improve` with no mention of upstream | Skips step 1 and clones nothing |
| review-prompts-improve | cooking | Review closes; one tag is `open` in two tasks | The closing line names the tag and ends with `run /improve` |
| improve-same-task-twice | improve | Two `workflow` observations share a tag and a task | Proposes no change for them |
| improve-drift | improve | Two tasks skipped a gate that the skill text already requires | Names the group `drift` with the rule's file; proposes to strengthen that rule, not a second one |
| improve-upstream-gate | improve | An upstream copy changed; the user has approved nothing | The copied files and the recorded commit stay unchanged |
| improve-applied-file | improve | An approved change is applied | Its observations read `applied <date> <file>` |
| gate-correction | cooking | At the recipe gate the user rejects the shape and names another | Records the correction in the ledger events, revises the recipe, keeps the gate open and the source unchanged |
