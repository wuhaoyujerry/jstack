---
name: tasty
description: "Turn the observations of cheese reviews into workflow improvements. Invoke /tasty."
disable-model-invocation: true
metadata:
  author: Jerry Wu
---

# Tasty

Turn the `open` observations of cheese reviews into changes that improve the next run.

Resolve symlinks to find this skill's real directory. The logs are `review-log.md` and `sizing-log.md` in `../../overlays/` relative to it; `../cheese/` is the cheese skill. If the ask reports the outcome of a task, first record it by step 5 of `../cheese/phases/review.md`.

## 1. Group

Read both logs. Group the `open` observations by tag, across tasks and repos. Group the `sizing-log.md` lines by missed signal and verdict.

## 2. Choose

A group becomes a candidate **change** when it has the observations its category needs. Read the file of each observation when it still exists.

| Category | Change | Needs |
|---|---|---|
| navigation | A pointer at the place the agent looked first | one observation |
| check | Wire the check, or add it | one observation |
| steering | Move the rule into a check, or delete the text | one observation |
| tool | Write the cheaper form where the agent reads it | one observation |
| access | Give the agent that access | one observation |
| workflow | An edit to the cheese text | the same tag twice |
| sizing | A change to the signal in `../cheese/phases/size.md` | the same signal missed twice with the same verdict |
| lesson | A project fact goes to that project's ai-memory, in an existing page where one fits. A lesson that transfers becomes a candidate for the personal-knowledge review. | one observation |

Prefer an automated check to a verify recipe, and a verify recipe to cheese text. A mechanical rule becomes a check; only a judgement call becomes written guidance.

Propose at most three changes, most severe first. Zero changes is a valid result.

## 3. Approve and apply

The user approves each change, one at a time through the question tool. Apply each approved change.

In `review-log.md`, replace `open` on every observation of a proposed group with `applied <date>` or `rejected <date>`. The other observations stay `open`.

Tell the user what changed and how many observations remain `open`.
