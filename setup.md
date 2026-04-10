# Setup: Interactive Configuration

## Overview

Guide the user through configuring the test-writing and bug-finding run. This only runs once — subsequent runs use the saved config.

## Setup Flow

Ask the user these questions **one at a time**. Use multiple-choice when possible.

### Step 1: Test Command

Ask: "What command runs your tests?"

Examples to suggest:
- `cargo test` / `pytest` / `go test ./...` / `npm test` / `jest`
- Custom command

Run the command once to verify it works. Capture the full output.

### Step 2: Additional Detection Commands (Optional)

Ask: "Any additional bug detection commands besides tests? (linters, static analysis, etc.)"

Examples to suggest:
- `cargo clippy` / `pylint src/` / `eslint src/` (linters)
- `mypy src/` / `tsc --noEmit` (type checking)
- None — tests only

### Step 3: Test Framework and Conventions

Ask: "What test framework do you use?"

Auto-detect from the project or ask:
- **Rust**: `#[test]`, `#[cfg(test)]` modules
- **Python**: `pytest` (files `test_*.py` or `*_test.py`), `unittest`
- **Go**: `_test.go` files, `func Test...`
- **JavaScript/TypeScript**: `jest`, `vitest`, `mocha` (files `*.test.ts`, `*.spec.ts`)
- Other

Ask: "Where should new test files be placed?" (e.g., `tests/`, `src/tests/`, alongside source files)

### Step 4: Bug Metric Extraction

Show the test command output. Ask: "How should I count the number of bugs/failures?"

Options:
- **Failing tests**: number of tests that fail (e.g., `FAILED 3` from pytest, `FAIL` lines from go test)
- **Lint warnings/errors**: number of warnings or errors reported by the linter
- **Regex pattern**: provide a regex to extract a bug count from the command output

Construct a regex pattern that extracts the count from the output. Verify the regex works.

Common patterns:
- `(\d+) failed` — pytest failed test count
- `(\d+) error` — compiler/linter error count
- `^(FAIL|FAIL\s)` — go test failure lines (count matches)
- Custom regex

Direction is always **lower is better** — fewer failing tests means progress.

### Step 5: Editable Scope

Ask: "What test directories can I write new tests into?"

**Important**: For this skill, only test files are modified — source code is always read-only.

- Test directories (`editable_tests`) — where the agent may add or update test files
- All source directories are automatically read-only

Also ask: "Any files/directories that are strictly off-limits?" (build configs, generated files, vendor dependencies).

### Step 6: Safety Timeout

Ask: "How long should I wait before killing a runaway test command? (default: 5 minutes)"

### Step 7: Code Risk Analysis

Ask: "Run code risk analysis now? (Recommended — generates risk map for smarter test selection)"

If yes:
1. Read all source files in the `readonly` scope
2. Follow `analysis-engine.md` to score each function on 6 dimensions (including Security)
3. Generate `risk-map.json`
4. Show summary: total functions, high/medium/low risk counts

If no: skip. Risk map will be generated on first loop iteration.

### Step 7a: Recon (Codebase Reconnaissance)

Immediately after risk analysis (whether run now or deferred), follow `recon.md` to:

1. Detect the project's tech stack (language, framework, ORM, auth)
2. Identify high-risk entry points (HTTP routes, WebSocket, queues, etc.)
3. Map trust boundaries (public → authenticated, authenticated → admin)
4. Write `recon-report.json`

This runs automatically — no user prompt needed. Show a brief summary of findings.

### Step 8: Coverage Configuration (Optional)

Ask: "Do you have a coverage tool? (e.g., `pytest --cov`, `nyc report`, `go test -cover`)"

If yes:
- Record the coverage command in `bug-hunt.toml` under `[coverage]`
- Coverage data will be used for novelty bonus calculation in test selection

If no: skip. Skill uses analysis-only mode.

### Step 9: Run Tag

Propose a tag based on today's date (e.g., `mar27`). The branch `bug-hunt/<tag>` must not already exist.

### Step 10: Iteration Limit

Ask: "What is the maximum number of iterations before the agent should stop? (default: 100)"

This prevents unbounded runs. The agent will stop after this many write-test iterations.

### Step 11: Multi-Agent Configuration (Optional)

Ask: "Do you want to run multiple agents in parallel, each covering a different module?"

If yes, ask for each agent:
- Agent name (e.g., `agent-core`, `agent-api`, `agent-util`)
- Readonly source scope for that agent (which module/directory it focuses on)
- Test directory for that agent
- Branch name (e.g., `bug-hunt/<tag>-core`)

Also ask:
- Maximum number of agents: `max_agents`
- Final merge branch: `final_branch` (e.g., `bug-hunt/merge-<tag>`)
- Report output file (e.g., `bug-hunt-report.md`)

## Generate Config

Write `bug-hunt.toml`:

