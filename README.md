# jstack

Jerry's dev workflow: size, grill, spec, build, verify, review. Each has a file in `skills/cheese/phases/`.

- Generic workflow: `skills/cheese/SKILL.md`, `skills/cheese/models.md`, and `skills/cheese/phases/`.
- `skills/grill/` is the grill phase as its own skill; `phases/grill.md` points to it. `skills/research/` is a separate skill that grill and spec call for a missing fact. `skills/tasty/` is a separate skill, typed as `/tasty`, that turns the observations of the review phase into workflow changes. `/grill <topic>` is typed only; `research` also starts when a prompt says research, or asks how code works, why it has its shape, what a tool does, or which option to pick.
- Private work rules and generated logs: `overlays/work.md`, `overlays/sizing-log.md` and `overlays/review-log.md`. The whole `overlays/` directory is Git-ignored and outside the synced skill.
- The skill resolves its real directory before finding `../../overlays/`. Overlays are optional and are not distributed to other machines.
- Task artifacts stay in each working repo's Git-ignored `.jstack/` directory.
- Link a checkout: `skillshare link "$PWD/skills/cheese" --name cheese --enable -g`, the same for `skills/grill`, `skills/research` and `skills/tasty` under their own names, then `skillshare sync -g`.
- `grill` writes the brief to the `technical-writing` and `unslop` standards: `skillshare install github.com/cursor/plugins/pstack/skills/technical-writing -g`, and the same for `.../skills/unslop`.
- Skillshare and agent skill folders link here; edits through those links change this repo.
- `SOURCES.md` records the origins of each phase.
- Invoke: `/cheese <ask>`. An ask to continue a task resumes it from its ledger. An ask that reports what happened to a finished task adds it to the review log, and an issue to fix reopens the task at build.
