# Setup: Interactive Configuration

## Overview

Guide the user through configuring the test-writing and bug-fixing run. This only runs once — subsequent runs use the saved config.

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

Ask: "What files/directories can I modify?"

**Important**: For this skill, both source files AND test files should generally be editable. Suggest:
- Source code directories (for bug fixes)
- Test directories (for writing new tests)

Also ask: "Any files/directories that are strictly off-limits?" (build configs, generated files, vendor dependencies).

### Step 6: Safety Timeout

Ask: "How long should I wait before killing a runaway test command? (default: 5 minutes)"

### Step 7: Code Risk Analysis

Ask: "Run code risk analysis now? (Recommended — generates risk map for smarter test selection)"

If yes:
1. Read all files in `editable_src`
2. Follow `analysis-engine.md` to score each function on 5 dimensions
3. Generate `risk-map.json`
4. Show summary: total functions, high/medium/low risk counts

If no: skip. Risk map will be generated on first loop iteration.

### Step 8: Coverage Configuration (Optional)

Ask: "Do you have a coverage tool? (e.g., `pytest --cov`, `nyc report`, `go test -cover`)"

If yes:
- Record the coverage command in `bug-fix.toml` under `[coverage]`
- Coverage data will be used for novelty bonus calculation in test selection

If no: skip. Skill uses analysis-only mode.

### Step 9: Run Tag

Propose a tag based on today's date (e.g., `mar27`). The branch `bug-fix/<tag>` must not already exist.

## Generate Config

Write `bug-fix.toml`:

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
editable_src = ["<source directories>"]
editable_tests = ["<test directories>"]
readonly = ["<off-limits paths>"]
branch_prefix = "bug-fix"

[run]
tag = "<tag>"
max_consecutive_not_fixed = 3

[coverage]
command = "<optional coverage command>"
enabled = false

[strategy]
learning_rate = 0.3
weight_min = 0.2
weight_max = 3.0
```

## Establish Baseline

1. Create git branch: `git checkout -b bug-fix/<tag>`
2. Run all test/detection commands once
3. Record: total tests, passing tests, failing tests, lint errors
4. Report to user: "Baseline: X tests (Y passing, Z failing). Starting hunt."

## Initialize Results Log

Create `results.tsv` with header and baseline entry:

```
commit	type	tests_total	tests_failing	delta	status	description	hypothesis	category
<hash>	baseline	<total>	<failing>	0	baseline	initial state	establish baseline	baseline
```

Add `results.tsv` to `.gitignore` if not already there.

## Build Initial Context

Read the editable files thoroughly. Write `bug-fix-context.md`:

```markdown
# Bug-Fix Context

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

## What Doesn't Work
(None yet)

## Ideas Backlog — Tests to Write
<Areas to add unit tests, ordered by expected impact>
1. ...
2. ...
3. ...

## Ideas Backlog — Bugs to Fix
<Fix ideas based on reading the code and errors>
1. ...
2. ...

## Categories Tried
| Category | Type | Attempts | Kept | Last Tried |
|----------|------|----------|------|------------|
```

Commit `bug-fix.toml` and `bug-fix-context.md` to git.

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
    "state-corruption": { "written": 0, "bugs_found": 0, "weight": 1.0 }
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
- Editable scope (source + tests)
- Branch name
- Risk analysis: total functions scored, high/medium/low risk counts (if run)
- Coverage: enabled/disabled
- Number of coverage gaps / known bugs / initial ideas

Ask: "Ready to start? The agent will continuously write tests and fix bugs."

On confirmation, proceed to `loop.md`.
