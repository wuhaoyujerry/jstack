# jstack

Jerry's dev workflow: size, idea, recipe, saute, taste, review. Each has a file in `skills/cooking/phases/`.

- Generic workflow: `skills/cooking/SKILL.md`, `skills/cooking/models.md`, and `skills/cooking/phases/`.
- `skills/idea/` is the idea phase as its own skill; `phases/idea.md` points to it. `skills/research/` is a separate skill that idea and recipe call for a missing fact. `skills/improve/` is a separate skill, typed as `/improve`, that turns the observations of the review phase into workflow changes. `/idea <topic>` is typed only; `research` also starts when a prompt says research, or asks how code works, why it has its shape, what a tool does, or which option to pick.
- Private work rules and generated logs: `overlays/work.md`, `overlays/sizing-log.md` and `overlays/review-log.md`. The whole `overlays/` directory is Git-ignored and outside the synced skill.
- The skill resolves its real directory before finding `../../overlays/`. Overlays are optional and are not distributed to other machines.
- Task artifacts stay in each working repo's Git-ignored `.jstack/` directory.
- Link a checkout: `skillshare link "$PWD/skills/cooking" --name cooking --enable -g`, the same for `skills/idea`, `skills/research` and `skills/improve` under their own names, then `skillshare sync -g`.
- `skills/technical-writing/` and `skills/unslop/` are copies of pstack skills (MIT). `idea` reads them by path to write the brief; they need no link.
- Skillshare and agent skill folders link here; edits through those links change this repo.
- `SOURCES.md` records the origins of each phase.
- `SCENARIOS.md` lists behaviours that must hold; `/improve` checks each skill change against it.
- `skills/writing-for-agents/` is a copy of Matt Pocock's skill (MIT), without its Codex-only `agents/` folder; `SOURCES.md` records it, and `/improve` checks it for upstream changes. `AGENTS.md` requires it before edits to `skills/`.
- Invoke: `/cooking <ask>`. An ask to continue a task resumes it from its ledger. An ask that reports what happened to a finished task adds it to the review log, and an issue to fix reopens the task at saute.
