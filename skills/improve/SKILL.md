---
name: improve
description: "Turn cooking review observations and upstream source changes into workflow improvements. Invoke /improve."
disable-model-invocation: true
metadata:
  author: Jerry Wu
---

# Improve

Turn the `open` observations of cooking reviews, and upstream changes to the skills jstack draws from, into changes that improve the next run.

Resolve symlinks to find this skill's real directory. The logs are `review-log.md` and `sizing-log.md` in `../../overlays/` relative to it; `../cooking/` is the cooking skill; `../../SOURCES.md` records the sources.

The Git working tree that holds that directory is this skill's **home**; every step runs in a session there. You are in the home when `git rev-parse --show-toplevel` prints the same path here as in that directory. Outside the home, hand off the ask to the home, with this file's path to follow and your working directory, then end your turn. To **hand off** is to start a session in the named repo with the prompt, through the tool this session has for that; with none, or when the launch fails, give the user the prompt to paste.

If the ask reports the outcome of a task, first record it by step 5 of `../cooking/phases/review.md`. If the ask reports a problem from a run outside a cooking task, such as a standalone idea or research run, first append it to `review-log.md` as one observation in the format of `../cooking/phases/review.md`: `-` for an unknown repo or slug, and the user's words as its file.

## 1. Upstream

Run this step when the ask is about upstream or source changes, such as "check pstack for updates". Otherwise go to step 2.

Check the collections the ask names, or every collection in the `SOURCES.md` collection table when it names none. For each collection, read its upstream and commit, and every row whose source skill is from it; skip rows that copied nothing. Clone the upstream into a temporary directory. Find each named skill by the `name:` in its `SKILL.md`, then diff its folder from the recorded commit to `HEAD`. A playbook names the skill that holds it.

Each change in the diff is an **upstream change**: a candidate for step 3. This step edits no file.

- For a copy (`../writing-for-agents/`, `../technical-writing/`, `../unslop/`): the candidate replaces each kept file with its upstream version. It keeps `LICENSE` and adds a new upstream file only if the skill reads it.
- For an adapted skill: a change to a mechanism the row lists as Kept, or a new mechanism, can change the jstack file of that row. A change only to a Dropped mechanism needs nothing.

The upstream step is done when every named skill has a diff and every upstream change has a line in your notes.

## 2. Group

Read both logs. Where an observation reads `handed <date> <file>` and that file now holds its change, replace `handed` with `applied`. First give `open` observations whose events show one failure one tag, and rewrite it on those lines in `review-log.md`: a **merge**. Keep the tag that an `applied` observation of that failure has, else the tag of the earliest line. Then group the `open` observations by tag, across tasks and repos. Group the unspent `sizing-log.md` lines by missed signal and verdict; step 3 of `../cooking/phases/review.md` defines **spent**.

An `open` observation whose tag also has an `applied` observation from an earlier date is a **recurrence**: the earlier change did not hold. Read the file its `applied` entry names before you propose another.

## 3. Choose

A group becomes a candidate **change** when it has the observations its category needs. Read the file of each observation when it still exists.

| Category | Change | Needs |
|---|---|---|
| navigation | A pointer at the place the agent looked first | one observation |
| check | Wire the check, or add it | one observation |
| steering | Move the rule into a check, or delete the text | one observation |
| tool | Write the cheaper form where the agent reads it | one observation |
| access | Give the agent that access | one observation |
| workflow | Tasks in two repos: an edit to the cooking text. Tasks in one repo: a rule limited to that repo, in an **overlay** that applies to it (`../cooking/SKILL.md`, step 1); with none, in its `AGENTS.md` | the same tag in two tasks |
| sizing | A change to the signal in `../cooking/phases/size.md` | the same signal missed twice with the same verdict |
| upstream | Copy the upstream folder, or edit the jstack file of the row | one upstream change |
| recurrence | Revise or replace the earlier change | one observation |
| lesson | A project fact goes to that project's ai-memory, in an existing page where one fits. A lesson that transfers becomes a candidate for the personal-knowledge review. | one observation |

Prefer an automated check to a drive script, and a drive script to cooking text. A mechanical rule becomes a check; only a judgement call becomes written guidance.

Before a `workflow` or `steering` change, search the skill text for a rule that already covers the tag. A hit makes the group **drift**: the rule exists and did not hold. A drift change takes the place of the row's change, for tasks in one repo too: it strengthens that rule where it stands, or moves it into a check; the text keeps one rule for it. Name the group `drift`, with the rule's file, when you propose it and in your last message.

Propose at most three changes, recurrences first, then most severe. Zero changes is a valid result.

## 4. Approve and apply

Before you propose changes that edit a file in `skills/`, check them against `../../SCENARIOS.md`. For each change that came from observations, first write its **candidate scenario**: one row that would have caught them, generic as that file requires. Start one fresh read-only `judge` worker for the whole run, as `../cooking/models.md` describes. Give it the scenario file, the files the changes touch and every proposed change. Put each candidate scenario in the judge's spec; it enters `SCENARIOS.md` only when its change is applied. The judge walks every scenario, the candidates included, through the text before and after each change alone, and reports each scenario whose result changes and each pair of changes that conflict. The check is done when every scenario has a verdict for every change: `same`, `fixed` or `broken`.

A candidate scenario must be `fixed` for its own change. On `same` the edit does not address its observations: revise the edit and send it to the same judge, or drop the change and leave its observations `open`.

The user approves each change, one at a time through the question tool, with its `broken` scenarios shown. A sizing change also shows the count of each verdict among the lines unspent for its signal. For a `broken` scenario the user chooses: revise the change, or accept it and update that scenario, with its behaviour case where one exists.

Apply each approved change by the file it edits:

- **A file in `skills/`.** **Prove** the change with `../../tests/behaviour/run.sh <case>`, which runs one behaviour case from the `cases/` folder beside it. Before you edit, write a case for the change's candidate scenario and run it with `RUNS=1`: it must fail on its assertion, on one model or both; if it passes, it shows nothing, so sharpen it. Then edit the file and run that case, and the case of each scenario the judge marked `fixed` or `broken` for the change, where one exists: each must pass. If one fails, show the user the run and ask: revise the change, or revert it. A change without a candidate scenario, or with one whose result no file can show, gets no new case.
- **A file in another repo.** A session there applies it: hand off the change, with the files of its observations, to that repo.
- **Any other file.** Edit it.

For each applied change that came from observations, add its candidate scenario to `SCENARIOS.md`; write one now for a change that had none.

In `review-log.md`, replace `open` on every observation of a proposed group with `applied <date> <file>`, naming the file the change edited; with `handed <date> <file>` for a change you handed off, by a session you started or by a prompt you gave the user, naming the file it is to edit; or with `rejected <date>`. The other observations stay `open`. In `sizing-log.md`, append a marker (step 3 of `../cooking/phases/review.md`) for the signal of each sizing change the user decided.

For each collection checked, when the user has decided its every upstream change, set its commit in `SOURCES.md` to the `HEAD` you diffed. If any of its upstream changes is still undecided, keep the old commit so the next run sees it again.

Tell the user what changed, the result of each case you ran and each candidate scenario without a case, each merge with the tags it replaced, each `drift` group, and how many observations remain `open`; after step 1, also how many upstream changes remain undecided.
