# Review

Record what this run showed, for the `tasty` skill to act on later. Ask the user nothing. Change only the two logs and the ledger.

Read the ledger, `verify.md` and the evidence folder.

## 1. Observations

An **observation** is one event from this run and the file that shows it: an evidence file or the ledger. No file, no observation. Zero observations is a valid result.

Give each observation a category and a short **tag** that names the failure. Reuse a tag from `review-log.md` when one fits.

| Category | Event |
|---|---|
| navigation | A fact took long to find. |
| check | An automated check would have caught a mistake, exists but is unwired, or the repo has no guardrail. |
| steering | Text in `AGENTS.md` stated a mechanical rule, or changed no behaviour. |
| tool | An expensive call has a cheaper form. |
| access | The agent could not reach a fact. |
| workflow | A cheese step was missing, unclear or wasted. |
| lesson | A fact about this project, or a lesson that transfers, that is not obvious. |

## 2. Sizing verdict

**Under** if any is true:

- the size was raised during build;
- a unit failed twice;
- verify returned work to build;
- a decision appeared after a gate;
- the task was reopened.

**Over** if every item that applies is true; a trivial task is never over:

- the user accepted every grill recommendation;
- the spec had one unit;
- the two sketches matched;
- a research note went unused;
- independent verify found nothing beyond the builder's checks.

Otherwise **right**. Name the signal that missed.

## 3. Write the logs

Both logs are in the private overlay directory defined in `SKILL.md`. Create the directory and the logs if missing; never write a log into the synced skill.

Write one line for the task to `sizing-log.md`, replacing its earlier line if the task was reopened:

```text
<date> | <repo> | <slug> | predicted=<size> | verdict=<right|under|over> | missed=<signal|none>
```

Append one line per observation to `review-log.md`:

```text
<date> | <repo> | <slug> | <category> | <tag> | <event> | <file> | open
```

## 4. Close

Set the ledger phase to `done`. Tell the user in one line: the number of `open` observations in `review-log.md`, and each tag or missed signal that now appears twice.

## 5. Outcome

The user may later report what happened to a `done` task: a deploy, a code review, a defect. Append the report as an observation, with the user's words as its file. If it shows the size was too small, set `verdict=under` in the task's `sizing-log.md` line. Then give the line of step 4.
