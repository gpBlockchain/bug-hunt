# The Test-Writing Loop

## ⚠️ CRITICAL: THIS IS AN INFINITE LOOP — NEVER STOP

You MUST keep iterating. After finishing one iteration, **immediately start the next**. Do NOT stop, pause, summarize, or ask the user anything between iterations. The loop runs until the human manually interrupts you or `max_iterations` (from `bug-hunt.toml`) is reached. If you have completed fewer iterations than `max_iterations`, you MUST continue.

## Overview

This is the core autonomous loop with a single mode:

1. **Write-Test**: Add new unit tests to increase coverage and expose hidden bugs

Each iteration: read context → write test → verify → record outcome. Runs indefinitely until manually stopped or `max_iterations` is reached.

## Loop Structure

```
iteration = 0
while iteration < max_iterations:
    iteration += 1
    1. Before Each Iteration  — read context files
    2. Write-Test Mode        — pick target, write test, commit, run, evaluate
    3. Log to results.tsv     — record outcome
    4. Update Context Note    — update bug-hunt-context.md
    5. Update Strategy State  — update strategy-state.json
    → immediately go back to step 1 for the next iteration
```

**After step 5, you MUST loop back to step 1.** Do NOT stop to reflect, summarize, or ask questions.

## Before Each Iteration

**Track your iteration number** — increment it at the start of each iteration. Check against `max_iterations` from `bug-hunt.toml`. Only stop if `iteration >= max_iterations`.

Read these files (and ONLY these — do not re-read the entire codebase):

1. **`bug-hunt.toml`** — config (test commands, framework, editable test scope, timeouts)
2. **`bug-hunt-context.md`** — your knowledge base (coverage gaps, known bugs)
3. **`risk-map.json`** — code risk scores per function (if exists; generate if missing)
4. **`strategy-state.json`** — test type weights and bug patterns
5. **`recon-report.json`** — tech stack, entry points, trust boundaries (if exists; generate via `recon.md` if missing)
6. **Last 10 entries of `results.tsv`** — recent history
7. **Last 30 entries (combined total) with status `test-added` or `bug-found` from `results.tsv`** — what's been accomplished (do NOT read ALL entries — only the most recent 30 to keep context small)
8. **The specific test files you plan to edit** — current state of the tests

Token budget per iteration should be minimal. Do NOT read files you don't plan to modify.

**If `risk-map.json` is missing:** Generate it now by following `analysis-engine.md`. Read all source files in `readonly` scope, score each function, write the map. This only happens once.

## Multi-Agent Parallel Execution

When multiple agents are configured (see `[coordinator]` and `[[agents]]` in `bug-hunt.toml`):

- Each agent works on its **own dedicated branch** (e.g., `bug-hunt/<tag>-core`, `bug-hunt/<tag>-api`)
- Each agent maintains its **own results log** (e.g., `results-core.tsv`, `results-api.tsv`)
- Each agent maintains its **own context file** (e.g., `bug-hunt-context-core.md`)
- Agents only read source code — they **never modify source files**
- Agents are fully independent and do not share state
- The coordinator merges findings after all agents complete their runs

---

## Write-Test Mode

### Think before writing

Use analysis-driven selection to pick the highest-value test target:

1. **Read risk-map.json** — get function risk scores (0-10)
2. **Read strategy-state.json** — get test type weights (0.2-3.0)
3. **Read last 10 results.tsv entries** — avoid repeating recently tested functions
4. **Calculate composite score** for each candidate (function, test_type):

```
score = (risk_score / 10) × 0.4 + (weight / 3.0) × 0.35 + novelty_bonus × 0.25
```

   - **risk_score**: from risk-map.json, normalized to 0-1
   - **weight**: from strategy-state.json, normalized to 0-1
   - **novelty_bonus**: 1.0 if function never tested, ×0.7 per previous test on same function, min 0.1
   - **recon bonus**: add +0.2 to score when the target function lives in a high-risk entry point path (from recon-report.json) AND the selected test_type is a security type (`injection`, `auth-bypass`, `idor`, `input-overflow`, `secret-leak`)

5. **Select highest-scoring** (function, test_type) pair
6. **Check bug patterns** in strategy-state.json — if the target function matches a recorded pattern, boost that test type
7. **State your hypothesis**: "I'm adding [test_type] tests for [function] because [risk reason + pattern match]"
8. **State the test category**: must match one of the types in strategy-state.json

### Write the test

- Follow the project's test framework conventions (from `bug-hunt.toml`)
- Place test files in the configured `test_dir` using the project's naming conventions
- Each test should be focused — test one thing
- Write tests that are **likely to expose bugs**: edge cases, error paths, boundary conditions, null/empty inputs
- Do NOT modify source code — only add/modify test files

### Commit and run

```bash
git add -A && git commit -m "test: <short description>"
```

Run the test command:

```bash
timeout <timeout_seconds> <test_command> > test-run.log 2>&1
```

### Evaluate Write-Test result

Three possible outcomes:

#### TEST-ADDED (all tests pass including new ones)

The new test(s) pass — the code is correct for these cases. Good: coverage increased.

1. The commit stays on the branch
2. Log to `results.tsv` with status `test-added`
3. Update `bug-hunt-context.md`:
   - Remove the coverage gap from "Test Coverage Gaps"
   - Note in "What Works" what was tested
   - Update "Categories Tried" table
4. **Next iteration**: continue writing more tests

#### BUG-FOUND (new test fails, proving a bug exists)

The new test fails — it exposed a real bug! This is a great outcome.

1. **Run verification** — follow `verification.md` before logging:
   - Re-run tests to check for flakiness
   - Review test preconditions and external state dependencies
   - Assign a confidence score (0–100) and classification (`confirmed`, `likely`, `flaky`, `by-design`)
   - If classified as `flaky` or `by-design`: discard the commit (`git reset --hard HEAD~1`), log with that status, and skip steps 2–3 below
