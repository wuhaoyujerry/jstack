# Review of the cooking skill against 20 self-improvement papers

Date: 2026-11-18. Reviewed commit: `52a7cfd`. Every `path:line` in this report refers to that commit.

This report checks `skills/cooking/`, `skills/improve/`, and `tests/behaviour/` against 23 practices taken from 20 arXiv papers about agents that improve themselves. The papers come from one list, <https://x.com/n01ennn/status/2122687063115899207>. Appendix B lists them.

The review changed no file. It read the skill text, ran read-only commands on one machine, and read the full text of each paper.

## Summary

- The design matches 11 of the 23 practices, partly matches 9, and misses 1. Two practices do not apply.
- Review only records, and improve acts on a threshold with at most three changes. The papers support that split more than any heavier loop.
- Every claim needs a file, and the main agent reads the raw output itself.
- A skill edit is checked against scenarios, and a fix that did not hold returns as a recurrence.
- The weak part is the loop's check on itself. Sizing evidence counts again at every run, and no skill file names the behaviour tests.
- Two setup defects on the reviewed machine come before any text change. See F1 and F2.
- On the reviewed machine no run log exists. The nine suggested changes are hypotheses from the text, not observed failures.

The report has three kinds of finding.

| Ids | Kind | Count |
|---|---|---|
| F1, F2 | Setup defect, observed by command | 2 |
| S1 to S9 | Suggested change to the skill text | 9 |
| W1 to W4 | Item to watch, with no change yet | 4 |

## How to read the evidence

Each finding carries two kinds of source.

- **Skill evidence** is a `path:line` at commit `52a7cfd`, quoted word for word.
- **Paper evidence** is an arXiv id and a section heading, with a quotation or a number from that section. The source is the HTML full text at `https://arxiv.org/html/<id>`, read on 2026-11-18.

Each finding has a grade.

- **Observed** means a command showed it, or the quoted line states it.
- **Inferred** means the reviewer reasoned it from the text. No run confirmed it.

Worker agents read the main text of each paper in full. The reviewer then found each cited passage in the full text by search and copied the quotation from it. A script matched every quotation in this report against its source file on the review date. Appendix C describes that check and has the commands for the counts and the setup checks.

A quotation marked `[...]` skips words. A number given without a quotation comes from a table or from a sentence that holds a formula.

## Work order

1. Fix F1 and F2 on each machine that runs cooking. This takes about 10 minutes per machine.
2. Apply S3 and S6. Each is one or two lines, and the skill text alone proves the gap.
3. Apply part (a) of S5. It adds no cost.
4. Run cooking on three real tasks. Then read `review-log.md`.
5. Adopt S1, S2, S4, S7, S8, or S9 when a run shows its failure.

The skill's own rule covers this report. A workflow change needs the same tag in two tasks (`skills/improve/SKILL.md:45`). S1 to S9 have no observation behind them. Steps 2 and 3 are the exception, because there the skill text contradicts itself.

Three notes apply to the whole list.

- If another machine holds a `review-log.md` or a filled `sizing-log.md`, read it first. A real observation outranks any hypothesis here.
- Each "Sketch" below is unreviewed wording. `AGENTS.md` requires the `writing-for-agents` check before any edit to `skills/`.
- Each "Check" below is a scenario row in the format of `SCENARIOS.md`. It says how to tell that the change worked.

## Setup defects

### F1. The installed skill finds no overlays

**Grade.** Observed on one machine on 2026-11-18.

**What the commands showed.**

- `~/.agents/skills/_jstack__skills__cooking` and `~/.claude/skills/_jstack__skills__cooking` are symlinks to `~/.config/skillshare/skills/_jstack/skills/cooking`. The improve links resolve into the same directory tree.
- `~/.config/skillshare/skills/_jstack` is its own Git clone of this repo's remote at `52a7cfd`. It is not a link to the development checkout.
- The clone has no `overlays/` directory. The development checkout has `overlays/work.md` and a `sizing-log.md` that holds only its header. Neither place has a `review-log.md`.
- A search of the usual project folders found no `.jstack/` directory, so no cooking run has finished on that machine. This last point is inferred from the folders searched.

**Skill evidence.**

> `skills/cooking/SKILL.md:23` "The optional private overlay directory is `../../overlays/` relative to it, outside the synced skill. [...] Missing overlays are normal."

> `skills/improve/SKILL.md:13` "The logs are `review-log.md` and `sizing-log.md` in `../../overlays/` relative to it"

> `skills/cooking/phases/review.md:45` "Create the directory and the logs if missing; never write a log into the synced skill."

> `README.md:10` "Link a checkout: `skillshare link "$PWD/skills/cooking" --name cooking --enable -g`"

> `README.md:12` "Skillshare and agent skill folders link here; edits through those links change this repo."

**Effect.**

- The private work overlay never loads. The skill treats a missing overlay directory as normal, so nothing reports it.
- The first review creates the two logs inside the skillshare clone, apart from the overlay file in the development checkout.
- Improve edits the skill files at its real directory. On the reviewed machine that is the clone, so `README.md:12` is false there.

**Fix for the machine.** Neither option was run.

1. Link the development checkout as `README.md:10` says. The review did not check how `skillshare link` treats the existing tracked install.
2. Or link the overlay directory into the clone with `ln -s <checkout>/overlays ~/.config/skillshare/skills/_jstack/overlays`. A test in a temporary repo showed one side effect. The ignore pattern `/overlays/` matches a directory only, so Git lists the link as untracked. This option also leaves improve editing the clone.

**Proposed change to the skill.** At the start of a task, the skill writes what it resolved to the ledger. A missing overlay directory then shows as a fact the user can read. The taste phase already separates "did not run" from "passed" (`skills/cooking/phases/taste.md:34`). The same idea applies here: a directory that is absent is unknown, not "no overlay applies".

Sketch for the ledger template in `skills/cooking/SKILL.md`:

```text
overlays: <directory>, <each overlay that applies> | none found at <directory>
```

**Check.** The scenario `overlay-missing` changes.

> `SCENARIOS.md:21` "| overlay-missing | cooking | No `overlays/` directory | Runs normally; creates logs there only at review |"

Its new expected text adds "writes `overlays: none found at <directory>` to the ledger". A behaviour case can assert this on the ledger file.

**Paper evidence.** None. This is a setup defect.

### F2. Git does not ignore `.jstack/`

**Grade.** Observed on one machine on 2026-11-18.

**What the commands showed.**

- `git check-ignore -q .jstack/x` exits with 1 in a new empty repo, in the development checkout, and in one other local repo.
- `git config --global --get core.excludesfile` prints nothing. `~/.config/git/ignore` does not exist. The global config has no `includeIf` rule.

