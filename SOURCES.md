# Sources

jstack is a rewrite, not a fork. Each phase keeps mechanisms from the skills below and drops the rest.

| Collection | Upstream | Commit read |
|---|---|---|
| pstack | https://github.com/backnotprop/pstack | `4161d4ef5051574e825ffe70e2f43a2e49e4b3db` |
| Matt Pocock skills | https://github.com/mattpocock/skills | `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d` |

| jstack file (relative to `skills/jstack/`, except private overlays) | Source skill | Kept | Dropped |
|---|---|---|---|
| `phases/grill.md` | `grilling` (Matt Pocock) | Design tree, frontier, recommended answer, agent finds facts | Whole-frontier rounds: jstack asks one question at a time |
| `phases/grill.md` | `domain-modeling` (Matt Pocock) | Challenge terms, edge-case scenarios, check against code, write glossary at once, three-part ADR test | In-repo `GLOSSARY.md` and `docs/adr/`, multi-context map, format files |
| `phases/research.md` | `research` (Matt Pocock) | Primary sources, one cited note | Background-agent wording |
| `phases/research.md` | `how` (pstack) | Simple and complex paths, 2 to 4 angles, five output sections | Model routing, per-harness spawn text, prompt reference files |
| `phases/research.md` | `why` (pstack) | Code anchor first, one investigator per evidence source, record empty sources, stated versus inferred | MCP discovery procedure, analytics category, source playbooks, epistemics reference, synthesizer prompt |
| `phases/spec.md` | `architect` (pstack) | Ground first, usage before shape, empty bodies, two blind sketches, red flags, deviation as signal | `arena` and cross-judging, always-two rule, rationale template, scrap procedure (jstack returns to the spec gate) |
| `phases/spec.md` | `to-spec` (Matt Pocock) | Spec sections, no stale file paths | User stories, issue-tracker publishing, triage labels |
| `phases/build.md` | `implement-spec`, `implement` (Matt Pocock) | Task graph with a frontier, pointers instead of repeated context, worktree per parallel unit, merge then recheck | Ticket tracker, `tdd` and `code-review` calls, draft PR handling |
| `phases/build.md` | Feature playbook, `principle-sequence-verifiable-units` (pstack) | Build, check and commit one unit before the next | Throughput checkpoint, arena delegation, PR steps |
| `phases/verify.md` | `create-verification-skill` (pstack) | Launch, doctor, drive, evidence, cleanup; prove the recipe once; proof standards; suspect the observation | Feature map, maintenance skill, per-harness skill folders (recipes live in `.jstack/verify/`) |
| `phases/retro.md` | `retro` (Matt Pocock) | Finding categories, checks before written rules | Implementation-versus-review reference, file guide, `writing-for-agents` call |
| `overlays/work.md` (private, repo-root relative) | Jerry's lessons in `~/Desktop/knowledge/lessons/` | Three-state checks, runtime evidence for removal, counting by a known-good list | The cases behind each lesson |

Not carried over: the 24 pstack principle skills and the playbook library. Four principles are candidates for the evaluation: prove it works, sequence verifiable units, fix root causes, subtract before you add.

New in jstack: sizing signals and the sizing log, the three-state verify table, the two-failure rule, the worker model table, evidence-backed lessons.
