# Analysis: Summarize Test-Writing and Bug-Finding Results

## Overview

Generate a summary report of the test-writing and bug-finding run. Use when the user asks about progress, tests written, bugs found, or recommendations.

## Read the Data

1. Read `results.tsv` (and any agent-specific results files, e.g., `results-core.tsv`) — parse all rows
2. Read `bug-hunt.toml` — get test commands, framework, baseline info
3. Read `bug-hunt-context.md` — get current understanding, coverage gaps, and known bugs

## Generate Report

### Summary Statistics

Compute and display:

```
## Bug-Hunt Run: <tag>

### Tests Written
**Total test iterations:** <N>
**Tests added:** <N> (new tests that pass)
**Bugs found by new tests:** <N> (new tests that exposed bugs)

### Overall Progress
**Baseline:** <X> tests (<Y> failing)
**Current:** <X> tests (<Y> failing)
**Tests added:** <delta_tests>
**New bugs found:** <delta_bugs_found>
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
| 4 | write-test | test-added | 51          | 5       | 0     | error-path     | test error return in connect()         |
| 5 | write-test | bug-found  | 53          | 7       | +2    | boundary       | test overflow in counter increment     |
| ...
```

Mark the current highest bug-found count and highest test count with indicators.

### Category Breakdown

```
## Test-Writing Categories

| Category     | Tests Written | Bugs Found | Coverage Impact |
|--------------|---------------|------------|-----------------|
| edge-case    | 5             | 2          | high            |
| null-input   | 3             | 1          | medium          |
| error-path   | 2             | 0          | low             |

## Bug Categories

| Bug Category    | Count | Modules Affected        | Severity Estimate |
|-----------------|-------|-------------------------|-------------------|
| null-check      | 3     | user_lookup, parse_date | high              |
| logic-error     | 2     | counter, sort           | medium            |
| error-handling  | 1     | connect                 | low               |
```

### Multi-Agent Summary

If multiple agents ran in parallel, compare their findings:

```
## Multi-Agent Summary

| Agent       | Branch                  | Tests Written | Bugs Found | Top Bug Category |
|-------------|-------------------------|---------------|------------|-----------------|
| agent-core  | bug-hunt/<tag>-core     | 12            | 4          | null-check      |
| agent-api   | bug-hunt/<tag>-api      | 8             | 2          | error-handling  |
| agent-util  | bug-hunt/<tag>-util     | 6             | 1          | logic-error     |
| **Total**   |                         | **26**        | **7**      |                 |
```

### Key Findings

Summarize from `bug-hunt-context.md`:
- **Tests added**: Summary of new test coverage areas
- **Top bugs found**: List the discovered bugs ranked by impact
- **Most bug-prone modules**: Which modules have the highest bug density?
- **Remaining coverage gaps**: Areas still lacking tests
- **Remaining known bugs**: All bugs found, awaiting fixes
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

If multiple run tags exist (multiple `bug-hunt/*` branches):

```bash
git branch --list 'bug-hunt/*'
```

Compare across runs: total tests added, bugs found per run. Show which run was most productive and what approaches were unique to each.