**Skill evidence.**

> `skills/cooking/SKILL.md:11` "Task state lives in `.jstack/<slug>/` at the repo root; Git ignores it globally."

> `README.md:9` "Task artifacts stay in each working repo's Git-ignored `.jstack/` directory."

> `skills/cooking/phases/saute.md:25` "If the check passes, commit and take the next unit."

> `tests/behaviour/run.sh:34` "(cd "$REPO" && git init -q && printf '.jstack/\n' > .git/info/exclude)"

**Effect.** `git status` lists `.jstack/` as untracked. A builder that stages every file commits briefs, ledgers, and raw check output. The behaviour tests cannot catch this, because `tests/behaviour/run.sh:34` writes the exclude into every fixture.

**Fix for the machine.**

```bash
mkdir -p ~/.config/git && echo '.jstack/' >> ~/.config/git/ignore
```

**Proposed change to the skill.** The skill text states a fact about the machine and nothing checks it. The repo's own writing rule names this risk.

> `skills/writing-for-agents/SKILL.md:79` "The **environment** is a source of truth too [...] and a document that restates it is a **cache**"

Sketch for step 1 of `skills/cooking/SKILL.md`, with line 11 reduced to its first clause:

```text
Before the first write, run `git check-ignore -q .jstack/x`. If it fails, append `.jstack/` to `.git/info/exclude`.
```

**Check.**

```text
| jstack-ignored | cooking | A new ask; Git does not ignore `.jstack/` in this repo | Adds `.jstack/` to `.git/info/exclude` before it writes the ledger |
```

A behaviour case can assert this on files. Its `setup.sh` must empty `.git/info/exclude`, because `tests/behaviour/run.sh:34` fills it.

**Paper evidence.** None. This is a setup defect.

## Scorecard: 23 practices

Appendix A gives the paper evidence for each practice. P01 to P20 are the papers in Appendix B.

| # | Practice | Status | Skill evidence | Papers | Finding |
|---|---|---|---|---|---|
| 1 | Keep one bounded note | partial | `review-log.md` only grows. `SCENARIOS.md` gains one row per applied change (`skills/improve/SKILL.md:63`). | P17, P02 | W1, W2 |
| 2 | Improve only on a trigger | match | Review only records. Its last line names `/improve` when a tag reaches two tasks (`skills/cooking/phases/review.md:61`). | P11, P19 | |
| 3 | Use real feedback only | match | "No file, no observation" (`skills/cooking/phases/review.md:9`). Review logs later outcomes that the user reports (`skills/cooking/phases/review.md:65`). | P13 | |
| 4 | Count the cost | missing | The ledger template and both log formats have no cost field (`skills/cooking/SKILL.md:37-50`, `skills/cooking/phases/review.md:50`, `skills/cooking/phases/review.md:56`). | P17 | S9 |
| 5 | Write four fields per lesson | partial | Event, file, and tag exist (`skills/cooking/phases/review.md:56`). Phase and scope do not. | P01, P13 | S7, S8 |
| 6 | Wait for a second case | match | A workflow change needs one tag in two tasks (`skills/improve/SKILL.md:45`). | P03, P14 | |
| 7 | Narrow before you drop | match | A recurrence revises the earlier change (`skills/improve/SKILL.md:32`). Drift strengthens the one rule (`skills/improve/SKILL.md:53`). | P01, P03 | |
| 8 | Keep the source | partial | `<file>` holds the source. The path can be relative, and the file can be gone (`skills/improve/SKILL.md:36`). | P04 | S8, W4 |
| 9 | Keep recovery lessons | partial | One evidence file per unit (`skills/cooking/phases/saute.md:24`). A run that fails and then passes keeps only the pass. | P14 | S2 |
| 10 | Test what passed before | match | Each skill edit gets `same`, `fixed`, or `broken` per scenario (`skills/improve/SKILL.md:59`). A merged unit runs the earlier checks again (`skills/cooking/phases/saute.md:33`). | P20, P01 | |
| 11 | Beat the noise | partial | A behaviour case needs 3 of 3 passes on two models (`tests/behaviour/run.sh:12-14`). Sizing lines count again at every run. | P09, P10 | S6 |
| 12 | Hide the checker | partial | The builder builds to the check (`skills/cooking/phases/saute.md:3`). Taste runs the same checks again (`skills/cooking/phases/taste.md:29`). | P08 | S4 |
| 13 | Check the end state | match | Taste starts clean and uses the real user path (`skills/cooking/phases/taste.md:31-32`). The main agent reads each raw output (`skills/cooking/phases/taste.md:48`). | P05, P06 | |
| 14 | Test the verifier | partial | The check runs first only for a defect (`skills/cooking/phases/saute.md:17`). No step shows that a new scenario fails. | P05 | S1, S5 |
| 15 | Read the raw trace | match | Raw output is saved per check. The verifier's summary only points to it (`skills/cooking/phases/taste.md:48`). | P11 | |
| 16 | Find the first wrong step | partial | An observation has no phase and no earliest cause (`skills/cooking/phases/review.md:56`). | P18 | S8 |
| 17 | Name the faulty part | match | Seven categories each route to one kind of repair (`skills/improve/SKILL.md:38-49`). | P18 | |
| 18 | Make exact small edits | match | At most three changes per run (`skills/improve/SKILL.md:55`). The judge sees the exact edit (`skills/improve/SKILL.md:59`). | P11 | |
| 19 | Use a second-model critic | partial | The judge differs from the builder. In improve it can be the author's model (`skills/cooking/models.md:14`). | P12 | S3 |
| 20 | Write a three-part description | n/a | cooking, idea, and improve start only when the user types them. | P15 | |
| 21 | Check neighbours on each add | n/a | Same reason. | P15 | |
| 22 | Load few skills | match | The skill reads one phase file at a time (`skills/cooking/SKILL.md:29`). | P16 | |
| 23 | Choose skills during the task | match | The ledger's phase selects the file (`skills/cooking/SKILL.md:29`). An overlay applies by its own rule (`skills/cooking/SKILL.md:23`). | P16 | |

## Suggested changes to saute, taste, and models

### S1. Run every new check before the build

**Grade.** The gap is observed in the text. The benefit is inferred.

**Gap.** The builder runs a check before the build only when the unit fixes a defect. A unit that adds a behaviour can deliver a test that never failed. Taste marks a check that could not fail as not-run, but only later, and only if the verifier notices.

**Skill evidence.**

> `skills/cooking/phases/saute.md:17` "1. If the unit fixes a defect, run its check first and save the failing output to `.jstack/<slug>/evidence/<unit>-repro.txt`. A check that passes here does not reproduce the defect: stop and report."

