# Meal

The meal file:

```markdown
# Meal: <meal>
goal: <one line>
worktree: <path|none>
branch: <meal branch|none>

## Shared decisions
- <a decision that binds more than one dish>

## Dishes
| dish | depends on |
|---|---|
```

Each dish keeps its own folder and ledger in the meal folder, and names the meal on the `meal` line of its ledger. Read a dish's status from the `phase` of its ledger.

## 1. Split a dish

The user approved the dishes to cut (`phases/size.md`, step 3). The **original dish** is the one you split. It keeps its slug, because its sessions name it, and it keeps a part that depends on no other dish.

1. Choose a short meal name that differs from the slug of every dish in the meal, and create the meal folder. Move the original dish's folder into it, and change each path in the dish's files that names the old folder.
2. Write the meal file: the goal and a row for each dish. Move each decision that binds more than one dish from the brief into it.
3. For each new dish, create `.cookbook/meals/<meal>/<slug>/ledger.md` from the template in `SKILL.md`, with its own `ask`, the `meal` line and `phase: size`. Write its `brief.md` with the sections of the original brief: its own goal, decisions and done-checks, and under `## Decisions` the path of the meal file in place of the shared decisions. Its recipe waits for its own recipe phase, after the dishes before it have changed the code.
4. Cut the original dish to its own part the same way: its brief, the `ask` and `meal` lines of its ledger, and the units of a written recipe. Answer the five signals again for its own part and record the size. A gate it has passed keeps its date.
5. Record the split in the events of each ledger.

The split is done when the meal file lists every dish, every dish has a folder in the meal folder and a ledger that names the meal, and every done-check of the uncut brief is in exactly one brief. Then coordinate the meal (step 2). The answer to the split approves no brief: the original dish stops at the gate where it was, and that gate stays open until its worker has put the cut brief to it, with the gate summary at the brief gate (`../idea/SKILL.md`, step 8) and by `phases/recipe.md`, step 5, at the recipe gate.

## 2. Coordinate the meal

The **meal worktree** holds the **meal branch**, which collects the work of the dishes. The session in it is the **meal agent**: it cooks no dish. It starts each dish as a worker in a child worktree, receives every report, and merges each dish that is done. Follow this step after a split, when the ask names the meal, and when it names a dish of the meal whose ledger names no worktree. A dish's worker (step 3) that is asked to continue its dish cooks it in place of this step, whatever its ledger names. This step replaces the question that `SKILL.md` asks when several ledgers match.

A dish is **ready** when it is not `done`, every dish it depends on is `done`, and the meal branch holds their work. While the meal file names no worktree, the current branch stands for the meal branch.

Find the meal agent first:

- **The meal file names the worktree you are in**: you are the meal agent.
- **It names another worktree**: tell the user that worktree and change nothing.
- **It names none, and no dish is ready**: tell the user what is missing and change nothing.
- **It names none, in the main checkout**: hand off the meal by step 3 of `SKILL.md`, with the meal's name for the slug, `Ask: continue the meal <meal>.`, and the meal file in place of the ledger: write the reply's path and its branch, without `refs/heads/`, to the meal file, and record the handoff and `$PI_SESSION_FILE` in the events of each dish that is not `done`. The `worktree` line of a dish names that dish's own worktree, never the meal worktree.
- **It names none, in another worktree**: that worktree is the meal worktree and you are the meal agent. Write its path and branch to the meal file, and set to `none` the `worktree` line of a dish that names it.

As the meal agent, handle each message that waits for you (2 and 3) before you start a dish:

1. Start every ready dish whose ledger names no worktree, as `models.md` starts a worker, on your own model and in a child worktree from the meal branch:

   ```bash
   orca orchestration worker-start --agent pi --model "$PI_PROVIDER/$PI_MODEL" --effort "$PI_REASONING_LEVEL" \
     --worktree new-child --name <slug> --base-branch <meal branch> --task-title "dish <slug>" --spec-file <file> --json
   ```

   The spec is `Read <this skill's real directory>/SKILL.md and follow it. Ask: continue the dish <slug>.` Write the path in the reply's `workspace`, after `::`, to the `worktree` line of the dish's ledger. When dishes remain that are not `done`, and none of them is ready or names a worktree, tell the user what is missing and change nothing. Then end your turn; Orca wakes you with each message.
2. A **question** from a dish is a gate or a stop of that dish. Show it to the user as the dish wrote it, with the dish's name, and send the user's answer back.
3. A **report** that a dish is `done`: merge its branch with `git merge <dish branch>`. On a conflict, run `git merge --abort`, show the user the files and stop. Otherwise tell the user the dish's closing line and go to 1.

The meal is done when every dish is `done` and merged: tell the user.

## 3. Cook a dish of a meal

- **Worker.** A dish that the meal agent started is its worker: its prompt opens with the Task and Dispatch IDs. Where a phase waits for the user, put the same text to the meal agent with `ask` and end your turn. When review closes the dish, report its closing line and its branch to the meal agent.
- **Brief.** The meal's shared decisions are settled for every dish. Give the meal file to each worker that receives the brief.