2. The commit stays on the branch (the failing test is intentional — it proves the bug)
3. Log to `results.tsv` with status `bug-found`, plus `confidence` and `verification` columns
4. Update `bug-hunt-context.md`:
   - Add the bug to "Known Bugs" with confidence score and classification
   - Note what the test covers
5. **Next iteration**: continue writing more tests — do NOT attempt to fix the bug

#### CRASH (test command fails to run)

1. Read the error output from `test-run.log`
2. If trivial (syntax error in test, import issue): fix and re-run
3. If fundamental: `git reset --hard HEAD~1`, log with status `crash`
4. Do NOT spend more than 2 attempts fixing a crash.

---

## Log to results.tsv

Append a row (tab-separated):

```
<commit_hash_7chars>	<type>	<tests_total>	<tests_failing>	<delta>	<status>	<description>	<hypothesis>	<category>	<confidence>	<verification>
```

- `commit`: short git hash (7 chars). For discarded attempts, use the hash before reset.
- `type`: always `write-test`
- `tests_total`: total number of tests after this iteration
- `tests_failing`: number of failing tests. Use `N/A` for crashes.
- `delta`: increase in failing tests compared to the previous iteration (positive = new bugs found this iteration). Use `0` for crashes.
- `status`: `test-added`, `bug-found`, `crash`, `flaky`, or `by-design`
- `description`: one-line summary of the test written
- `hypothesis`: why you wrote this test
- `category`: category tag
- `confidence`: integer 0–100 for `bug-found` rows; `N/A` for all others
- `verification`: `confirmed`, `likely`, `flaky`, or `by-design` for `bug-found` rows; `N/A` for all others

**Do NOT commit results.tsv** — it stays untracked.

### Data Growth Safety Limits

- Each section in `bug-hunt-context.md` keeps the **most recent N entries** (configurable via `context_history_limit` in `bug-hunt.toml`, default: 20). Archive older entries to `bug-hunt-context-archive.md`.
- When `results.tsv` exceeds **500 rows**, rename it to `results-archive-<timestamp>.tsv` and start a fresh `results.tsv`.
- Respect the `max_iterations` limit from `bug-hunt.toml` — stop the loop when reached.

## Update Context Note

After each iteration (regardless of outcome), update `bug-hunt-context.md`:

1. Update the relevant section (Test Coverage Gaps / Known Bugs / What Works)
2. Refresh the Ideas Backlog — remove tried ideas, add new ones if inspired
3. Update the Categories Tried table
4. Commit the context update: `git add bug-hunt-context.md && git commit -m "context: update after iteration <N>"`

## Update Strategy State

After each iteration, update `strategy-state.json` (see `adaptive-strategy.md` for details):

1. Read `strategy-state.json`
2. Identify the test type used in this iteration
3. Update counters:
   - `bug-found` → increment `bugs_found` for that type
   - `test-added` → increment `written` for that type
4. Recalculate weight: `new = old × (1 + 0.3 × (rate - avg_rate))`, clamp to [0.2, 3.0]
5. If `bug-found`: extract bug pattern, add to `bug_patterns` or increment count
6. Update `total_tests_written` and `total_bugs_found`
7. Set `last_updated` to current iteration number
8. Commit: `git add strategy-state.json && git commit -m "strategy: update after iteration <N>"`

**Stagnation check:** If last 20 iterations were all `test-added` (no bugs found), reset all weights to 1.0 and note in `bug-hunt-context.md`.

---

## → NEXT ITERATION

**You have finished one iteration. Immediately go back to "Before Each Iteration" and start the next one.**

Do NOT stop here. Do NOT summarize progress. Do NOT ask the user anything. Just increment your iteration counter and begin the next iteration. The only reasons to stop are:
1. `iteration >= max_iterations` from `bug-hunt.toml`
2. The human manually interrupts you

## NEVER STOP

Once the loop has begun, do NOT pause to ask the human if you should continue. Do NOT ask "should I keep going?" or "is this a good stopping point?". Do NOT produce a summary and wait. Do NOT say "let me know if you want me to continue." The human might be asleep or away and expects you to continue working **indefinitely** until manually stopped or `max_iterations` is reached.

**Common mistakes that cause premature stopping — AVOID these:**
- ❌ Stopping after a few iterations to "summarize progress so far"
- ❌ Asking "should I continue?" or "want me to keep going?"
- ❌ Deciding you've "done enough" or "covered the main areas"
- ❌ Stopping because a bug was found — record it and keep going
- ❌ Stopping because no bugs were found — keep writing more tests
- ❌ Stopping because the context feels large — trim it and keep going

You are autonomous. Writing tests keeps you busy forever:

**Always write more tests:**
- Find untested functions, methods, or modules
- Test edge cases: empty inputs, null values, boundary conditions, overflow
- Test error paths: what happens when things go wrong?
- Test concurrency: race conditions, deadlocks (if applicable)
- Test integration points: how components interact
- Look for missing validation: bad inputs, malformed data
- Check TODO/FIXME comments for known issues to write tests for
- Review code for complex logic that deserves test coverage

**When a bug is found:**
- Record it in `bug-hunt-context.md` under "Known Bugs"
- Log it to `results.tsv` with status `bug-found`
- Move on to writing the next test — do NOT fix the bug

The loop runs until the human interrupts you or `max_iterations` is reached.

## Simplicity Criterion

All else being equal, simpler is better:
- Tests should be clear and readable — test one thing per test function
- Prefer descriptive test names that explain what is being tested
- A focused test that exposes one specific bug is better than a broad test that might mask issues
