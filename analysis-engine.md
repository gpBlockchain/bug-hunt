# Analysis Engine: Code Risk Scoring

## Overview

Analyze source code to identify bug-prone areas. Run once during Setup to generate `risk-map.json`. The loop references this map to select high-value test targets — no re-analysis needed per iteration.

## Analysis Dimensions

| Dimension | Weight | Risk Signal |
|-----------|--------|-------------|
| Complexity | 0.25 | Deep nesting (>5), many branches (>10), long functions (>50 lines) |
| Input handling | 0.30 | Missing null/empty checks, unvalidated external input, no type constraints |
| Error handling | 0.20 | No try/catch, swallowed errors, missing error returns |
| Data flow | 0.15 | Shared mutable state, race conditions, unguarded concurrent access |
| Dependency | 0.10 | Deep call chains (>5), unhandled external API errors, circular deps |

## Execution

1. Read all files in the `readonly` scope from `bug-hunt.toml`
2. For each file, identify functions/methods
3. Score each function on each dimension (0-10)
4. Compute weighted composite: `risk = Σ(dimension_score × dimension_weight)`
5. Suggest test types per function based on dimension scores
6. Write `risk-map.json`

## Scoring Rules

### Complexity
- 0-3: Simple, linear code, <3 branches
- 4-6: Moderate nesting, 3-8 branches
- 7-10: Deep nesting, >8 branches, >30 lines, multiple loops

### Input Handling
- 0-3: All inputs validated, typed, bounded
- 4-6: Some validation missing, partial type coverage
- 7-10: No null checks, raw external input used directly, no bounds

### Error Handling
- 0-3: All errors caught and propagated properly
- 4-6: Some error paths missing, partial coverage
- 7-10: No error handling, errors swallowed, silent failures

### Data Flow
- 0-3: Immutable data, no shared state
- 4-6: Some shared state, properly synchronized
- 7-10: Unguarded mutable state, callback hell, potential races

### Dependency
- 0-3: Shallow calls, all external errors handled
- 4-6: Moderate depth, some unchecked external calls
- 7-10: Deep chains, unchecked third-party calls, circular dependencies

## Test Type Mapping

| High Dimension | Suggested Test Types |
|----------------|---------------------|
| Input handling | null-input, boundary, malformed-input |
| Error handling | error-path, exception-propagation |
| Complexity | edge-case, branch-coverage |
| Data flow | concurrency, state-corruption |
| Dependency | integration, mock-failure |

## Output: risk-map.json

```json
{
  "generated_at": "2026-03-31",
  "modules": [
    {
      "file": "src/parser.py",
      "function": "parse_input",
      "line": 42,
      "risk_score": 8.5,
      "dimensions": {
        "complexity": 7,
        "input_handling": 9,
        "error_handling": 8,
        "data_flow": 6,
        "dependency": 5
      },
      "reasons": ["No null check on input parameter", "Nested 6 levels deep", "No exception handling"],
      "suggested_tests": ["null-input", "boundary", "error-path"]
    }
  ],
  "summary": {
    "total_functions": 120,
    "high_risk": 8,
    "medium_risk": 25,
    "low_risk": 87
  }
}
```

## Language-Specific Detection

### Python
- Functions: `def name(`, methods inside `class`
- Null checks: `if x is None`, `if not x`
- Error handling: `try/except`, `raise`
- Type hints: `: type` annotations

### TypeScript/JavaScript
- Functions: `function name(`, `const name = (`, methods in classes
- Null checks: `if (x == null)`, `if (!x)`, `x?.`
- Error handling: `try/catch`, `throw`, `.catch()`
- Types: `: type` annotations, interfaces

### Rust
- Functions: `fn name(`
- Null checks: `Option<T>`, `.unwrap()`, `.expect()`
- Error handling: `Result<T, E>`, `?` operator, `match`
- Ownership: `&`, `&mut`, `move`

### Go
- Functions: `func name(`
- Null checks: `if err != nil`, `if x == nil`
- Error handling: `error` returns, `defer`
- Concurrency: `go`, `chan`, `sync.Mutex`

## Deduplication

- Skip functions already in `risk-map.json` with unchanged source
- Re-score only when source file changes (compare git diff)
- If no source changes since last analysis, reuse existing map