> `skills/cooking/phases/taste.md:34` "A check that was skipped, was unavailable, or could not fail is **not-run**, with the reason."

> `SOURCES.md:25` "Reproduce first: the unit's check fails before the fix and passes after"

> `SOURCES.md:23` "Ticket tracker, `tdd` and `code-review` calls, draft PR handling"

The last two lines show a past decision. The skill kept "reproduce first" for defects and dropped the `tdd` call. S1 keeps only the failing run from that call.

**Paper evidence.**

> [2611.13336, "Probe and one repair"] "Two outcomes trigger one regeneration: a crash, and a verifier that accepts a candidate known to be wrong, such as the task's initial state before any work is done."

> [2610.11794, "Abstract"] "Updated code is accepted only when the LLM judges it faithful to the rulebook and cell-exact replay reproduces the observed transitions."

Veritas (P05) treats a verifier that accepts the untouched start state as broken. A check that passes before the build is the same case.

**Proposed change.** Sketch for `skills/cooking/phases/saute.md:17`:

```text
1. If the unit adds a behaviour or fixes a defect, write its listed test cases, run its check, and save the failing output to `.jstack/<slug>/evidence/<unit>-repro.txt`. A check that passes here cannot fail for this change: stop and report.
```

A unit that only preserves behaviour is exempt. Its check is that the existing tests still pass.

**Check.**

```text
| red-first | cooking | A unit adds a behaviour; its check passes before the build | The builder stops and reports; the unit is not built |
```

The behaviour tests stub every worker (`tests/behaviour/run.sh:36`), so no case can run a builder. Only the judge's read of the scenario covers this row.

**Cost.** One more check run per unit.

### S2. Keep the output of every attempt

**Grade.** Inferred. The text names one file per unit. The review did not run a builder.

**Gap.** One file holds a unit's check output. When the first run fails and the second passes, the second run replaces the first. The ledger keeps a count of failures but not the failing output. Review then has no file for the event, and without a file there is no observation.

**Skill evidence.**

> `skills/cooking/phases/saute.md:24` "3. Run its check. Save the raw output to `.jstack/<slug>/evidence/<unit>-saute.txt`."

> `skills/cooking/phases/saute.md:26` "5. If it fails, fix and run it once more. On a second failure, stop and report both outputs."

> `skills/cooking/SKILL.md:45` "| unit | check | parallel | status | fails | evidence |"

> `skills/cooking/phases/review.md:9` "An **observation** is one event from this run and the file that shows it: an evidence file or the ledger. No file, no observation."

**Paper evidence.**

> [2610.35616, "4.1 L1: Agent Rollouts and Task Evidence"] "Failed-to-successful and successful-to-failed transitions provide strong positive and strong negative evidence, respectively"

> [2610.35616, "5.3 Component Analysis"] "On DeepSWE, removing the two recovery skills leaves HSE only 0.3 points above No Skills with Pi and 2.1 points above it with CC."

> [2611.02839, "1 Introduction"] "model-attributable failures are cut at the first erroneous decision and repaired"

> [2610.21170, "Abstract"] "On GAIA, the trace-and-memory inspection variant achieves 86.67% accuracy, compared with 70.00% for trace-only and 63.33% for summary-only feedback."

HSE (P14) treats a run that fails and then passes as its strongest evidence, and its recovery skills carry most of the gain on the harder benchmark. CARE (P18) and MemScope (P11) both need the raw failing output to find the cause.

**Proposed change.** Sketch for `skills/cooking/phases/saute.md:24`, with the same naming for taste:

```text
3. Run its check. Save the raw output of each run to `.jstack/<slug>/evidence/<unit>-saute-<n>.txt`.
```

Sketch for step 1 of `review.md`:

```text
A unit that failed and later passed is one observation source: name what changed between the two outputs.
```

**Check.**

```text
| attempt-evidence | cooking | A unit's check fails once, then passes | Both outputs exist as separate evidence files |
```

No behaviour case can run a builder, so only the judge's read covers this row.

### S3. State the judge rule by author

**Grade.** Observed in the text.

**Gap.** The rule that keeps the judge independent names only the builder. In improve, the main agent writes the change, and the judge can be the same model. In the review session the main agent ran `claude-fable-5-2`, which is the judge model. A standard task has the same gap in taste: the builder and the verifier are one model.

**Skill evidence.**

> `skills/cooking/models.md:14` "The **judge** is the strong model from the family that did not build. If the builder changes family, change the judge."

> `skills/cooking/models.md:12` "| judge | `anthropic/claude-fable-5-2:medium` |"

> `skills/cooking/models.md:10` "| builder | `openai-codex/gpt-6.1-sol:medium` |"

> `skills/cooking/models.md:11` "| verifier | `openai-codex/gpt-6.1-sol:medium` |"

> `skills/improve/SKILL.md:59` "Start one fresh read-only `judge` worker as `../cooking/models.md` describes."

> `skills/cooking/phases/taste.md:10` "| standard | a fresh `verifier` worker |"

> `tests/behaviour/run.sh:13` "# The main agent is one of these two, so every case runs on both."

**Paper evidence.**

> [2611.06049, "Abstract"] "a critic from a second model family screens each one for benchmark gaming"

> [2611.06049, "Proposer, critic and evaluator"] "so the proposer and the critic come from different model families"

> [2611.15276, "5.6 RQ4: Co-evolution in Practice"] "Verification can still misinterpret evidence: Finance024 treats a file timestamp as a business date and selects a failing output"

Reglos (P12) picks the critic by the proposer's family. Verify by Doing (P06) shows one case where the checking agent misread the evidence and selected a failing output.

**Proposed change.** Sketch for `skills/cooking/models.md:14`:

```text
The **judge** is the strong model from the family that did not write what it judges: the builder's diff in taste, the main agent's change in improve. If the author changes family, change the judge.
```

The table then needs a judge model for an author from each family. The owner picks that model.

**Check.**

```text
| improve-judge-family | improve | The main agent is from the judge's family; a change edits `skills/` | Starts the judge on the other family's strong model |
```

A behaviour case can assert this. The worker stub writes each start attempt to `$ORCA_LOG`, and that line holds the model name.

**Open decision.** Moving the standard-size verifier to the other family is a cost choice. This report does not recommend for or against it.

### S4. Add one variation per done-check at taste

**Grade.** Inferred. This change is optional.

**Gap.** The builder works until its check passes. The verifier then runs the same done-checks and unit checks. A change that fits those checks and nothing else passes both.

**Skill evidence.**

> `skills/cooking/phases/saute.md:3` "Builders build every unit until its check passes; you supervise from the ledger."

