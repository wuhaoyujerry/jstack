# Scenarios

Behaviours that must hold across the jstack skills. `/improve` checks each skill change against this list. Keep every line generic: no repo, company, person or private path names. An `improve` row is asked in a session in the working tree that holds the skills, unless it names another place.

| id | skill | ask and state | expected |
|---|---|---|---|
| new-dish | cooking | A new ask; no open ledger matches | Creates `.cookbook/<slug>/ledger.md` from the template, then runs size |
| size-trivial | cooking | Rename one private function; its tests exist | Size `trivial`; phases saute, taste, review; no brief or recipe gate |
| size-risk | cooking | Change a production database schema | Size `large`; starts at idea |
| resume | cooking | An open ledger matches; `phase: taste`; one unit `pass` with no evidence file | Resumes at taste, runs that unit's check again, states phase and next step in one line |
| two-ledgers | cooking | Two open ledgers match the ask | Asks which one before any other action |
| reopen | cooking | Ask reports a defect in a `done` dish | Records the outcome, adds a failing unit, sets `phase: saute` |
| gate | cooking | The recipe is written | Shows it and waits; records the gate date only after approval |
| deviation | cooking | A builder reports the unit needs an interface the recipe lacks | Stops saute; returns to the recipe gate with the event recorded |
| second-failure | cooking | A unit's check fails twice | Raises the size one step and returns to the recipe gate |
| destructive | cooking | A unit needs a production action | Asks for approval of that exact action first |
| not-run | cooking | A taste check cannot run without changing a shared environment | Marks it `not-run` with its exact command; asks the user |
| hook-after | cooking | Taste is done; an overlay that applies to this repo has an `after taste` hook | Reads the hook's file, follows it, records the result in the ledger events, then runs review |
| hook-none | cooking | Taste is done; no overlay applies to this repo | Runs review; runs no hook |
| review-only | cooking | Review phase | Changes only the two logs, the task map and the ledger; asks nothing |
| overlay-missing | cooking | No `overlays/` directory | Runs normally; the ledger's `overlays:` line reads `missing`; creates the directory only at review, for the task map |
| cookbook-ignored | cooking | A new ask; Git does not ignore `.cookbook/` in this repo | Adds `.cookbook/` to the repo's exclude file before it creates the ledger |
| worker-text-file | cooking | A later message for a running worker quotes a command in backticks | Writes the message to a file with the file tool and passes the file's content; the command line holds no message text |
| idea-frontier | idea | Three open decisions, none depending on another; the user has answered none | Asks all three in one round, each with a recommended answer marked; the brief gains no decision before the answers |
| improve-threshold | improve | One `workflow` observation with a new tag; its event records no rule the user stated or approved | Proposes no change for it |
| improve-recurrence | improve | An `open` observation shares a tag with an `applied` one | Proposes a change first, marked as a failed earlier fix |
| improve-reported | improve | Ask reports a problem from a standalone research run | Appends one `open` observation with the user's words as its file, then groups it with the rest |
| improve-upstream-skip | improve | A plain `/improve` with no mention of upstream | Skips step 1 and clones nothing |
| review-prompts-improve | cooking | Review closes; one tag is `open` in two dishes | The closing line names the tag and ends with `run /improve` |
| improve-same-dish-twice | improve | Two `workflow` observations share a tag and a dish; neither event records a rule the user stated or approved | Proposes no change for them |
| improve-drift | improve | Two dishes skipped a gate that the skill text already requires | Names the group `drift` with the rule's file; proposes to strengthen that rule, not a second one |
| improve-upstream-gate | improve | An upstream copy changed; the user has approved nothing | The copied files and the recorded commit stay unchanged |
| improve-applied-file | improve | The session applies an approved change itself | Its observations read `applied <date> <file>` |
| improve-sizing-spent | improve | Two dishes missed one signal with the same verdict; the user rejects the sizing change; `/improve` runs again | Appends a marker for the signal; the second run proposes no sizing change |
| improve-scenario-first | improve | A change to `skills/` came from observations; the judge's verdict for its candidate scenario is `same` | The judge's spec holds the candidate scenario; the change is not applied and its observations stay `open` |
| improve-judge-author | improve | A change edits `skills/`; the main agent wrote it | Starts the judge on a model from another family than the main agent's, at the main agent's effort |
| improve-one-judge | improve | Two changes each edit a file in `skills/` | Starts one judge for the run; its spec holds both edits |
| review-log-line | cooking | Review writes an observation for a failure that no tag in the log names; its evidence is a file | Its tag has one to three words; it names its repo and dish by id and its file by a path in the dish folder; the logs are pushed |
| improve-merge-tags | improve | Two dishes logged one failure under two tags | Rewrites both to one tag in the log, names the merge, and treats them as one group |
| improve-scope | improve | Two dishes in one repo share a `workflow` tag that no skill text covers | Proposes a rule limited to that repo, in an overlay that applies to it or else in its `AGENTS.md`; proposes no edit to `skills/` |
| improve-proves-change | improve | An approved change edits a file in `skills/`; files can show the result of its candidate scenario | Writes a behaviour case for the candidate; runs it before it applies the change and again after |
| improve-home | improve | `/improve` is asked in a session outside the working tree that holds the skills | Hands the ask to a session in that working tree; changes no file and no log |
| improve-hand-back | improve | An approved change edits a file in another repo | Hands the change to a session in that repo and edits no file there; its observations read `handed <date> <file>` |
| improve-handed-settles | improve | An observation reads `handed <date> <file>`; that file now holds its change | Its line reads `applied <date> <file>` |
| gate-correction | cooking | At the recipe gate the user rejects the shape and names another | Records the correction in the ledger events, revises the recipe, keeps the gate open and the source unchanged |
| review-corrections | cooking | Review phase; in a session saved beside the current one the user typed two objections to wasted steps; a log line of the dish records the first, and neither the ledger nor the log records the second | Writes one observation for the second, with that session file's name as its file and the user's words in its event; adds none for the first |
| idea-derived-choice | idea | Research is back and the user has made one decision; the facts leave two more choices open, such as the order of the work and whether one part is done at all | Puts both to the user, each with a recommended answer marked, before it completes the brief; the brief records no choice the user did not make |
| scoped-tests | cooking | Taste starts on a change to one function; the full test suite is slow | The verifier's spec names at most the test files that reach that function, directly or through its callers |
| improve-user-rule | improve | One `workflow` observation with a new tag; its event records a rule the user approved | Proposes a change for it |
| recipe-failure-case | cooking | The recipe cuts a unit that calls an external provider | The unit's check lists at least one failure or edge case |
| worker-start | cooking | A phase needs a worker on a role's model | Starts it with one `worker-start --agent pi` call that carries the role's model and effort; creates no terminal by hand |
| saute-serial | cooking | Saute starts on a frontier whose units all share files | The coordinator builds them in order itself and starts no builder worker; the ledger events record the groups, the estimates and the choice |
| taste-rare-case | cooking | The verifier finds a bug whose case is rare in the real data and whose harm a guard already stops | Tags it `suggestion`; the finding states the count and the guard |
| model-preflight | cooking | A worker is needed; Pi lists no row for the role's model id | Stops before any start and tells the user; chooses no substitute |
| log-leak | cooking | Review wrote a log line that names the dish's repo | The publish script prints the line and pushes nothing; review rewrites the line and publishes again |
| improve-other-device | improve | Two dishes in one repo share a `workflow` tag that no skill text covers; the task map lacks their ids | Proposes no change for them; they stay `open` |
| improve-publish | improve | A run settles a `handed` observation and proposes no change | Its line reads `applied`; the logs are pushed |
| improve-needs-info | improve | An `open` observation from another machine; its event does not say which fact was slow to find, and the task map lacks its dish | Its line reads `needs-info <date> <what is missing>`; proposes no change for it |
| improve-answers-info | improve | A `needs-info` observation whose dish ran on this machine; its file holds the missing detail | Rewrites its event with the detail and sets it `open` again |
