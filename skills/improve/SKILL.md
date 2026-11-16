---
name: improve
description: "Turn cooking review observations and upstream source changes into workflow improvements. Invoke /improve."
disable-model-invocation: true
metadata:
  author: Jerry Wu
---

# Improve

Turn the `open` observations of cooking reviews, and upstream changes to the skills jstack draws from, into changes that improve the next run.

Resolve symlinks to find this skill's real directory. The logs are `review-log.md` and `sizing-log.md` in `../../overlays/` relative to it; `../cooking/` is the cooking skill; `../../SOURCES.md` records the sources. If the ask reports the outcome of a task, first record it by step 5 of `../cooking/phases/review.md`. If the ask reports a problem from a run outside a cooking task, such as a standalone idea or research run, first append it to `review-log.md` as one observation in the format of `../cooking/phases/review.md`: `-` for an unknown repo or slug, and the user's words as its file.

## 1. Upstream

Run this step when the ask is about upstream or source changes, such as "check pstack for updates". Otherwise go to step 2.

Check the collections the ask names, or every collection in the `SOURCES.md` collection table when it names none. For each collection, read its upstream and commit, and every row whose source skill is from it; skip rows that copied nothing. Clone the upstream into a temporary directory. Find each named skill by the `name:` in its `SKILL.md`, then diff its folder from the recorded commit to `HEAD`. A playbook names the skill that holds it.

Each change in the diff is an **upstream change**: a candidate for step 3. This step edits no file.

- For a copy (`../writing-for-agents/`, `../technical-writing/`, `../unslop/`): the candidate replaces each kept file with its upstream version. It keeps `LICENSE` and adds a new upstream file only if the skill reads it.
- For an adapted skill: a change to a mechanism the row lists as Kept, or a new mechanism, can change the jstack file of that row. A change only to a Dropped mechanism needs nothing.

The upstream step is done when every named skill has a diff and every upstream change has a line in your notes.

## 2. Group

Read both logs. Group the `open` observations by tag, across tasks and repos. Group the `sizing-log.md` lines by missed signal and verdict.

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
| workflow | An edit to the cooking text | the same tag in two tasks |
| sizing | A change to the signal in `../cooking/phases/size.md` | the same signal missed twice with the same verdict |
| upstream | Copy the upstream folder, or edit the jstack file of the row | one upstream change |
| recurrence | Revise or replace the earlier change | one observation |
| lesson | A project fact goes to that project's ai-memory, in an existing page where one fits. A lesson that transfers becomes a candidate for the personal-knowledge review. | one observation |

Prefer an automated check to a drive script, and a drive script to cooking text. A mechanical rule becomes a check; only a judgement call becomes written guidance.

Before a `workflow` or `steering` change, search the skill text for a rule that already covers the tag. A hit makes the group **drift**: the rule exists and did not hold. A drift change strengthens that rule where it stands, or moves it into a check; the text keeps one rule for it. Name the group `drift`, with the rule's file, when you propose it and in your last message.

Propose at most three changes, recurrences first, then most severe. Zero changes is a valid result.

## 4. Approve and apply

Before you propose a change that edits a file in `skills/`, check it against `../../SCENARIOS.md`. Start one fresh read-only `judge` worker as `../cooking/models.md` describes. Give it the scenario file, the files the change touches and the proposed edit. It walks every scenario through the text before and after the edit, and reports each scenario whose result changes. The check is done when every scenario has a verdict: `same`, `fixed` or `broken`.

The user approves each change, one at a time through the question tool, with its `broken` scenarios shown. For a `broken` scenario the user chooses: revise the change, or accept it and update that scenario. Apply each approved change.

For each applied change that came from observations, add one scenario to `SCENARIOS.md` that would have caught them. Write it generic, as that file requires.

In `review-log.md`, replace `open` on every observation of a proposed group with `applied <date> <file>`, naming the file the change edited, or `rejected <date>`. The other observations stay `open`.

For each collection checked, when the user has decided its every upstream change, set its commit in `SOURCES.md` to the `HEAD` you diffed. If any of its upstream changes is still undecided, keep the old commit so the next run sees it again.

Tell the user what changed, each `drift` group, and how many observations remain `open`; after step 1, also how many upstream changes remain undecided.
