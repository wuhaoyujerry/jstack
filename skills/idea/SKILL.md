---
name: idea
description: "Interview me until every decision is settled, then write a brief. Invoke /idea TOPIC."
disable-model-invocation: true
metadata:
  author: Jerry Wu
---

# Idea

Interview the user relentlessly until every decision is settled, then write the brief.

`.cookbook/` is at the root of the main checkout, the first worktree that `git worktree list` prints. `<dish>` is the cooking dish's folder. Outside cooking, it is `.cookbook/dishes/<slug>/`, with a short slug you choose.

## Steps

1. Map the ask as a **design tree**: each decision branches into the decisions that depend on it. A **decision** is a choice the brief must resolve when the facts permit more than one reasonable way to meet the ask, such as scope, order or what to defer. It is **settled** when the user has made it, in the ask or in an answer; `## Decisions` in `<dish>/brief.md` records the settled ones. An outcome that rests on an opinion, such as wording that reads well or a design that looks good, holds one more decision: what settles the opinion, as the exact text, the design to match or a rule with a number. The **frontier** is every open decision whose prerequisites are settled.

2. In each **round**, ask as many frontier questions as fit in one question-tool call, with your recommended answer first in each and marked. Wait for the answers, write each decision under `## Decisions` in `<dish>/brief.md`, then recompute the frontier and ask the next round.

3. Facts are yours to find; decisions are the user's. Read the code or run a read-only command. If a fact needs fetching or history, follow `../research/SKILL.md` (from this skill's real directory) and keep asking the questions that do not depend on it. When its note arrives, add each decision it opens to the tree.

4. When the user is unsure, give the trade-off and your evidence, name what you have not checked, and ask again.

5. Sharpen the language as you go:
   - When a term conflicts with `GLOSSARY.md` at the repo root or with the code, ask which meaning is right.
   - Replace a vague term with one exact term.
   - Test a relationship between concepts with a concrete edge case.
   - When a term settles, write it under `## Terms` in `<dish>/brief.md` at once: the term and one sentence. The recipe moves it to `GLOSSARY.md`.

6. A decision that replaces an ADR in `docs/adr/` names that ADR under `## Decisions`. Mark a decision `ADR` under `## Decisions` only when all three hold: it is hard to reverse, it would surprise a later reader, and it came from a real trade-off. Write its alternatives and the reason under `## Open facts`. The recipe moves it to `docs/adr/`.

7. **Close the interview.** When no decision on the tree is open and no research is pending, ask the **closing question** in a round of its own: "What haven't I asked that I should have?" Offer the answers "Nothing is missing" and "Something is missing". This round has no recommended answer: only the user knows what the interview missed. Write the answer under `## Decisions` as the **closing line**: `- Closing question. <the answer in one sentence>. (<date>)`. Add each decision that the answer opens to the tree and ask it in its round. An interview has one closing question, before the brief gets its sections: a brief that holds a closing line or a `## Goal` is past it.

   The interview is done when the brief is past its closing question, no decision on the tree is open and no research is pending.

8. From this skill's real directory, read `../technical-writing/SKILL.md` and `../unslop/SKILL.md`, then complete `<dish>/brief.md` to both standards:

   ```markdown
   # Brief: <slug>
   ## Goal
   ## What it does
   - <a change, in plain words>
   ## How we check
   - <what the user will see or run>
   ## Done-checks
   - <an outcome that a command or a named observation can show>
   ## Non-goals
   - <what stays as it is, in plain words>
   ## Open facts
   - <a fact the recipe must find or confirm, or a mechanism>
   ## Terms
   - <a settled term>: <one sentence>
   ## Contested shape: yes | no
   ## Decisions
   ```

   The first three sections are for the user, in plain words a reader who has not seen the code understands: the goal in one sentence; what the dish changes, in at most 5 lines; how the user will see that it works, in at most 3 lines. Each line has 15 words or fewer and no code, identifier or issue criterion. The non-goals reach the user too: the gate page shows them under "What stays the same". Write each as one plain sentence without code that states what stays as it is, such as "Group bookings keep the card check" or "No change to how fees are charged". The other sections are for the recipe.

   Write each done-check and each decision, also a decision the brief already holds, as one sentence of 20 words or fewer: the outcome, or the choice. A **mechanism** behind it (a command, an identifier, a code reference, the steps of a procedure) goes under `## Open facts`; the recipe writes the exact check of each done-check from there.

   Then run `check-brief.sh <dish>/brief.md` from this skill's real directory. It counts the lines and the words that the two paragraphs above limit, and prints each line over a limit. Rewrite each printed line and run it again: the brief is complete when it prints nothing.

9. **Gate.** A choice you made while writing the brief is a decision; ask it before the gate. Then show the user the **gate page**: one page with the goal, a picture of the change and the brief's lines for the user.

   - **Picture.** Run `gate-page.sh --help` from this skill's real directory: it prints the two forms of a picture. Write `<dish>/gate-picture.md` in one of them: a diagram that marks each part the dish adds, removes or changes, when the parts of the change connect, and keeps each link of today that the dish replaces, marked removed; a table of before and after when they do not, as in a change of wording. The picture holds only what the brief says.
   - **Page.** Run `gate-page.sh <dish>/brief.md <dish>/gate-picture.md`. It writes `<dish>/gate-page.html` and prints a `goal:` line and a `page:` line. When it prints `picture:`, correct the picture as that line says and run it once more.
   - **Gate reply.** Open your message with the gate reply, three lines: the goal, word for word as the `goal:` line gives it, the address of the `page:` line as the link `[<address>](<address>)`, and "Approve this brief?". When the script prints `no page:`, or rejects the picture a second time, open it with the text form: the line `No page: <the reason>.` first, then the **gate summary**: the goal, what it does and how we check, as written in the brief, then the path of the brief and the ask for approval. The first line of your message is the goal or the `No page:` line. Below the gate reply comes only what cooking asks you to say at this gate, such as a split that it recommends, in a few lines; when it asks nothing, the gate reply is your whole message.

   The user reads nothing else: leave the recipe sections, rewordings and code out of the reply. Each gate builds the page again, also after a correction. The idea phase ends when the user approves the brief.
