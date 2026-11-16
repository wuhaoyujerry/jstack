# Size

Choose the task's size, and with it the phases that follow.

## 1. Answer the signals

Answer five signals from the ask and a short repo look. Read files yourself; start no worker.

| Signal | Question |
|---|---|
| Done-check | Can I write the passing check now, with no open decision? |
| Units | Is the work one unit, or several that can run apart? |
| Reach | Does it change a public interface, or more than one module or repo? |
| Risk | Does it change a shared or production environment, or data that cannot be restored? |
| Shape | Is there more than one reasonable design, or a fact to research? |

- **trivial**: Done-check clear, one unit, no Reach, no Risk. Phases: build, verify, review.
- **large**: several units, wide Reach, Risk, or open Shape. Phases: grill, spec, build, verify, review.
- **standard**: everything else. Phases: grill, spec, build, verify, review.

Write the size and the five answers to the ledger and tell the user both in one line. The user may override. Then run the first phase of that size.

## 2. Correct the size

Each gate answers signals again: the brief gate Shape and Risk, the spec gate Units and Reach. During build the size only goes up; only the user lowers it. Record each change in the ledger.
