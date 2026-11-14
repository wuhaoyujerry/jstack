# jstack

Jerry's dev workflow: size a task, then grill, research, spec, build, verify, retro.

- Generic workflow: `skills/jstack/SKILL.md`, `skills/jstack/models.md`, and `skills/jstack/phases/`.
- Private work rules and generated sizing history: `overlays/work.md` and `overlays/sizing-log.md`. The whole `overlays/` directory is Git-ignored and outside the synced skill.
- The skill resolves its real directory before finding `../../overlays/`. Overlays are optional and are not distributed to other machines.
- Task artifacts stay in each working repo's Git-ignored `.jstack/` directory.
- Link a checkout: `skillshare link "$PWD/skills/jstack" --name jstack --enable -g`, then `skillshare sync -g`.
- Skillshare and agent skill folders link here; edits through those links change this repo.
- `SOURCES.md` records the origins of each phase.
- Invoke: `/jstack <ask>`, or `/jstack <phase>`.
- Word cap: 3,000 for `skills/jstack/SKILL.md`, `skills/jstack/models.md` and `skills/jstack/phases/*.md`.
