# Recipe

Turn the approved brief into `<dish>/recipe.md`: a shape, and ordered units that each carry a check.

## 1. Ground

Read every part of the system the change touches. If you cannot explain how a part works, run a `how` research question. If the change moves ownership or layering, run a `why` question on the present shape. Skip this step only for greenfield work.

## 2. Sketch

Write the caller's usage first, then derive the shape from it: types, signatures, module boundaries, resource layout. Leave bodies empty.

- **Standard dish**: you write one sketch.
- **Large dish, or the brief says the shape is contested**: start sketcher A and sketcher B. Each receives only `brief.md` and the research notes, and sketches without seeing the other. Compare the two in a table, choose or merge, and record why under **Choice**.

Revise a sketch that shows a **red flag**:

- A wide interface that hides little.
- One internal decision known to several modules.
- Modules split by execution order instead of by what they own.
- A layer that only forwards calls.
- Two writers of the same state.

## 3. Cut units

A **unit** is the smallest change that can be built, checked and committed alone. For each unit write:

- what changes;
- its **check**: a command and the expected result, or a named observation;
- the units it depends on;
- `parallel: yes` only when its files overlap with no other parallel unit.

Keep checks **lean**. Attach each at the highest existing **seam** that shows the behaviour; add a seam only when none does. Reuse an existing test when one shows it. A new test lists its cases in the unit: one per behaviour in the brief's done-checks, plus one per risky failure path in a parser or security code. A unit that writes state, enqueues work, calls an external provider or handles a webhook also lists at least one failure or edge case in its check: a partial failure, a retry or re-entry, or another caller path.

Mark each check that needs judgement, and each that changes a shared environment. A check that needs the deployed system is a **live check**: write it under `## Taste` with the unit it verifies, not as a unit.

## 4. Write the recipe

```markdown
# Recipe: <slug>
## Problem
## Usage
## Shape
## Units
| id | change | check | depends on | parallel |
## Taste
- surface: <where a user meets this change>
- judgement checks: <ids>
- mutating checks: <ids, each with its exact command>
- live checks: <each with the unit it verifies>
## Out of scope
## Choice
```

Every done-check in the brief maps to a unit check. Name decisions and interfaces; file paths go stale. Use the terms in `.cookbook/glossary.md` and keep to the decisions in `.cookbook/adr/`.

## 5. Gate

The recipe is for agents: the user does not read it. The gate waits for the user only on a **gap** that needs their input:

- the two sketches differ in a design choice that is the user's to make;
- the recipe departs from the brief in scope, a decision or a done-check;
- a unit failed twice and saute returned here;
- the split test recommends a split.

On a gap, show the gap and your recommendation, not the recipe, and wait for the answer. With no gap the gate **auto-passes**: write `recipe gate auto-passed` and the reason in the ledger events, and tell the user in one line. On either passage, record the gate's date and copy the units into the ledger.

A return from saute sets the gate to `open`. So does an objection from the user to the recipe, also after the gate's date: record the correction in the ledger events, revise the recipe and wait for approval.
