# Analysis: Summarize Test-Writing and Bug-Fixing Results

## Overview

Generate a summary report of the test-writing and bug-fixing run. Use when the user asks about progress, tests written, bugs fixed, or recommendations.

## Read the Data

1. Read `results.tsv` — parse all rows
2. Read `bug-fix.toml` — get test commands, framework, baseline info
3. Read `bug-fix-context.md` — get current understanding, coverage gaps, and known bugs

## Generate Report

### Summary Statistics

Compute and display:

```
## Bug-Fix Run: <tag>

### Tests Written
**Total test iterations:** <N>
**Tests added:** <N> (new tests that pass)
**Bugs found by new tests:** <N> (new tests that exposed bugs)

### Bugs Fixed
**Total fix attempts:** <N>
**Fixed:** <N> (<pct>%)    **Not-fixed:** <N> (<pct>%)    **Regression:** <N> (<pct>%)    **Crashed:** <N> (<pct>%)

### Overall Progress
**Baseline:** <X> tests (<Y> failing)
**Current:** <X> tests (<Y> failing)
**Tests added:** <delta_tests>
**Bugs fixed:** <delta_failing>
```

### Timeline

List all iterations in order:

```
## Timeline

| # | Type       | Status     | Total Tests | Failing | Delta | Category       | Description                            |
|---|------------|------------|-------------|---------|-------|----------------|----------------------------------------|
| 1 | baseline   | baseline   | 45          | 3       | -     | baseline       | initial state                          |
| 2 | write-test | test-added | 47          | 3       | 0     | edge-case      | add boundary tests for parse_date()    |
| 3 | write-test | bug-found  | 49          | 5       | +2    | null-input     | test nil handling in user_lookup()     |
| 4 | fix-bug    | fixed      | 49          | 3       | -2    | null-check     | add nil guard in user_lookup()         |
| 5 | fix-bug    | not-fixed  | 49          | 3       | 0     | logic-error    | rewrite sort comparison                |
| ...
```

Mark the current lowest failing count and highest test count with indicators.

### Category Breakdown

```
## Test-Writing Categories

| Category     | Tests Written | Bugs Found | Coverage Impact |
|--------------|---------------|------------|-----------------|
| edge-case    | 5             | 2          | high            |
| null-input   | 3             | 1          | medium          |
| error-path   | 2             | 0          | low             |

## Bug-Fix Categories

| Category        | Attempts | Fixed | Success Rate | Bugs Resolved |
|-----------------|----------|-------|--------------|---------------|
| null-check      | 3        | 2     | 67%          | 3             |
| logic-error     | 5        | 1     | 20%          | 1             |
| error-handling  | 2        | 0     | 0%           | -             |
```

### Key Findings

Summarize from `bug-fix-context.md`:
- **Tests added**: Summary of new test coverage areas
- **Top fixes**: List the resolved bugs ranked by impact
- **Failed approaches**: Brief summary of what didn't work and why
- **Remaining coverage gaps**: Areas still lacking tests
- **Remaining bugs**: Known bugs not yet fixed
- **Potential bugs**: Suspected issues found via code review not yet confirmed by tests

### Recommendations

Based on the data:
- Which areas of code have the most coverage gaps?
- Which bug categories are most common?
- What areas of code are most bug-prone?
- Are there systemic issues (e.g., consistently missing error handling)?
- What types of tests are most effective at finding bugs?
- Are there remaining TODO/FIXME comments that need tests?

## Optional: Compare Branches

If multiple run tags exist (multiple `bug-fix/*` branches):

```bash
git branch --list 'bug-fix/*'
```

Compare across runs: total tests added, bugs found, bugs fixed. Show which run was most productive and what approaches were unique to each.