> `skills/cooking/phases/taste.md:29` "The verifier's loop, for each done-check and each unit check:"

Three rules already reduce this risk.

> `skills/cooking/phases/taste.md:13` "The verifier receives the recipe, the diff and the brief's done-checks, without the builder's reports."

> `skills/cooking/phases/taste.md:32` "2. Run the check through the real user path. Capture the action, the resulting state and the side effects."

> `skills/cooking/phases/taste.md:42` "It looks for a defect that no check covers"

The last rule works by reading the diff. Nothing runs a case that the builder did not see.

**Paper evidence.**

> [2611.08318, "Abstract"] "this advantage disappears when the criteria are changed slightly without departing from the original instructions"

> [2611.08318, "4.2.3 Synthesis and Implications"] "About a third of the exposed memory entries cite the criteria code, and none of the success-only ones do."

> [2611.08946, "Abstract"] "kept only if it scores higher on held-out validation data"

In the Criteria Exposure paper (P08), an agent that could read the checker code scored 51.6% against 27.8% under the original criteria. Under criteria rewritten to follow the instruction, the same episodes scored 45.0% against 47.2%. The numbers are in the figure caption before section 1. A library tuned to one set of criteria fell from 65.0% to 13.5% under the other set (section 4.2.2, "Results").

**Proposed change.** Sketch for a new item in step 3 of `taste.md`:

```text
5. For each done-check, run one variation from the brief's Goal that the recipe does not list: another input or path for the same behaviour. A variation that fails is a finding with its case.
```

**Check.**

```text
| taste-variation | cooking | A done-check passes; a variation of its input from the brief fails | Taste records a must-fix finding with the case |
```

No behaviour case can run a verifier, so only the judge's read covers this row.

**Cost.** One more run per done-check, for standard and large tasks only.

## Suggested changes to review and improve

### S5. Write the scenario first, and run its behaviour case

**Grade.** Observed in the text.

**Gap.** Improve adds the new scenario after it applies the change. No step shows that the scenario fails on the old text, so a change can be approved that does not address its own observation. The repo also has executable behaviour tests, and no file in `skills/` names them. The judge reads the scenarios. Nothing runs them.

**Skill evidence.**

> `skills/improve/SKILL.md:59` "It walks every scenario through the text before and after the edit, and reports each scenario whose result changes."

> `skills/improve/SKILL.md:63` "For each applied change that came from observations, add one scenario to `SCENARIOS.md` that would have caught them. Write it generic, as that file requires."

> `README.md:15` "`tests/behaviour/run.sh` runs scenarios as headless Pi agents on seeded fixtures and asserts on the files they leave."

> `tests/behaviour/run.sh:36` "# Workers are out of scope: a stub records each attempt to start one."

`grep -rn "tests/behaviour" skills/` prints nothing. `SCENARIOS.md` has 26 scenarios, and `tests/behaviour/cases/` has 13 cases.

**Paper evidence.**

> [2611.13336, "Probe and one repair"] "Two outcomes trigger one regeneration: a crash, and a verifier that accepts a candidate known to be wrong, such as the task's initial state before any work is done."

> [2611.14326, "4.1 Overview"] "It is committed to persistent agent state only when it improves target cases, survives targeted falsification, and preserves previously solved behavior."

> [2611.15276, "1 Introduction"] "the Evaluator uses its own harness to inspect artifacts and environment state, recording satisfied, violated, and unresolved requirements"

In FGSE (P01), removing the falsification probes raised the failure rate from 5.0% to 18.6% and harmful updates from 3.6% to 10.6% (section "Single-factor ablation"). In Verify by Doing (P06), removing active verification lowered the overall AutomationBench score from 37.0 to 34.3 (the results table in section 5).

**Proposed change.** The change has two parts.

Part (a) costs nothing. Sketch to replace `skills/improve/SKILL.md:63` and extend line 59:

```text
For a change that came from observations, first write the scenario that would have caught them, and add it to the scenario file you give the judge. The change is ready to propose when that scenario's verdict is `fixed`.
```

A verdict of `same` then means the change does not address the observation.

Part (b) costs model tokens. Sketch for the end of step 4:

```text
After you apply a change, run `tests/behaviour/run.sh <case>` for each case whose scenario the judge marked `fixed` or `broken`.
```

**Check.**

```text
| improve-scenario-first | improve | An approved change came from observations | The new scenario exists before the judge runs and has the verdict `fixed` |
```

**Cost.** One behaviour case is 6 agent runs by default: 3 runs on each of 2 models (`tests/behaviour/run.sh:12`, `tests/behaviour/run.sh:14`). Run only the touched cases.

### S6. Count each sizing line once

**Grade.** The gap is observed in the text. The effect is inferred and was not run.

**Gap.** A sizing line has no status. Step 4 of improve marks only the lines of `review-log.md`. After the user accepts or rejects a sizing change, the same two lines still meet the threshold at the next run. The last line of every later review also names the signal. A miss from before the change cannot be told from a miss after it.

**Skill evidence.**

> `skills/cooking/phases/review.md:50` "`<date> | <repo> | <slug> | predicted=<size> | verdict=<right|under|over> | missed=<signal|none>`"

> `skills/improve/SKILL.md:30` "Group the `sizing-log.md` lines by missed signal and verdict."

> `skills/improve/SKILL.md:46` "| sizing | A change to the signal in `../cooking/phases/size.md` | the same signal missed twice with the same verdict |"

> `skills/improve/SKILL.md:65` "In `review-log.md`, replace `open` on every observation of a proposed group with `applied <date> <file>`, naming the file the change edited, or `rejected <date>`. The other observations stay `open`."

> `skills/cooking/phases/review.md:61` "each tag or missed signal that now appears in two tasks"

**Paper evidence.**

> [2611.10787, "1 Introduction"] "Noise from finite samples and overfitting from reusing validation data can both make inferior updates appear beneficial and pass a greedy gate"

> [2611.10787, "Abstract"] "TRUST reduces the average ratio of accepted inferior updates from the greedy gate's 45.59% to 2.78%"

> [2610.12789, "3.5 Using the World Model for Prediction and Planning"] "A success caused by using the rule is recorded for analysis but does not count as new independent support for the same rule."

TRUST (P10) corrects for validation samples that are used again. Its parameter β sets the strength of that correction. With β at 0, 23.33% of accepted updates were inferior. With β at 0.03, none were (section 6.2, "Ablation study"). EvoBelief (P03) counts a piece of support once.

**Proposed change.** Sketch for step 4 of `improve/SKILL.md`:

```text
When the user decides a sizing change, append `<date> | signal=<signal> | applied <file>` or `<date> | signal=<signal> | rejected` to `sizing-log.md`.
```

