# Analysis: Summarize Experiment Results

## Overview

Generate a summary report of the benchmark optimization run. Use when the user asks about progress, results, or recommendations.

## Read the Data

1. Read `results.tsv` — parse all rows
2. Read `bench-optimize.toml` — get metric name, direction, baseline info
3. Read `bench-optimize-context.md` — get current understanding

## Generate Report

### Summary Statistics

Compute and display:

```
## Optimization Run: <tag>

**Total experiments:** <N>
**Kept:** <N> (<pct>%)    **Discarded:** <N> (<pct>%)    **Crashed:** <N> (<pct>%)

**Baseline <metric_name>:** <value>
**Current best <metric_name>:** <value>
**Total improvement:** <delta_pct>% (<direction>)
```

### Timeline

List experiments in order, highlighting keeps:

```
## Experiment Timeline

| # | Status | Metric | Delta | Category | Description |
|---|--------|--------|-------|----------|-------------|
| 1 | keep   | 1234   | -     | baseline | baseline    |
| 2 | keep   | 1198   | +2.9% | allocation | pre-allocate Vec in hot loop |
| 3 | discard| 1245   | -3.9% | caching  | lazy_static lookup table |
| ...
```

Mark the current running best with an indicator.

### Category Breakdown

```
## Approach Categories

| Category | Attempts | Kept | Success Rate | Best Delta |
|----------|----------|------|--------------|------------|
| allocation | 3 | 2 | 67% | +4.2% |
| algorithm  | 5 | 1 | 20% | +1.1% |
| caching    | 2 | 0 | 0%  | -     |
```

### Key Findings

Summarize from `bench-optimize-context.md`:
- **Top improvements**: List the kept changes ranked by delta
- **Failed approaches**: Brief summary of what didn't work and why
- **Remaining opportunities**: Ideas from the backlog not yet tried

### Recommendations

Based on the data:
- Which categories are most promising?
- What approach would you try next?
- Is there diminishing returns? (last N experiments all discarded)
- Should the variance threshold be adjusted? (if many borderline cases)

## Optional: Compare Branches

If multiple run tags exist (multiple `bench-optimize/*` branches):

```bash
git branch --list 'bench-optimize/*'
```

Compare final metrics across runs. Show which run achieved the best result and what approaches were unique to each.
