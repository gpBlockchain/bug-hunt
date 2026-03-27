# Setup: Interactive Configuration

## Overview

Guide the user through configuring a benchmark optimization run. This only runs once — subsequent runs use the saved config.

## Setup Flow

Ask the user these questions **one at a time**. Use multiple-choice when possible.

### Step 1: Benchmark Command

Ask: "What command runs your benchmark?"

Examples to suggest:
- `cargo bench --bench <name>`
- `python -m pytest tests/bench.py --benchmark-only`
- `go test -bench=. ./...`
- `hyperfine './my_program'`
- Custom command

Run the command once to verify it works. Capture the full output.

### Step 2: Metric Extraction

Show the benchmark output to the user. Ask: "Which number is the metric to optimize?"

Help them identify the metric. Then construct a regex pattern that extracts it from the output. Verify the regex works by testing it against the captured output.

Common patterns:
- `time:\s+\[([\d.]+)` — Rust criterion
- `([\d.]+)\s+ns/iter` — Rust built-in bench
- `Min:\s+([\d.]+)` — hyperfine
- Custom regex

Ask: "What should we call this metric?" (e.g., `median_ns`, `throughput_ops`, `p99_latency_ms`)

### Step 3: Optimization Direction

Ask: "Is lower better (latency, time) or higher better (throughput, ops/sec)?"

### Step 4: Editable Scope

Ask: "What files/directories can I modify to optimize this?"

Suggest a reasonable default based on the project structure. Also ask: "Any files/directories that are strictly off-limits?" (benchmarks themselves, tests, build configs should generally be read-only).

### Step 5: Safety Timeout

Ask: "How long should I wait before killing a runaway benchmark? (default: 5x the baseline runtime)"

### Step 6: Run Tag

Propose a tag based on today's date (e.g., `mar27`). The branch `bench-optimize/<tag>` must not already exist.

## Generate Config

Write `bench-optimize.toml`:

```toml
[benchmark]
command = "<user's benchmark command>"
metric_pattern = "<regex with capture group>"
metric_name = "<metric name>"
direction = "<lower|higher>"
timeout_seconds = <timeout>

[scope]
editable = ["<directories or files>"]
readonly = ["<off-limits paths>"]
branch_prefix = "bench-optimize"

[experiment]
tag = "<tag>"
max_consecutive_fails = 3
baseline_runs = 3
variance_threshold_pct = <computed after baseline>
```

## Establish Baseline

1. Create git branch: `git checkout -b bench-optimize/<tag>`
2. Run the benchmark `baseline_runs` times (default 3)
3. Record each result
4. Compute variance: `(max - min) / mean * 100`
5. Set `variance_threshold_pct` to `max(1.0, 2 * computed_variance)` — improvements must exceed this to count
6. Report to user: "Baseline metric: X (variance: Y%). Changes must improve by at least Z% to be kept."

## Initialize Results Log

Create `results.tsv` with header and baseline entry:

```
commit	metric	delta_pct	status	description	hypothesis	approach_category
<hash>	<value>	0.0	keep	baseline	establish baseline performance	baseline
```

Add `results.tsv` to `.gitignore` if not already there.

## Build Initial Context

Read the editable files thoroughly. Write `bench-optimize-context.md`:

```markdown
# Benchmark Optimization Context

## Project Understanding
<Brief description of the codebase, what the program does, and what the benchmark measures>

## Architecture Notes
<Key files, hot paths, data flow relevant to performance>

## What Works
(None yet — baseline established)

## What Doesn't Work
(None yet)

## Ideas Backlog
<Initial optimization ideas based on reading the code, ordered by expected impact>
1. ...
2. ...
3. ...

## Approach Categories Tried
| Category | Attempts | Kept | Last Tried |
|----------|----------|------|------------|
```

Commit `bench-optimize.toml` and `bench-optimize-context.md` to git.

## Confirm and Go

Show the user a summary:
- Benchmark command
- Metric: name, direction, baseline value, variance threshold
- Editable scope
- Branch name
- Number of initial ideas

Ask: "Ready to start the optimization loop?"

On confirmation, proceed to `loop.md`.