Sketch for step 2 of `improve/SKILL.md` and for `skills/cooking/phases/review.md:61`:

```text
Count a signal's lines only after its last marker line.
```

When improve proposes a sizing change, it also states the count of `right`, `under`, and `over` lines since that marker. Two misses in one direction among many `right` lines are weaker than two misses in three tasks.

**Check.**

```text
| improve-sizing-consumed | improve | Two old misses of one signal; a marker line for that signal follows them | Proposes no sizing change |
```

A behaviour case can assert this on files, as `improve-threshold` does.

### S7. Send a change to the scope its evidence covers

**Grade.** The gap is observed in the text. The benefit is inferred.

**Gap.** Improve groups tags across repos. Two tasks in one repo are enough to change the generic cooking text. The skill says where work-specific rules belong, but the improve table gives a workflow change one destination.

**Skill evidence.**

> `skills/improve/SKILL.md:30` "Group the `open` observations by tag, across tasks and repos."

> `skills/improve/SKILL.md:45` "| workflow | An edit to the cooking text | the same tag in two tasks |"

> `skills/cooking/SKILL.md:25` "Keep work-specific rules and generated workflow logs in that private overlay directory, never inside this skill."

> `SCENARIOS.md:3` "Keep every line generic: no repo, company, person or private path names."

**Paper evidence.**

> [2610.35616, "Abstract"] "then aggregates recurring evidence within the same repository to form repository-specific skill candidates, and finally consolidates consistent patterns across repositories into transferable skills across repositories"

> [2610.35616, "5.3 Component Analysis"] "This reduces performance by 1.2–2.0 points on SWE-bench Verified and 1.8–3.8 points on DeepSWE."

> [2610.12789, "3.2 World Knowledge as Testable Hypotheses"] "broader scope is earned only from evidence across varied bindings rather than assumed in advance"

> [2611.07624, "Abstract"] "Specific changes usually outperform generic reminders, but their benefits can change when combined."

> [2611.14326, "3 Preliminary Study"] "many harmful but useful updates can be repaired by narrowing their applicability"

The second HSE quotation is the result of one ablation. It shuffled the task trajectories across repositories and kept everything else.

**Proposed change.** Sketch for the workflow row at `skills/improve/SKILL.md:45`:

```text
| workflow | Tasks in one repo: a rule in that repo's `AGENTS.md` or its overlay. Tasks in two repos: an edit to the cooking text | the same tag in two tasks |
```

**Check.**

```text
| improve-scope | improve | Two workflow observations share a tag and a repo | Proposes a change to that repo or its overlay, and none to `skills/` |
```

A behaviour case can assert this on files. With approval given in the prompt, `skills/` stays unchanged and a file in the fixture repo or in `overlays/` changes.

### S8. Record the phase, an absolute path, and the decisive line

**Grade.** Observed in the text.

**Gap.** An observation line has no field for the phase where the cause happened, so improve must guess which phase file to edit. The format does not require an absolute path. Improve runs across repos and cannot open a relative path from another repo. The evidence file lives in untracked task state and can be gone when improve runs.

**Skill evidence.**

> `skills/cooking/phases/review.md:56` "`<date> | <repo> | <slug> | <category> | <tag> | <event> | <file> | open`"

> `skills/improve/SKILL.md:36` "Read the file of each observation when it still exists."

> `skills/cooking/SKILL.md:11` "Give workers absolute paths to it."

The test fixtures already hold both forms.

> `tests/behaviour/cases/improve-threshold/setup.sh:3` ".jstack/add-export/brief.md | open"

> `tests/behaviour/cases/applied-names-change/setup.sh:9` "$REPO/.jstack/add-export/evidence/nav.txt | open"

**Paper evidence.**

> [2611.02839, "Abstract"] "Attribution separates model errors from defects in Skills, tools, or the harness, routing component failures to repair."

> [2611.02839, "1 Introduction"] "model-attributable failures are cut at the first erroneous decision and repaired"

> [2608.01679, "Abstract"] "consolidation preserves a claim while erasing the source constraints governing its authorized use"

> [2608.01679, "Abstract"] "automatically predicted and persisted authority labels reduce the observed unauthorized-action rate from 16.9% to 0.0%"

In AuthMem-Bench (P04), a writing instruction that keeps the source cut wrongly upgraded memories from 55.8% to 9.9% (Table 3 in section 4.2). MemScope (P11) scored 86.67% with raw traces and memory against 63.33% with summaries only (abstract).

**Proposed change.** Sketch for `skills/cooking/phases/review.md:56` and the text under it:

```text
<date> | <repo> | <slug> | <phase> | <category> | <tag> | <event> | <file> | open

`<phase>` is the phase where the earliest cause happened. `<file>` is an absolute path. `<event>` quotes the line that shows it.
```

This is the widest change in the report. It alters a line format that improve reads, and the fixtures of at least five behaviour cases hold that format. A smaller first step is the absolute path alone, which changes no format.

**Check.**

```text
| review-absolute-file | cooking | Review writes an observation | Its file is an absolute path that exists |
```

A behaviour case can assert this on the log line.

### S9. Record what each task cost

**Grade.** The gap is observed in the text. The benefit is inferred.

**Gap.** No file records cost. The `over` verdict rests on five yes-or-no items. Improve's own checking grows with each change, because every applied change adds a scenario and the judge reads every scenario.

**Skill evidence.**

> `skills/cooking/SKILL.md:41` "`size: <size>, <five answers>`"

The ledger template is `skills/cooking/SKILL.md:37-50`. It has no cost line.

> `skills/cooking/phases/review.md:33` "**Over** if every item that applies is true; a trivial task is never over:"

> `skills/cooking/phases/review.md:39` "- independent tasting found nothing beyond the builder's checks."

> `README.md:15` "It runs each case three times on both main-agent models and spends model tokens"

**Paper evidence.**

> [2611.13524, "Abstract"] "A substantial share of the RSI Tax is also associated with states or artifacts that are not used later in the evaluated streams."

> [2611.13524, "4 Simple Reflection with Notes (SRN)"] "The note is limited to 2,048 tokens."

> [2611.13524, "Sources of the RSI Tax"] "EvoSkill spends 497.45M tokens refreshing its old frontier, compared with 182.26M on the 89 arriving tasks."

In The RSI Tax (P17), a baseline with one bounded note matched or beat three heavier methods and used 65.6 to 71.0% fewer tokens in total. Verification was 74.8 to 93.6% of the cost of self-improvement for those three methods. Both numbers are in the abstract.

**Proposed change.** Sketch for the ledger template and the sizing line:

