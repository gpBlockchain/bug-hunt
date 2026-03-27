# Setup: Interactive Configuration

## Overview

Guide the user through configuring a bug-hunting run. This only runs once — subsequent runs use the saved config.

## Setup Flow

Ask the user these questions **one at a time**. Use multiple-choice when possible.

### Step 1: Bug Detection Commands

Ask: "What command(s) detect bugs in your codebase?"

Examples to suggest:
- `cargo test` / `pytest` / `go test ./...` (test suites)
- `cargo clippy` / `pylint src/` / `eslint src/` (linters)
- `cargo-fuzz run <target>` / `atheris` / `pythonfuzz` (fuzzing)
- Custom command

Multiple commands can be configured (e.g., run tests first, then lint). Run each command once to verify it works. Capture the full output.

### Step 2: Bug Metric Extraction

Show the command output to the user. Ask: "How should I count the number of bugs?"

Options:
- **Failing tests**: number of tests that fail (e.g., `FAILED 3` from pytest, `FAIL` lines from go test)
- **Lint warnings/errors**: number of warnings or errors reported by the linter
- **Regex pattern**: provide a regex to extract a bug count from the command output

Construct a regex pattern that extracts a bug count from the output. Verify the regex works by testing it against the captured output.

Common patterns:
- `(\d+) failed` — pytest failed test count
- `FAILED (\d+)` — alternative pytest format
- `(\d+) error` — compiler/linter error count
- `^(FAIL|FAIL\s)` — go test failure lines (count matches)
- Custom regex

Ask: "What should we call this metric?" (e.g., `failing_tests`, `lint_errors`, `bug_count`)

Direction is always **lower is better** — fewer bugs means progress.

### Step 3: Editable Scope

Ask: "What files/directories can I modify to fix bugs?"

Suggest a reasonable default based on the project structure. Also ask: "Any files/directories that are strictly off-limits?" (tests themselves should generally be read-only unless the user says otherwise; also exclude build configs, generated files).

### Step 4: Safety Timeout

Ask: "How long should I wait before killing a runaway test/lint command? (default: 5 minutes)"

### Step 5: Run Tag

Propose a tag based on today's date (e.g., `mar27`). The branch `bug-fix/<tag>` must not already exist.

## Generate Config

Write `bug-fix.toml`:

```toml
[detection]
commands = ["<detection command 1>", "<detection command 2>"]
metric_pattern = "<regex with capture group>"
metric_name = "<metric name>"
timeout_seconds = <timeout>

[scope]
editable = ["<directories or files>"]
readonly = ["<off-limits paths>"]
branch_prefix = "bug-fix"

[run]
tag = "<tag>"
max_consecutive_not_fixed = 3
baseline_runs = 1
```

## Establish Baseline

1. Create git branch: `git checkout -b bug-fix/<tag>`
2. Run all detection commands once
3. Record the bug count (baseline metric)
4. Report to user: "Baseline bug count: X bugs detected. Starting hunt."

## Initialize Results Log

Create `results.tsv` with header and baseline entry:

```
commit	bug_count	delta	status	description	hypothesis	bug_category
<hash>	<value>	0	baseline	initial bug count	establish baseline	baseline
```

Add `results.tsv` to `.gitignore` if not already there.

## Build Initial Context

Read the editable files thoroughly. Write `bug-fix-context.md`:

```markdown
# Bug-Fix Context

## Project Understanding
<Brief description of the codebase, what it does, and what the tests/linters check>

## Architecture Notes
<Key files, modules, data flow relevant to the bugs>

## Known Bugs
<List of bugs identified from the baseline run — failing tests, lint errors, etc.>
1. ...
2. ...
3. ...

## What Works
(None yet — baseline established)

## What Doesn't Work
(None yet)

## Ideas Backlog
<Initial fix ideas based on reading the code and errors, ordered by expected impact>
1. ...
2. ...
3. ...

## Bug Categories Tried
| Category | Attempts | Fixed | Last Tried |
|----------|----------|-------|------------|
```

Commit `bug-fix.toml` and `bug-fix-context.md` to git.

## Confirm and Go

Show the user a summary:
- Detection commands
- Metric: name, baseline value
- Editable scope
- Branch name
- Number of known bugs / initial ideas

Ask: "Ready to start the bug-hunting loop?"

On confirmation, proceed to `loop.md`.