```toml
[testing]
test_command = "<test command>"
additional_commands = ["<lint command>", "<type check command>"]
metric_pattern = "<regex with capture group>"
metric_name = "<metric name>"
timeout_seconds = <timeout>

[framework]
name = "<pytest|jest|go-test|cargo-test|...>"
test_dir = "<where test files go>"
test_pattern = "<file naming pattern, e.g. test_*.py>"

[scope]
editable_tests = ["<test directories>"]
readonly = ["<off-limits paths>"]
branch_prefix = "bug-hunt"

[run]
tag = "<tag>"
max_iterations = 100
context_history_limit = 20

[coverage]
command = "<optional coverage command>"
enabled = false

[strategy]
learning_rate = 0.3
weight_min = 0.2
weight_max = 3.0

# Optional: multi-agent configuration
[coordinator]
strategy = "by-module"
max_agents = 3

[[agents]]
name = "agent-core"
scope = ["src/core/"]
test_dir = "tests/core/"
branch = "bug-hunt/<tag>-core"
results = "results-core.tsv"

[[agents]]
name = "agent-api"
scope = ["src/api/"]
test_dir = "tests/api/"
branch = "bug-hunt/<tag>-api"
results = "results-api.tsv"

[merge]
final_branch = "bug-hunt/merge-<tag>"
report = "bug-hunt-report.md"
```

## Establish Baseline

1. Create git branch: `git checkout -b bug-hunt/<tag>`
2. Run all test/detection commands once
3. Record: total tests, passing tests, failing tests, lint errors
4. Report to user: "Baseline: X tests (Y passing, Z failing). Starting hunt."

## Initialize Results Log

Create `results.tsv` with header and baseline entry:

```
commit	type	tests_total	tests_failing	delta	status	description	hypothesis	category	confidence	verification
<hash>	baseline	<total>	<failing>	0	baseline	initial state	establish baseline	baseline	N/A	N/A
```

Add `results.tsv` to `.gitignore` if not already there.

## Build Initial Context

Read the editable files thoroughly. Write `bug-hunt-context.md`:

```markdown
# Bug-Hunt Context

## Project Understanding
<Brief description of the codebase, what it does, and what the tests cover>

## Test Coverage Gaps
<Areas of the code with poor or no test coverage>
1. ...
2. ...
3. ...

## Known Bugs
<List of bugs identified from the baseline run — failing tests, lint errors, etc.>
1. ...
2. ...

## What Works
(None yet — baseline established)

## Ideas Backlog — Tests to Write
<Areas to add unit tests, ordered by expected impact>
1. ...
2. ...
3. ...

## Categories Tried
| Category | Type | Attempts | Kept | Last Tried |
|----------|------|----------|------|------------|
```

Commit `bug-hunt.toml` and `bug-hunt-context.md` to git.

## Initialize Strategy State

Create `strategy-state.json` with default weights:

```json
{
  "test_types": {
    "null-input":       { "written": 0, "bugs_found": 0, "weight": 1.0 },
    "boundary":         { "written": 0, "bugs_found": 0, "weight": 1.0 },
    "error-path":       { "written": 0, "bugs_found": 0, "weight": 1.0 },
    "edge-case":        { "written": 0, "bugs_found": 0, "weight": 1.0 },
    "concurrency":      { "written": 0, "bugs_found": 0, "weight": 1.0 },
    "regression":       { "written": 0, "bugs_found": 0, "weight": 1.0 },
    "malformed-input":  { "written": 0, "bugs_found": 0, "weight": 1.0 },
    "state-corruption": { "written": 0, "bugs_found": 0, "weight": 1.0 },
    "injection":        { "written": 0, "bugs_found": 0, "weight": 1.0 },
    "auth-bypass":      { "written": 0, "bugs_found": 0, "weight": 1.0 },
    "idor":             { "written": 0, "bugs_found": 0, "weight": 1.0 },
    "input-overflow":   { "written": 0, "bugs_found": 0, "weight": 1.0 },
    "secret-leak":      { "written": 0, "bugs_found": 0, "weight": 1.0 }
  },
  "bug_patterns": [],
  "last_updated": "setup",
  "total_tests_written": 0,
  "total_bugs_found": 0
}
```

Commit `strategy-state.json` to git.

## Confirm and Go

Show the user a summary:
- Test command and framework
- Metric: name, baseline value (total tests, failing tests)
- Editable test scope (test directories only)
- Branch name
- Risk analysis: total functions scored, high/medium/low risk counts (if run)
- Recon: tech stack, high-risk entry points count, trust boundaries count
- Coverage: enabled/disabled
- Number of coverage gaps / known bugs / initial ideas
- Multi-agent plan (if configured)

Ask: "Ready to start? The agent will continuously write tests to find bugs."

On confirmation, proceed to `loop.md`.