```text
workers: <phase>=<count>, ...

<date> | <repo> | <slug> | predicted=<size> | verdict=<right|under|over> | missed=<signal|none> | workers=<count>
```

Improve's last message also states how many judge runs and behaviour-test runs it started. The sketch counts workers because the review did not check whether the skill can read token totals.

**Check.**

```text
| ledger-workers | cooking | Saute starts two builders | The ledger's workers line reads `saute=2` |
```

The worker stub fails every start, so only the judge's read covers this row.

## Items to watch

Build nothing for these yet. Each names the event that should start the work. The two size limits, 50 lines and 40 rows, are the reviewer's judgement. No paper sets them.

### W1. Tags split and the log grows

**Grade.** Inferred. The log does not exist yet on the reviewed machine.

**Evidence.** Grouping depends on review choosing the same tag for the same failure.

> `skills/cooking/phases/review.md:11` "Reuse a tag from `review-log.md` when one fits."

The test fixtures already hold two tags for one failure, a recipe gate that was skipped.

> `tests/behaviour/cases/improve-drift/setup.sh:4` "recipe-gate-skipped"

> `tests/behaviour/cases/review-prompts-improve/setup.sh:5` "recipe-gate-unclear"

`review-log.md` has no size limit and no archive step. Review reads it at every task to reuse tags.

**Paper evidence.**

> [2611.00544, "1 Introduction"] "62 of the 115 queries that were routed correctly when their required skills first became available fail once the library reaches 731 skills"

> [2611.11509, "3.3 Working Memory via Trajectory Reflection"] "so the MLLM itself decides what the bounded memory keeps"

SimplEvo (P02) rewrites its whole memory within a budget of 32 KB after each episode. Skill++ (P15) shows that near-duplicate names break selection as a library grows.

**Act when.** The log passes 50 lines. Then merge tags that name one failure in step 2 of improve, and archive `applied` and `rejected` lines. Keep one line per applied tag, because recurrence needs it (`skills/improve/SKILL.md:32`).

### W2. The scenario list grows, and half of it never runs

**Grade.** Observed for the counts. Inferred for the cost.

**Evidence.** The judge reads every scenario at each change (`skills/improve/SKILL.md:59`), and each applied change adds one (`skills/improve/SKILL.md:63`).

13 of the 26 scenarios have a behaviour case. Four cases use another name than their scenario: `gate-approve` covers `gate`, `gate-correct` covers `gate-correction`, `applied-names-change` covers `improve-applied-file`, and `upstream-no-approval` covers `improve-upstream-gate`. These 13 scenarios have no case:

`new-task`, `size-trivial`, `reopen`, `deviation`, `second-failure`, `destructive`, `not-run`, `review-only`, `overlay-missing`, `idea-frontier`, `improve-recurrence`, `improve-reported`, `improve-upstream-skip`.

The saute and taste scenarios are among them, and the tests stub every worker.

> `tests/behaviour/run.sh:36` "# Workers are out of scope: a stub records each attempt to start one."

**Paper evidence.**

> [2611.13524, "Sources of the RSI Tax"] "EvoSkill spends 497.45M tokens refreshing its old frontier, compared with 182.26M on the 89 arriving tasks."

> [2611.07624, "4.3 Reliability and Deployment Efficiency"] "Eight of eleven reliability-improving Champions cost more per trial than Seed"

**Act when.** The list passes 40 rows. Then merge rows that test one rule.

### W3. The tests run on other models than the session

**Grade.** Observed for one session. Which model normally drives cooking was not checked.

**Evidence.**

> `tests/behaviour/run.sh:14` "MODELS="${MODELS:-openai-codex/gpt-6.1-sol:medium anthropic/claude-opus-5-5:medium}""

The review session ran `claude-fable-5-2` as the main agent. That model is the judge and sketcher A in `skills/cooking/models.md`, and it is not in the default test list.

**Paper evidence.**

> [2608.15071, "4.5 Transfer and Adaptability (RQ3)"] "Thus, Sonnet-evolved skills can help Opus, but do not necessarily help Sonnet itself."

> [2611.08946, "5.4 Does editing the harness help?"] "A harness built by a stronger model thus raised the score of the weaker model on two of the four tasks"

**Act when.** You confirm which model drives cooking. Then align the default in `tests/behaviour/run.sh:14`.

### W4. A decision record becomes a standing rule with no source

**Grade.** Inferred.

**Evidence.** The recipe must follow every decision record. Idea asks about a conflict with a term, but not about a conflict with a decision record. The record has no required date or source, and `.jstack/` has no Git history.

> `skills/cooking/phases/recipe.md:54` "Use the terms in `.jstack/glossary.md` and keep to the decisions in `.jstack/adr/`."

> `skills/idea/SKILL.md:26` "When a term conflicts with `.jstack/glossary.md` or with the code, ask which meaning is right."

> `skills/idea/SKILL.md:31` "Record a decision in `.jstack/adr/<nnnn>-<name>.md` only when all three hold"

**Paper evidence.**

> [2608.01679, "Abstract"] "consolidation preserves a claim while erasing the source constraints governing its authorized use"

> [2610.12789, "Abstract"] "Counterexamples narrow or retire rules as the environment changes."

**Act when.** A brief first conflicts with a decision record. Then make idea ask about that conflict as it does for a term, and make each record state its date, its task, and that the user decided it at the brief gate.

## Limits of this review

- No cooking task ran. Every statement about what an agent does with the text is inferred, except where a behaviour case already asserts it.
- The review ran no behaviour test, because each case spends model tokens.
- F1 and F2 describe one machine. Run the commands in Appendix C on each other machine.
- The review did not read `skills/writing-for-agents/SKILL-MECHANICS.md`. The sketches are not checked against it.
- The paper results come from benchmarks for web agents, robots, coding agents, and memory systems. None measures a workflow like cooking. Each mapping from a paper to a suggestion is the reviewer's judgement.
- The mapping of each paper to a "practice" is also the reviewer's. The papers do not use those names.

## Appendix A. The 23 practices and their paper evidence

Each row gives the practice, what to do, and the passage that supports it.

### Start cheap

| # | Practice | Do this | Paper evidence |
|---|---|---|---|
| 1 | Keep one bounded note | Keep one note with a size limit. Rewrite it from failed tasks. | P17, section 4: "The note is limited to 2,048 tokens." Section 2.3: the methods "update every four completed tasks". P02, section 3.3: a full rewrite within a budget of 32 KB. |
| 2 | Improve only on a trigger | Start a repair when accuracy drops or progress stalls. | P11, section 3.2: a patch round starts only when accuracy falls more than δ = 0.05 and at least one task fails. P19, abstract: monitors start deliberation "when they detect anomalies, degradation, or stagnation". |
| 3 | Use real feedback only | Learn from test results, user corrections, or inspected artifacts. | P13, section 4.6: "Self-Generated feedback underperforms No-Evolve on both benchmarks, decreasing CL-Bench from 29.54 to 27.96 and SWE-bench Lite from 63.67 to 61.67". |
| 4 | Count the cost | Record what improvement costs next to what the tasks cost. | P17, abstract: verification is 74.8 to 93.6% of the cost of self-improvement. A bounded note used 65.6 to 71.0% fewer tokens in total. |

