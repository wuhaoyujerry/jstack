# Retro

Improve the next run. Read the ledger, `verify.md` and the evidence folder. ai-memory keeps the session history, so write no summary.

The user approves every item, one at a time through the question tool. Zero items is a valid result.

## 1. Environment

- **Navigation**: a fact took long to find. Add a pointer.
- **Automated checks**: a check would have caught a mistake, exists but is unwired, or the repo has no guardrail.
- **Standards**: a mechanical rule becomes a check; only a judgement call becomes written guidance.
- **Steering files**: text in `AGENTS.md` that belongs in a check, or changes no behaviour.
- **Tool economy**: an expensive call that has a cheaper form.
- **Information access**: a fact the agent could not reach.

## 2. Workflow

Look for a jstack step that was missing, unclear or wasted. A new rule needs the same failure tag twice in the private overlay directory's `sizing-log.md`; a first occurrence gets a tag in this task's log line.

An edit must keep the generic skill at or below 3,000 words (from its real directory: `wc -w SKILL.md models.md phases/*.md`), so cut text when you add text. Put work-specific changes in the private overlay directory.

Propose at most three items from parts 1 and 2 together, most severe first. Prefer an automated check to a verify recipe, and a verify recipe to jstack text.

## 3. Sizing verdict

**Under** if any is true:

- the size was raised during build;
- a unit failed twice;
- verify returned work to build;
- a decision appeared after a gate.

**Over** if every item that applies is true:

- the user accepted every grill recommendation;
- the spec had one unit;
- the two sketches matched;
- a research note went unused;
- independent verify found nothing beyond the builder's checks.

Otherwise **right**. Name the signal that missed. Append one line to `sizing-log.md` in the private overlay directory defined in `SKILL.md`. Create the directory and log if missing; never write the log into the synced skill:

```text
<date> | <repo> | <slug> | predicted=<size> | verdict=<right|under|over> | missed=<signal|none> | tags=<failure tags>
```

If the same signal has missed twice in the same direction, propose a change to it.

## 4. Lessons

Propose a lesson only when an evidence file supports it and it is not obvious.

- A fact about this project: save it to the project's ai-memory, updating an existing page where one fits.
- A lesson that transfers: list it as a candidate for the personal-knowledge review.

## 5. Close

Apply the approved items. Set the ledger phase to `done`.
