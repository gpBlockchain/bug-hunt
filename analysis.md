# Analysis: Summarize Bug-Hunting Results

## Overview

Generate a summary report of the bug-hunting run. Use when the user asks about progress, fixed bugs, or recommendations.

## Read the Data

1. Read `results.tsv` — parse all rows
2. Read `bug-fix.toml` — get metric name, detection commands, baseline info
3. Read `bug-fix-context.md` — get current understanding, known bugs, and what was tried

## Generate Report

### Summary Statistics

Compute and display:

```
## Bug-Fix Run: <tag>

**Total fix attempts:** <N>
**Fixed:** <N> (<pct>%)    **Not-fixed:** <N> (<pct>%)    **Regression:** <N> (<pct>%)    **Crashed:** <N> (<pct>%)

**Initial bug count (baseline):** <value>
**Current bug count:** <value>
**Total bugs fixed:** <delta>
```

### Timeline

List fix attempts in order, highlighting fixed bugs:

```
## Fix Timeline

| # | Status      | Bugs | Delta | Category       | Description                        |
|---|-------------|------|-------|----------------|------------------------------------|
| 1 | baseline    | 12   | -     | baseline       | initial bug count                  |
| 2 | fixed       | 10   | -2    | null-check     | add nil guard in user lookup       |
| 3 | not-fixed   | 12   | 0     | logic-error    | rewrite sort comparison function   |
| 4 | regression  | 13   | +1    | error-handling | wrap DB call in try/catch          |
| ...
```

Mark the current lowest bug count with an indicator.

### Category Breakdown

```
## Bug Categories

| Category        | Attempts | Fixed | Success Rate | Bugs Resolved |
|-----------------|----------|-------|--------------|---------------|
| null-check      | 3        | 2     | 67%          | 3             |
| logic-error     | 5        | 1     | 20%          | 1             |
| error-handling  | 2        | 0     | 0%           | -             |
```

### Key Findings

Summarize from `bug-fix-context.md`:
- **Top fixes**: List the resolved bugs ranked by impact (bugs fixed per attempt)
- **Failed approaches**: Brief summary of what didn't work and why
- **Remaining bugs**: Known bugs not yet fixed (from "Known Bugs" in context)
- **Potential bugs**: Suspected issues found via code review that aren't yet confirmed by tests

### Recommendations

Based on the data:
- Which bug categories are most common in this codebase?
- What areas of code are most bug-prone?
- Are there systemic issues (e.g., consistently missing error handling)?
- Are there remaining TODO/FIXME comments that indicate known issues?
- Should fuzzing or additional static analysis be added to the detection commands?

## Optional: Compare Branches

If multiple run tags exist (multiple `bug-fix/*` branches):

```bash
git branch --list 'bug-fix/*'
```

Compare final bug counts across runs. Show which run resolved the most bugs and what fix approaches were unique to each.
