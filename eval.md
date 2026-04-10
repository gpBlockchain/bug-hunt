# Evaluation: Measuring Bug-Hunt Effectiveness

## Overview

Run bug-hunt against a controlled test fixture with known planted bugs to measure how well the skill performs. Use this to validate that the skill is working, to benchmark improvements, and to catch regressions.

## Invocation

```
/bug-hunt --eval
```

When the user invokes bug-hunt with the `--eval` flag, follow this file instead of `setup.md` / `loop.md`.

## Test Fixture Setup

Create a `test-fixtures/` directory in the target project with intentionally buggy code. Plant exactly these bugs:

| # | Bug Type | Description |
|---|----------|-------------|
| 1 | null-handling | Function crashes when passed `null` / `None` / `undefined` |
| 2 | null-handling | Method dereferences a nullable field without a guard |
| 3 | boundary/off-by-one | Loop runs one iteration too many (off-by-one) |
| 4 | boundary/off-by-one | Array index is off by one at the boundary |
| 5 | error-handling | Exception is swallowed silently, error is not propagated |
| 6 | concurrency/state | Shared mutable state modified without synchronization |
| 7 | security/injection | User input passed directly to a raw SQL query or shell command |

Name the fixture files clearly: `fixtures/buggy_null.py`, `fixtures/buggy_boundary.py`, etc. (adapt extension to the project language).

**Important:** Planted bugs must be real, reproducible, and testable. Each bug must be detectable by at least one unit test.

## Eval Loop

Run the standard bug-hunt loop (`loop.md`) with the following overrides:

- `readonly` scope: `test-fixtures/` only
- `max_iterations`: 30 (hard cap for eval)
- Branch: `bug-hunt/eval-<date>`
- Results log: `eval-results.tsv`

Track which planted bugs are found vs missed.

## Benchmark Metrics

After the eval run (or when `max_iterations` is reached), compute:

| Metric | Formula |
|--------|---------|
| Detection rate | bugs_found / planted_bugs |
| False positive rate | confirmed_non_bugs / total_findings |
| Efficiency | bugs_found / total_tests_written |
| Coverage | functions_tested / total_functions |
| Time to first bug | iterations before first `bug-found` result |

**Target thresholds** (for a healthy skill):

| Metric | Target |
|--------|--------|
| Detection rate | ≥ 0.70 |
| False positive rate | ≤ 0.10 |
| Efficiency | ≥ 0.25 |
| Time to first bug | ≤ 5 |

## Effectiveness Report

Write `eval-report.json` after the eval run:

```json
{
  "planted_bugs": 7,
  "bugs_found": 5,
  "false_positives": 1,
  "total_tests_written": 15,
  "detection_rate": 0.71,
  "false_positive_rate": 0.067,
  "efficiency": 0.33,
  "coverage": 0.80,
  "time_to_first_bug": 3,
  "missed_bugs": [
    { "id": 6, "type": "concurrency/state", "reason": "No concurrency test types selected" }
  ],
  "eval_date": "<YYYY-MM-DD>"
}
```

Commit `eval-report.json`:

```bash
git add eval-report.json && git commit -m "eval: write eval-report.json"
```

## Interpreting Results

### Detection rate < 0.70

The skill is missing bugs. Possible causes:
- Test type weights are miscalibrated — reset `strategy-state.json`
- Risk analysis missed the buggy functions — re-run `analysis-engine.md`
- Recon did not identify the fixture as a high-risk entry point

### False positive rate > 0.10

Too many false alarms. Possible causes:
- Verification step (`verification.md`) is not being applied
- Tests are relying on unstable external state

### Efficiency < 0.25

Too many tests written before finding bugs. Possible causes:
- Novelty bonus is dominating — the loop is exploring too broadly
- Risk scores are not differentiating high vs low risk functions

### Time to first bug > 5

The loop is slow to start finding bugs. Possible causes:
- Stagnation: adaptive weights have converged to a low-finding region
- Missing recon: security-oriented test types not being selected for entry points

## Continuous Evaluation

Re-run eval periodically (after significant changes to the skill) to track improvement over time. Compare `eval-report.json` files across runs.
