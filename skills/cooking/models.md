# Worker models

Every worker is a Pi agent. The role sets the model and effort. For each saute builder you start, use the current size in the ledger.

| Role | `<model>:<effort>` |
|---|---|
| researcher | `openai-codex/gpt-6-luna:low` |
| sketcher A | `anthropic/claude-fable-5-2:medium` |
| sketcher B | `openai-codex/gpt-6.2-astra:medium` |
| builder (`large`) | `openai-codex/gpt-6.2-astra:medium` |
| builder (`trivial` or `standard`) | `openai-codex/gpt-6.2-sol:medium` |
| verifier | `openai-codex/gpt-6.2-sol:medium` |
| judge (author is an OpenAI model) | `anthropic/claude-fable-5-2:medium` |
| judge (author is an Anthropic model) | `openai-codex/gpt-6.2-astra:medium` |

The **author** is whose work the judge checks: the builder in taste, you in improve. Pick the judge row for the author's family. In improve, give the judge your own effort, `$PI_REASONING_LEVEL`, in place of the row's.

Ids differ by machine. An overlay in `overlays/` of the data folder, which `logs.sh data` prints, may replace them: apply it first.

## Start a worker

Start each worker with one `worker-start` call, so that Orca owns its terminal and closes it after the worker reports.

```bash
orca orchestration worker-start --agent pi --model <model> --effort <effort> \
  --worktree <selector> --task-title "<role> <slug>" --spec-file <file> --json
```

- `<model>` and `<effort>` are the two halves of the role's `<model>:<effort>`.
- `<selector>` is `current`, or `name:<worktree>` for a unit's own worktree.
- Write the spec file in `<dish>/workers/`: the target, absolute paths to read, what the worker may edit, and the evidence that proves it is done.
- A worker's spec and every later message come from a file you wrote with your file tool: `--spec-file <file>` for the spec, `"$(cat <file>)"` for a message. The shell runs backticks typed inside double quotes; it leaves a file's content as data.
- A read-only spec opens with: "Read-only: change nothing outside your report file."
- Start every independent worker, then end your turn. Orca wakes you with each `worker_done`.
- Before the first start, run `pi --list-models <model>` for each id you will use. If Pi prints no row for one, or rejects one at start, stop and tell the user. Choose no substitute.
