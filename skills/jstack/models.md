# Worker models

Every worker is a Pi agent. The role sets the model and effort.

| Role | `<model>:<effort>` |
|---|---|
| researcher | `openai-codex/gpt-6-luna:low` |
| sketcher A | `anthropic/claude-fable-5-2:medium` |
| sketcher B | `openai-codex/gpt-6-astra:medium` |
| builder | `openai-codex/gpt-6.1-sol:medium` |
| verifier | `openai-codex/gpt-6.1-sol:medium` |
| judge | `anthropic/claude-fable-5-2:medium` |

The **judge** is the strong model from the family that did not build. If the builder changes family, change the judge.

## Start a worker

Orca's `--model` flag does not reach Pi, so start Pi yourself and attach the task.

```bash
orca terminal create --worktree <selector> --title <role>-<slug> \
  --command "pi --model <model>:<effort>" --json
orca terminal wait --terminal <handle> --for tui-idle --timeout-ms 60000 --json
orca orchestration worker-start --terminal <handle> --worktree <selector> \
  --task-title "<role> <slug>" --spec-file <file> --json
```

- `<selector>` is `current`, or `name:<worktree>` for a unit's own worktree.
- Write the spec file in `.jstack/<slug>/workers/`: the target, absolute paths to read, what the worker may edit, and the evidence that proves it is done.
- A read-only spec opens with: "Read-only: change nothing outside your report file."
- Start every independent worker, then end your turn. Orca wakes you with each `worker_done`.
- If Pi rejects a model id, stop and tell the user. Choose no substitute.
