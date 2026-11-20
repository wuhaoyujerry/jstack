---
name: idea
description: "Interview me until every decision is settled, then write a brief. Invoke /idea TOPIC."
disable-model-invocation: true
metadata:
  author: Jerry Wu
---

# Idea

Interview the user relentlessly until every decision is settled, then write the brief.

`.cookbook/` is at the repo root. `<slug>` is the cooking dish's slug, or a short one you choose.

## Steps

1. Map the ask as a **design tree**: each decision branches into the decisions that depend on it. A **decision** is a choice the brief must resolve when the facts permit more than one reasonable way to meet the ask, such as scope, order or what to defer. It is **settled** when the user has made it, in the ask or in an answer; `## Decisions` in `.cookbook/<slug>/brief.md` records the settled ones. The **frontier** is every open decision whose prerequisites are settled.

2. In each **round**, ask as many frontier questions as fit in one question-tool call, with your recommended answer first in each and marked. Wait for the answers, write each decision under `## Decisions` in `.cookbook/<slug>/brief.md`, then recompute the frontier and ask the next round.

3. Facts are yours to find; decisions are the user's. Read the code or run a read-only command. If a fact needs fetching or history, follow `../research/SKILL.md` (from this skill's real directory) and keep asking the questions that do not depend on it. When its note arrives, add each decision it opens to the tree.

4. When the user is unsure, give the trade-off and your evidence, name what you have not checked, and ask again.

5. Sharpen the language as you go:
   - When a term conflicts with `.cookbook/glossary.md` or with the code, ask which meaning is right.
   - Replace a vague term with one exact term.
   - Test a relationship between concepts with a concrete edge case.
   - When a term settles, write it to `.cookbook/glossary.md` at once: the term and one sentence.

6. Record a decision in `.cookbook/adr/<nnnn>-<name>.md` only when all three hold: it is hard to reverse, it would surprise a later reader, and it came from a real trade-off.

7. The interview is done when no decision on the tree is open and no research is pending. From this skill's real directory, read `../technical-writing/SKILL.md` and `../unslop/SKILL.md`, then complete `.cookbook/<slug>/brief.md` to both standards:

   ```markdown
   # Brief: <slug>
   ## Goal
   ## Decisions
   ## Non-goals
   ## Done-checks
   - <observable check: a command and its expected result, or a named observation>
   ## Contested shape: yes | no
   ## Open facts
   ```

8. **Gate.** Show the brief. The idea phase ends when the user approves it.
