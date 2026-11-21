# Meal

The meal file:

```markdown
# Meal: <meal>
goal: <one line>

## Shared decisions
- <a decision that binds more than one dish>

## Dishes
| dish | depends on |
|---|---|
```

Each dish keeps its own folder and ledger in the cookbook, and names the meal on the `meal` line of its ledger. Read a dish's status from the `phase` of its ledger; the meal is done when every dish is `done`.

## 1. Split a dish

The user approved the dishes to cut (`phases/size.md`, step 3). The **original dish** is the one you split. It keeps its slug and folder, because its sessions and evidence name that path, and it keeps a part that depends on no other dish.

1. Write the meal file: a short name, the goal and a row for each dish. Move each decision that binds more than one dish from the brief into it.
2. For each new dish, create `.cookbook/<slug>/ledger.md` from the template in `SKILL.md`, with its own `ask`, the `meal` line and `phase: size`. Write its `brief.md` with the sections of the original brief: its own goal, decisions and done-checks, and under `## Decisions` the path of the meal file in place of the shared decisions. Its recipe waits for its own recipe phase, after the dishes before it have changed the code.
3. Cut the original dish to its own part the same way: its brief, the `ask` and `meal` lines of its ledger, and the units of a written recipe. Answer the five signals again for its own part and record the size. A gate it has passed keeps its date.
4. Record the split in the events of each ledger.

The split is done when the meal file lists every dish, every dish has a ledger that names the meal, and every done-check of the uncut brief is in exactly one brief. Then continue the original dish from where it stopped; at the brief gate, show the gate summary of its cut brief (`../idea/SKILL.md`, step 8); at the recipe gate, follow `phases/recipe.md`, step 5.

## 2. Cook a dish of a meal

- **Choose.** When the ask names the meal and no one dish, take the first dish in the table that is not `done` and whose dependencies are all `done`. This choice replaces the question that `SKILL.md` asks when several ledgers match. When every dish is `done`, tell the user the meal is done.
- **Start.** Start a dish only when every dish it depends on is `done` and the current branch holds their work. Otherwise tell the user what is missing.
- **Brief.** The meal's shared decisions are settled for every dish. Give the meal file to each worker that receives the brief.
- **Close.** When review closes a dish, add to its closing line the next dish of the meal, or that the meal is done.
