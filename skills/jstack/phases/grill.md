# Grill

Interview the user until every decision is settled, then write the brief.

## Steps

1. Map the ask as a **design tree**: each decision branches into the decisions that depend on it. The **frontier** is every decision whose prerequisites are settled.

2. Ask the frontier one question at a time with the question tool. Put your recommended answer first and mark it. After each answer, recompute the frontier.

3. Facts are yours to find; decisions are the user's. Read the code or run a read-only command. If a fact needs fetching or history, run research and keep asking the questions that do not depend on it.

4. When the user is unsure, give the trade-off and your evidence, name what you have not checked, and ask again.

5. Sharpen the language as you go:
   - When a term conflicts with `.jstack/glossary.md` or with the code, ask which meaning is right.
   - Replace a vague term with one exact term.
   - Test a relationship between concepts with a concrete edge case.
   - When a term settles, write it to `.jstack/glossary.md` at once: the term and one sentence.

6. Record a decision in `.jstack/adr/<nnnn>-<name>.md` only when all three hold: it is hard to reverse, it would surprise a later reader, and it came from a real trade-off.

7. The grill is done when the frontier is empty. Write `.jstack/<slug>/brief.md`:

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

8. **Gate.** Show the brief. Wait for the user to approve it. Then answer the Shape and Risk signals again and record the date in the ledger.
