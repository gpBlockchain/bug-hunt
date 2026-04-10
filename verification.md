# Verification: Bug Confirmation and False-Positive Filtering

## Overview

When a test fails and a potential bug is found, run this lightweight verification step **before** logging the finding to `results.tsv`. The goal is to distinguish real bugs from flaky tests, framework quirks, and test authoring mistakes — and to assign a confidence score to every confirmed finding.

## When to Run

After the **BUG-FOUND** outcome in the loop (test fails), and before logging to `results.tsv` and updating `bug-hunt-context.md`.

## Verification Checklist

Work through these checks in order. Stop as soon as one check determines the classification.

### Check 1 — Re-run the test (flakiness guard)

Run the full test suite a **second time** without any changes:

```bash
timeout <timeout_seconds> <test_command> > test-rerun.log 2>&1
```

- If the test **passes** on re-run → classify as `flaky`. Do not record as a bug.
- If the test **fails again** → proceed to Check 2.

### Check 2 — Review test preconditions

Read the failing test carefully:

- Do the inputs and setup state make sense for the function under test?
- Is the expected value correct and well-defined?
- Are there any typos or logic errors in the test itself?

If the test has an obvious authoring error → fix the test, re-run. If it passes after the fix → reclassify as `test-added`. If it still fails, proceed to Check 3.

### Check 3 — Check for external state dependencies

Does the test depend on:
- The current time (`Date.now()`, `time.time()`, `time.Now()`)
- Random numbers (`Math.random()`, `random.random()`)
- Network access or external services
- File system state outside the repo
- Environment variables that may not be set

If yes → classify as `flaky` (unstable external dependency). Do not record as a bug unless you can reproduce the failure deterministically by controlling the external dependency.

### Check 4 — Check framework design intent

Is the behavior consistent with the documented contract of the library or framework?

- Review any doc comments on the function under test
- Check for explicit `// by design` or `TODO: this is intentional` annotations
- Check if the test expectation contradicts the type signature or documented behavior

If the behavior is clearly intentional → classify as `by-design`. Note it in `bug-hunt-context.md` so the loop does not re-test the same pattern.

### Check 5 — Assess confidence

If none of the above checks eliminated the finding, it is a real bug. Assign a confidence score:

| Score | Meaning |
|-------|---------|
| 90–100 | Deterministic failure, clear incorrect output, unambiguous contract violation |
| 70–89  | Strong evidence of a bug; minor ambiguity about expected behavior |
| 50–69  | Plausible bug, but expected behavior could be argued either way |
| 30–49  | Uncertain — behavior is surprising but may be intentional |
| < 30   | Very low confidence — classify as `flaky` or `by-design` instead |

**Classification rules:**

| Confidence | Classification |
|------------|---------------|
| ≥ 70       | `confirmed`   |
| 50–69      | `likely`      |
| < 50       | `by-design` or `flaky` (use judgment) |

## Output

### results.tsv — additional columns

Append two columns at the end of every `bug-found` row:

```
... <confidence>	<verification>
```

- `confidence`: integer 0–100 (use `N/A` for non-bug rows)
- `verification`: `confirmed`, `likely`, `flaky`, `by-design`, or `N/A`

Example row:
```
a1b2c3d	write-test	42	3	1	bug-found	null deref in parse_input	missing null check on x	null-input	85	confirmed
```

### bug-hunt-context.md — Known Bugs section

When adding a bug entry to "Known Bugs", include the confidence score and classification:

```markdown
## Known Bugs
1. **[confirmed, 92]** `parse_input` crashes on null: test `test_parse_null` fails — no null guard before `x.length`
2. **[likely, 65]** `calculate_total` returns negative for empty cart — may be intentional fallback
```

## Classification Reference

| Label | Meaning | Action |
|-------|---------|--------|
| `confirmed` | Verified real bug with high confidence | Log to `results.tsv`, add to Known Bugs, continue |
| `likely` | Probably a bug but some ambiguity | Log to `results.tsv`, add to Known Bugs with note, continue |
| `flaky` | Test is unstable — not a reliable bug signal | Discard commit (`git reset --hard HEAD~1`), log with status `flaky`, do NOT add to Known Bugs |
| `by-design` | Behavior is intentional | Discard commit, log with status `by-design`, note in context to avoid re-testing |
