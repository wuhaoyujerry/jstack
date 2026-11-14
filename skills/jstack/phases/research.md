# Research

Answer one question with cited evidence, in one note: `.jstack/<slug>/research/<question>.md`.

## 1. Choose the kind

| Kind | Question | Evidence |
|---|---|---|
| how | How does this code work, and where should a change live? | the code |
| why | What forces gave the code this shape? | history and discussion |
| external | What does a tool, API or standard do? | primary sources |

## 2. Gather

**Narrow question** (one module, one function, one doc page): gather it yourself.

**Wide question**: start one researcher per slice, all at once, each read-only and each writing its own findings file.

- **how**: split the subsystem into 2 to 4 angles, one researcher each.
- **why**: first set the code anchor yourself (paths, symbols, `git blame`, recent commits, PR and ticket ids). Then send one researcher per evidence source that exists: source control, tickets, documents, chat, observability, error tracking. Each owns one source.
- **external**: official docs, source code, specs. Follow each claim to the source that owns it.

A source that returns nothing is a finding. Record it.

## 3. Write the note

You write the conclusion; researchers only supply findings.

- **how** notes use these sections where they apply: Overview, Key concepts, How it works, Where things live, Gotchas. Write for a senior engineer new to the subsystem.
- **why** notes separate what a source states from what you infer, and list which sources were searched and which were empty.
- Every claim cites its source: `path:line`, a commit, a ticket, or a URL.
- End with **Unknowns**: what the evidence does not settle, and how to check it.

The note is done when the question has an answer or a named unknown, and each claim has a citation.
