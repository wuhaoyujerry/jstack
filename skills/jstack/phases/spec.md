# Spec

Turn the approved brief into `.jstack/<slug>/spec.md`: a shape, and ordered units that each carry a check.

## 1. Ground

Read every part of the system the change touches. If you cannot explain how a part works, run a `how` research question. If the change moves ownership or layering, run a `why` question on the present shape. Skip this step only for greenfield work.

## 2. Sketch

Write the caller's usage first, then derive the shape from it: types, signatures, module boundaries, resource layout. Leave bodies empty.

- **Standard task**: you write one sketch.
- **Large task, or the brief says the shape is contested**: start sketcher A and sketcher B. Each receives only `brief.md` and the research notes, and sketches without seeing the other. Compare the two in a table, choose or merge, and record why under **Choice**.

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

Mark each check that needs judgement, and each that changes a shared environment.

## 4. Write the spec

```markdown
# Spec: <slug>
## Problem
## Usage
## Shape
## Units
| id | change | check | depends on | parallel |
## Verify
- surface: <where a user meets this change>
- judgement checks: <ids>
- mutating checks: <ids, each with its exact command>
## Out of scope
## Choice
```

Every done-check in the brief maps to a unit check. Name decisions and interfaces; file paths go stale.

## 5. Gate

Show the spec. Wait for the user to approve it. Then answer the Units and Reach signals again, copy the units into the ledger, and record the date.