### Write a lesson so that it can fail

| # | Practice | Do this | Paper evidence |
|---|---|---|---|
| 5 | Write four fields per lesson | Write the trigger, the behaviour change, the expected effect, and the evidence. | P01, section 4.1: each hypothesis "specifies its precondition, behavior change, expected effect, and verifier". P13, section "Execution reflection": a memory is (lesson, trigger, evidence, scope hint). |
| 6 | Wait for a second case | Promote a lesson after it holds in two separate tasks. | P03, section "Commitment thresholds": "at least two distinct bindings in at least two distinct episodes". P14, abstract: task evidence, then repository candidates, then cross-repository skills. |
| 7 | Narrow before you drop | Tighten the trigger once. If the lesson fails again, delete it. | P01, section 4.1: "Hypotheses with localized failures are refined once through precondition narrowing and reevaluated; hypotheses that still fail are rejected." |
| 8 | Keep the source | Store who said each fact. | P04, abstract: unauthorized actions fell "from 16.9% to 0.0%" with stored authority labels. Authority collapse appeared in 48 of 49 configurations. |
| 9 | Keep recovery lessons | Save how to recover from a common failure. | P14, section 5.3: without the two recovery skills, HSE is "only 0.3 points above No Skills with Pi and 2.1 points above it with CC" on DeepSWE. |

### Accept a change only with proof

| # | Practice | Do this | Paper evidence |
|---|---|---|---|
| 10 | Test what passed before | Run the old passing tasks again. Count the lost tasks. | P20, abstract: "All sixteen evolved agents gain previously uncovered tasks while losing previously covered ones." P01, section "Single-factor ablation": the regression archive cuts regression damage from 5.2% to 1.3%. |
| 11 | Beat the noise | Accept only a gain larger than the variation between runs. | P09, section 3.2: the margin is "twice the standard deviation of the starter's validation score". P10, abstract: a greedy gate accepted 45.59% inferior updates. |
| 12 | Hide the checker | Give the agent the instruction, not the test code. | P08, figure caption before section 1: 51.6% against 27.8% with the checker visible, and 45.0% against 47.2% under criteria that follow the instruction. |
| 13 | Check the end state | Verify what exists after the run. | P05, section "Evidence header (E)": "Every check must rest on evidence in the list." P06, results table in section 5: 37.0 with active verification, 34.3 without. |
| 14 | Test the verifier | Run the verifier on a result that is known to be wrong. | P05, section "Probe and one repair": a verifier that accepts "the task's initial state before any work is done" is regenerated. |

### Patch small, from raw evidence

| # | Practice | Do this | Paper evidence |
|---|---|---|---|
| 15 | Read the raw trace | Diagnose from the trace and the stored memory. | P11, abstract: 86.67% with trace and memory, 70.00% with the trace only, 63.33% with a summary only. |
| 16 | Find the first wrong step | Stop at the first wrong decision. | P18, section 1: failures "are cut at the first erroneous decision and repaired". P18, abstract: the bad-case rate fell from 6.42% to 1.97%. |
| 17 | Name the faulty part | Decide whether the model, the skill, the tool, or the harness failed. | P18, abstract: "Attribution separates model errors from defects in Skills, tools, or the harness, routing component failures to repair." |
| 18 | Make exact small edits | Change the lines that failed. | P11, abstract: "the median code-change ratio is 4.4%". |
| 19 | Use a second-model critic | Let another model family review each change. | P12, section "Proposer, critic and evaluator": "the proposer and the critic come from different model families". |

### Describe and load skills

| # | Practice | Do this | Paper evidence |
|---|---|---|---|
| 20 | Write a three-part description | State what the skill covers, how it differs from its nearest skill, and what it excludes. | P15, abstract: "The new description states what the body supports, how the skill differs from its closest predecessor, and what related work it excludes." Correct selection rose from 36.4% to 76.3%. |
| 21 | Check neighbours on each add | Test that the older similar skill still loads. | P15, section 1: "62 of the 115 queries" that were once routed correctly fail at 731 skills. |
| 22 | Load few skills | Load about three skills for a step. | P16, "Obs. 5": "Under a fixed budget, injecting three skills outperforms injecting one or five". |
| 23 | Choose skills during the task | Select skills again when the task state changes. | P16, "Obs. 3": "fixing the initial skill set causes the largest decline: 8.9 TGC points on AppWorld and 10.7 SR points on ALFWorld". |

## Appendix B. The 20 papers

The number and the name in the first two columns come from the source list. The core idea is taken from each abstract. Code links returned HTTP 200 on 2026-11-18, except where the table says otherwise.

