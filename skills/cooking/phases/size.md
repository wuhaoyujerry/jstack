# Size

Choose the dish's size, and with it the phases that follow.

## 1. Answer the signals

Answer five signals from the ask and a short repo look. Read files yourself; start no worker.

| Signal | Question |
|---|---|
| Done-check | Can I write the passing check now, with no open decision? |
| Units | Is the work one unit, or several that can run apart? |
| Reach | Does it change a public interface, or more than one module or repo? |
| Risk | Does it change a shared or production environment, or data that cannot be restored? |
| Shape | Is there more than one reasonable design, or a fact to research? |

- **trivial**: Done-check clear, one unit, no Reach, no Risk. Phases: saute, taste, review.
- **large**: wide Reach, Risk, or open Shape. Phases: idea, recipe, saute, taste, review.
- **standard**: everything else. Phases: idea, recipe, saute, taste, review.

Write the size and the five answers to the ledger and tell the user both in one line. The user may override. Then run the first phase of that size.

## 2. Correct the size

Each gate answers signals again: the brief gate Shape and Risk, the recipe gate Reach. During saute the size only goes up; only the user lowers it. Record each change in the ledger.

## 3. Test for a split

Size answers how hard the work is. A **split** into several dishes answers how much of it there is.

When you show the brief or the recipe at its gate, and when the user says the dish is too big, sort the brief's done-checks into **parts**. A part can be built, tasted and shipped without the others, or after another has shipped; done-checks that share a unit are one part. The dish holds several dishes when two or more parts would each be standard or large as a dish of its own (step 1).

When it does, show beside the brief or the recipe the dishes you would cut, each with its done-checks, and recommend the split. A part that would be trivial joins one of them. The user decides; record the answer in the ledger events. A no stands until the parts change. On a yes, follow [`../meal.md`](../meal.md).
