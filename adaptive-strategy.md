# Adaptive Strategy: Self-Learning Test Selection

## Overview

Learn from test results to select the most effective test types and targets. Maintains `strategy-state.json` with weights and bug patterns. Updates after each loop iteration.

## Test Type Weights

Each test type has a weight (default 1.0) that adjusts based on effectiveness:

| Test Type | Description |
|-----------|-------------|
| null-input | Tests with null/None/undefined/empty inputs |
| boundary | Tests at boundary values (0, max, -1, empty string) |
| error-path | Tests error handling and exception paths |
| edge-case | Unusual but valid inputs, corner cases |
| concurrency | Race conditions, parallel access |
| regression | Tests for previously fixed bugs |
| malformed-input | Invalid format, wrong types, injection |
| state-corruption | Mutable state manipulation, ordering issues |
| injection | SQL injection, command injection, path traversal via test inputs |
| auth-bypass | Tests for authentication/authorization bypass scenarios |
| idor | Tests for insecure direct object reference (accessing other users' data) |
| input-overflow | Integer overflow, buffer limits, extremely large inputs |
| secret-leak | Tests that verify secrets/tokens aren't exposed in logs/responses |

## Weight Update

After each iteration, update the weight for the test type used:

```
rate = bugs_found_this_type / total_written_this_type
avg_rate = total_bugs_found / total_tests_written
new_weight = old_weight × (1 + α × (rate - avg_rate))
```

- `α = 0.3` (learning rate, configurable in `bug-hunt.toml`)
- Clamp: `min(3.0, max(0.2, new_weight))`

**Effect:** High-bug-finding types gain weight, low-finding types lose weight.

## Composite Scoring

When selecting a test target in Write-Test mode, score each candidate:

```
score = risk_score × 0.4 + type_weight × 0.35 + novelty_bonus × 0.25
```

- **risk_score**: From `risk-map.json` (0-10, normalized to 0-1)
- **type_weight**: From `strategy-state.json` (0.2-3.0, normalized to 0-1)
- **novelty_bonus**: 1.0 if function never tested, ×0.7 per previous test, min 0.1

Select the highest-scoring (function, test_type) pair.

## Bug Pattern Learning

When a bug is found, record the pattern:

```json
{
  "pattern": "missing null check",
  "test_type": "null-input",
  "function": "parse_input",
  "file": "src/parser.py",
  "iteration": 15
}
```

**Reuse:** When targeting a new function, check if its code pattern matches recorded bugs. If so, prioritize the test type that found the similar bug.

## Output: strategy-state.json

```json
{
  "test_types": {
    "null-input":       { "written": 12, "bugs_found": 5, "weight": 1.8 },
    "boundary":         { "written": 8,  "bugs_found": 3, "weight": 1.5 },
    "error-path":       { "written": 15, "bugs_found": 1, "weight": 0.6 },
    "edge-case":        { "written": 10, "bugs_found": 4, "weight": 1.6 },
    "concurrency":      { "written": 3,  "bugs_found": 2, "weight": 2.0 },
    "regression":       { "written": 5,  "bugs_found": 0, "weight": 0.4 },
    "malformed-input":  { "written": 0,  "bugs_found": 0, "weight": 1.0 },
    "state-corruption": { "written": 0,  "bugs_found": 0, "weight": 1.0 },
    "injection":        { "written": 0,  "bugs_found": 0, "weight": 1.0 },
    "auth-bypass":      { "written": 0,  "bugs_found": 0, "weight": 1.0 },
    "idor":             { "written": 0,  "bugs_found": 0, "weight": 1.0 },
    "input-overflow":   { "written": 0,  "bugs_found": 0, "weight": 1.0 },
    "secret-leak":      { "written": 0,  "bugs_found": 0, "weight": 1.0 }
  },
  "bug_patterns": [
    { "pattern": "missing null check", "count": 5, "test_type": "null-input" },
    { "pattern": "off-by-one", "count": 3, "test_type": "boundary" },
    { "pattern": "unhandled exception", "count": 2, "test_type": "error-path" }
  ],
  "last_updated": "iteration_42",
  "total_tests_written": 53,
  "total_bugs_found": 15
}
```

## Configuration

In `bug-hunt.toml`:

```toml
[strategy]
learning_rate = 0.3
weight_min = 0.2
weight_max = 3.0
```

## Update Procedure

After each loop iteration:

1. Read `strategy-state.json`
2. Identify the test type used in this iteration
3. If result is `bug-found`: increment `bugs_found` for that type
4. If result is `test-added`: increment `written` for that type
5. Recalculate weight using the formula
6. If `bug-found`: extract bug pattern, add to `bug_patterns` (or increment existing)
7. Update `total_tests_written` and `total_bugs_found`
8. Write `strategy-state.json`
9. Commit: `git add strategy-state.json && git commit -m "strategy: update after iteration N"`

## Stagnation Detection

If no bugs found in last 20 test-added iterations:
- Reset all weights to 1.0 (escape local minimum)
- Log warning to `bug-hunt-context.md`
- Consider switching to untested test types (weight boost for types with `written: 0`)

## Fuzz Testing Strategy

When test types `malformed-input`, `injection`, or `input-overflow` are selected, apply fuzzing principles:

### Fuzz Input Generation

- **Boundary values**: `0`, `-1`, `MAX_INT`, `MIN_INT`, empty string, very long string (10000+ chars)
- **Special characters**: `'`, `"`, `\`, `<script>`, `../`, `; DROP TABLE`, null bytes (`\x00`)
- **Type confusion**: pass string where int expected, array where object expected, null where required
- **Format strings**: `%s`, `%x`, `${...}`, `{{...}}`
- **Unicode edge cases**: RTL characters, zero-width joiners, emoji, mixed encodings

### Fuzz Test Template

When writing a fuzz-style test, generate multiple inputs from the categories above and assert that the function either:
1. Returns a valid result, OR
2. Throws a well-defined error (not an unhandled exception or crash)

Never assert that the function silently ignores invalid input without signaling an error.

