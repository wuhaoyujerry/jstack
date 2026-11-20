# Sources

cooking is a rewrite, not a fork. Each phase keeps mechanisms from the skills below and drops the rest.

| Collection | Upstream | Commit read |
|---|---|---|
| pstack | https://github.com/backnotprop/pstack | `4161d4ef5051574e825ffe70e2f43a2e49e4b3db` |
| Matt Pocock skills | https://github.com/mattpocock/skills | `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d` |
| ponytail | https://github.com/DietrichGebert/ponytail | `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846` |

| cooking file (relative to `skills/cooking/`, except private overlays) | Source skill | Kept | Dropped |
|---|---|---|---|
| `../idea/SKILL.md` | `grilling` (Matt Pocock) | Design tree, frontier, rounds, recommended answer, agent finds facts, a relentless interview | Text format of a round and its "yes" wording: a round is one question-tool call |
| `../idea/SKILL.md` | `domain-modeling` (Matt Pocock) | Challenge terms, edge-case scenarios, check against code, write glossary at once, three-part ADR test | In-repo `GLOSSARY.md` and `docs/adr/`, multi-context map, format files |
| `../technical-writing/`, `../unslop/` | `technical-writing`, `unslop` (pstack) | `SKILL.md`, verbatim, with the MIT license; `idea` reads both by path for the brief | Nothing |
| `../research/SKILL.md` | `research` (Matt Pocock) | Primary sources, one cited note | Background-agent wording |
| `../research/SKILL.md` | `how` (pstack) | Simple and complex paths, 2 to 4 angles, five output sections | Model routing, per-harness spawn text, prompt reference files |
| `../research/SKILL.md` | `why` (pstack) | Code anchor first, one investigator per evidence source, record empty sources, stated versus inferred | MCP discovery procedure, analytics category, source playbooks, epistemics reference, synthesizer prompt |
| `../research/SKILL.md` | Investigation playbook (pstack `poteto-mode`) | Read-only, own the answer, trade-off table for a decision, stop on a wrong premise | Routing to `how` and `why` skills, throughput checkpoint, `unslop` call |
| `../research/SKILL.md` | Jerry's earlier `research` skill | Pre-scan before researchers, open the original source for key claims, empty versus unsearched, two-codemode-worker limit | Work source list and tool names, run-report table, Hindsight and deep-research notes |
| `phases/recipe.md` | `architect` (pstack) | Ground first, usage before shape, empty bodies, two blind sketches, red flags, deviation as signal | `arena` and cross-judging, always-two rule, rationale template, scrap procedure (cooking returns to the recipe gate) |
| `phases/recipe.md` | `to-spec` (Matt Pocock) | Spec sections, no stale file paths, checks at the highest existing seam, glossary terms and ADRs | User stories, issue-tracker publishing, triage labels |
| `phases/saute.md` | `implement-spec`, `implement` (Matt Pocock) | Task graph with a frontier, pointers instead of repeated context, worktree per parallel group, merge then recheck | Ticket tracker, `tdd` and `code-review` calls, draft PR handling |
| `phases/saute.md` | Feature playbook, `principle-sequence-verifiable-units` (pstack) | Build, check and commit one unit before the next | Throughput checkpoint, arena delegation, PR steps |
| `phases/saute.md` | Bug fix playbook (pstack `poteto-mode`) | Reproduce first: the unit's check fails before the fix and passes after | Control skills, binary search for the cause, repro-before-fix commit order |
| `phases/saute.md` | `ponytail` (Dietrich Gebert) | Smallest complete change: reuse before new code, finish what the change breaks, the never-cut list, fix a defect once in shared code | Session mode and levels, reply footer, `shortcut:` comments, one-line preference, comment rule |
| `phases/taste.md` | `create-verification-skill` (pstack) | Launch, doctor, drive, evidence, cleanup; prove the drive script once; proof standards; suspect the observation | Feature map, maintenance skill, per-harness skill folders (drive scripts live in `.cookbook/taste/`) |
| `phases/taste.md` | `ponytail-review` (Dietrich Gebert) | Review of the diff and its callers, the order of importance, no case no finding, scale judged against the expected load | Six-category checklist, four-part finding template, numbered findings, verdict and lean-count lines |
| `phases/review.md` | `retro` (Matt Pocock) | Finding categories, as observation categories; session logs as a source, cut to the user's messages in the dish's sessions | Any session as input, implementation-versus-review reference, file guide |
| `../improve/SKILL.md` | `retro` (Matt Pocock) | Checks before written rules, the user approves each change | `writing-for-agents` call |
| `../writing-for-agents/` | `writing-for-agents` (Matt Pocock) | `SKILL.md` and `SKILL-MECHANICS.md`, verbatim, with the MIT license | `agents/openai.yaml` (Codex UI metadata) |
| `overlays/work.md` (private, repo-root relative) | Jerry's lessons in `~/Desktop/knowledge/lessons/` | Three-state checks, runtime evidence for removal, counting by a known-good list | The cases behind each lesson |

Not carried over: the 24 pstack principle skills and the playbook library. Four principles are candidates for the evaluation: prove it works, sequence verifiable units, fix root causes, subtract before you add.

New in cooking: resume from the ledger, review that only records and `improve` that acts across dishes, sizing signals and the sizing log with its markers, the split test at each gate, the meal file that lists the dishes of one goal, the three-state taste table, overlay hooks after each phase, the two-failure rule, lean test cases listed in the recipe, a failure case for units with side effects, scoped test commands, a serial-or-parallel time estimate before saute, frequency and guards weighed before a must-fix, a model-id check before worker start, the worker model table, evidence-backed lessons, the drift check before a second rule (after the error-class governance loop, arXiv 2608.19125), the candidate scenario judged before a change, one judge for all changes of a run, tag merges in the review log, workflow changes scoped by repo, a behaviour case that proves each skill change, the home of `improve` with handoffs in both directions, the ignore check for `.cookbook/`, shared logs that name repos and dishes by id with a leak check before each push, a detail check that marks a thin observation `needs-info` for the machine that holds its file, behavioural tests.
