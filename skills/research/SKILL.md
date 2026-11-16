---
name: research
description: "Research a question and return one cited answer. Use when the user says research, or asks how code works, why it has its shape, what a tool or API does, or which option to pick."
metadata:
  author: Jerry Wu
---

# Research

Read-only. You own the answer: plan, gather, write.

## 1. Choose the kind

| Kind | Question | Evidence |
|---|---|---|
| how | How does this code work, and where should a change live? | the code |
| why | What forces gave this its shape? | history and discussion |
| external | What does a tool, API or standard do? | primary sources |

A **decision** (which option fits) is one of these kinds; its answer is a recommendation.

If the evidence rules out the question's premise, show it and stop.

## 2. Gather

**Narrow question** (one module, one function, one doc page): gather it yourself.

**Wide question**: pre-scan each connected source (code, source control, tickets, documents, chat, observability, the web) with one cheap search, and record the hits and identifiers. Then start one read-only researcher per slice, all at once, each with the identifiers and its own findings file.

- **how**: split the subsystem into 2 to 4 angles, one researcher each.
- **why**: set the code anchor yourself (paths, symbols, `git blame`, recent commits, PR and ticket ids). Then one researcher per source with hits.
- **external**: official docs, source code, specs. Follow each claim to the source that owns it.

Pi runs two codemode workers per process: start at most two codemode researchers, and make no codemode call meanwhile.

## 3. Write

Open the original source yourself for every claim the answer depends on.

- **how**: Overview, Key concepts, How it works, Where things live, Gotchas. Write for a senior engineer new to the subsystem.
- **why**: separate what a source states from what you infer.
- **decision**: the recommendation, then a trade-off table.
- Every claim cites its source and date: a file path with its line, a commit, a ticket, or a URL.
- End with **Unknowns**: what the evidence does not settle, how to check it, and each source's state: hits, empty (searched, nothing found) or unsearched.

Inside a cheese task, also save the answer to `.jstack/<slug>/research/<question>.md`.

Research is done when the question has an answer or a named unknown, with every claim cited.