| # | Name in the list | Paper | arXiv | Core idea |
|---|---|---|---|---|
| P01 | lesson-as-hypothesis | When Should Agents Remember? Falsification-Gated Self-Evolution for LLM Agents (FGSE) | [2611.14326](https://arxiv.org/abs/2611.14326) | Test each lesson as a hypothesis in a temporary state, then commit, refine, or reject it. |
| P02 | refine-after-episode | Review the Episodes, Refine the Lessons: Simple Memory Evolution for Embodied Agents (SimplEvo) | [2611.11509](https://arxiv.org/abs/2611.11509) | Rewrite one bounded text memory after each training episode, then freeze it. |
| P03 | falsifiable-rules | EvoBelief: Falsifiable World Models for Self-Improving LLM Agents | [2610.12789](https://arxiv.org/abs/2610.12789) | Hold beliefs about the environment as falsifiable rules that need independent validation. |
| P04 | tag-memory-source | When Memory Becomes Authority: Benchmarking Authority Collapse at the Memory Consolidation Boundary (AuthMem-Bench) | [2608.01679](https://arxiv.org/abs/2608.01679) | Memory consolidation keeps a claim and drops who may act on it. Stored authority labels prevent that. |
| P05 | write-own-verifier | Veritas: A Verifier Generation Harness for Agent Tasks | [2611.13336](https://arxiv.org/abs/2611.13336) | Generate verifiers from an evidence header, a library of domain rules, and authoring principles. |
| P06 | inspect-dont-trust | Verify by Doing: Co-Evolving Agent Execution and Evaluation without External Feedback (VbD) | [2611.15276](https://arxiv.org/abs/2611.15276) | An evaluator inspects artifacts with tools, and both the actor and the evaluator evolve. |
| P07 | replay-check | Memento 3: Model-Based Recursive Self-Improvement through Reflective Rulebooks | [2610.11794](https://arxiv.org/abs/2610.11794) | Compile a written rulebook into code, and accept an update only when replay reproduces what was observed. |
| P08 | check-the-instruction | Learning the Task or Learning the Verifier? Rethinking Criteria Exposure in Embodied Self-Improvement | [2611.08318](https://arxiv.org/abs/2611.08318) | An agent that sees the success criteria fits them. The gain disappears when the criteria change slightly. |
| P09 | holdout-gate | Flex-RSI: Benchmarking Recursive Self-Improvement of Frontier Agents | [2611.08946](https://arxiv.org/abs/2611.08946) | Keep a solution only if it scores higher on held-out validation data. Score the final on hidden test data. |
| P10 | stat-test-gate | Trustworthy Recursive Self-Improvement with Statistical Guarantees (TRUST) | [2611.10787](https://arxiv.org/abs/2611.10787) | Gate each update with an online statistical test in place of "higher score wins". |
| P11 | small-patch-only | MemScope: Evolving Agent Memory Architectures through Localized Code Repair | [2610.21170](https://arxiv.org/abs/2610.21170) | Read raw traces, memory state, and code to find the failure, then make bounded edits in place. |
| P12 | cross-model-critic | Reglos: A Self-Evolving Personal Memory Agent with Recursive Self-Improvement | [2611.06049](https://arxiv.org/abs/2611.06049) | A critic from a second model family screens each patch for benchmark gaming. |
| P13 | run-to-skill | Evo-Harness: Context-to-Harness Skill Compilation for Self-Evolving Agents | [2608.15071](https://arxiv.org/abs/2608.15071) | Turn one noisy run into reusable skills, and study which kind of feedback makes that work. |
| P14 | skill-ladder | Hierarchical Skill Evolution for Coding Agent (HSE) | [2610.35616](https://arxiv.org/abs/2610.35616) | Promote evidence from the task to the repository to all repositories, so only recurring patterns become skills. |
| P15 | distinct-skill-desc | Skill++: Towards Lifelong Agents via Routing-Aware Skill Refinement | [2611.00544](https://arxiv.org/abs/2611.00544) | Rewrite the name and description of each new skill so it stays distinct from its neighbours. |
| P16 | just-in-time-skill | Just-in-Time Skill Retrieval via Long-Horizon State Tracking (JitSkill) | [2611.01701](https://arxiv.org/abs/2611.01701) | Select skills during the task from a tracked task state, not once at the start. |
| P17 | rsi-tax-meter | The RSI Tax: When Recursive Self-Improvement Is Not Worth the Cost | [2611.13524](https://arxiv.org/abs/2611.13524) | Count the tokens that self-improvement costs. A bounded note matched three heavier methods. |
| P18 | first-error-blame | CARE: Grounded Recursive Self-Improvement for Production Customer-Service Agents | [2611.02839](https://arxiv.org/abs/2611.02839) | Attribute each failure to a component, cut the run at the first wrong decision, and learn from the repair. |
| P19 | stall-trigger | AutoRL: A Multi-Agent System towards Autonomous Reinforcement Learning | [2611.17790](https://arxiv.org/abs/2611.17790) | Monitors start a review of a training run only on an anomaly, a decline, or a stall. |
| P20 | regression-audit | Beneath the Surface: What We Overlook When We Talk About Agent Evolution | [2611.07624](https://arxiv.org/abs/2611.07624) | Every evolved agent gained some tasks and lost others. Score what an update preserves. |

Papers P04 and P13 were read at version 2. The other papers were read at version 1.

Code links:

| # | Link | State on 2026-11-18 |
|---|---|---|
| P08 | <https://github.com/DAGroup-PKU/PyRUA-Lean/tree/RSIJudge> | Resolves. An earlier search of the abstract and the project page found the link. The reviewer's search of the full text did not. |
| P09 | <https://github.com/flex-rsi/rsi-bench> | Resolves. Same note as P08. |
| P13 | <https://github.com/A-EVO-Lab/a-evolve/tree/release/evo-harness> | Resolves. The abstract names it. |
| P14 | <https://github.com/jungao1106/SKILL_EVO> | Returns 404. The paper names it. |
| P16 | <https://github.com/XMUDeepLIT/JitSkill> | Resolves. The abstract names it. |
| P20 | <https://github.com/simple-agent-lab/RSIHub> | Resolves. The paper names it. |

For the other 14 papers, an earlier search of each abstract, full text, and project page found no public code. That search did not look on GitHub by title.

To fetch a paper, use `https://export.arxiv.org/api/query?id_list=<id>` for the abstract and `https://arxiv.org/html/<id>` for the full text.

## Appendix C. Commands

Run each command from the repo root unless it says otherwise.

Counts in this report:

```bash
grep -c '^| [a-z]' SCENARIOS.md      # 27: the header row and 26 scenarios
ls tests/behaviour/cases | wc -l     # 13
grep -rn "tests/behaviour" skills/   # no output
```

Recheck F1 on any machine. The command prints one line for each installed cooking skill:

```bash
for d in ~/.agents/skills ~/.claude/skills; do
	for l in "$d"/*cooking*; do
		[ -e "$l" ] || continue
		r="$(cd "$l" && pwd -P)"
		if [ -d "$r/../../overlays" ]; then echo "$r: overlays found"; else echo "$r: no overlays"; fi
	done
done
```

Recheck F2 on any machine:

```bash
t="$(mktemp -d)" && git -C "$t" init -q
if git -C "$t" check-ignore -q .jstack/x; then echo ignored; else echo "not ignored"; fi
rm -rf "$t"
```

The test of fix option 2 for F1. It prints `?? overlays`, which shows that the pattern does not cover a link:

```bash
t="$(mktemp -d)" && git -C "$t" init -q && printf '/overlays/\n' > "$t/.gitignore"
mkdir "$t/real" && ln -s "$t/real" "$t/overlays"
git -C "$t" status --porcelain --untracked-files=all
rm -rf "$t"
```

The quotation check is a script that is not in this repo, because it needs the paper texts. It reads each blockquote line of this report, opens the cited file, and tests that the quoted words are on the cited line. For a paper, it tests that the quoted words are in the full text. It ignores whitespace, backticks, and quote style. On the review date it matched 99 quotations in blockquotes and 29 in Appendix A, with no mismatch. It also confirmed that every cited `path:line` exists.
