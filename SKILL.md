---
name: bug-fix
description: Use when continuously hunting and fixing bugs in a codebase — finds bugs via tests/linters/static-analysis, proposes fixes, verifies them, runs indefinitely without supervision
---

# bug-fix: Autonomous Bug-Hunting and Fixing

## Overview

Continuously find and fix bugs by proposing code fixes, running tests and linters, and keeping fixes that pass while discarding those that fail or introduce regressions.

## When to Use

- User wants to find and fix bugs autonomously
- There is a test suite, linter, or other bug detection tool
- The process should run autonomously without supervision

## Routing

```dot
digraph routing {
    "User invokes bug-fix" [shape=doublecircle];
    "bug-fix.toml exists?" [shape=diamond];
    "Load setup.md" [shape=box];
    "User asks for analysis?" [shape=diamond];
    "Load analysis.md" [shape=box];
    "Load loop.md" [shape=box];

    "User invokes bug-fix" -> "bug-fix.toml exists?";
    "bug-fix.toml exists?" -> "Load setup.md" [label="no"];
    "bug-fix.toml exists?" -> "User asks for analysis?" [label="yes"];
    "User asks for analysis?" -> "Load analysis.md" [label="yes"];
    "User asks for analysis?" -> "Load loop.md" [label="no"];
}
```

### First run (no config)

Follow `setup.md` to interactively configure the bug detection commands, editable scope, and baseline.

### Subsequent runs (config exists)

Follow `loop.md` to run the bug-hunting loop. The agent reads the config, context note, and recent history, then enters the autonomous fix loop.

### Analysis

Follow `analysis.md` when the user asks for a summary of results, fixed bugs, or recommendations.

## Key Files

| File | Tracked in git? | Purpose |
|------|-----------------|---------|
| `bug-fix.toml` | Yes | Configuration: detection commands, metric, scope, timeouts |
| `bug-fix-context.md` | Yes | Agent's living knowledge base: what works, what doesn't, known bugs |
| `results.tsv` | No (gitignored) | Structured fix log with bug counts and descriptions |

## Quick Reference

- **fixed**: fix applied and all detection commands pass
- **not-fixed**: fix didn't resolve the bug or detection commands still fail
- **regression**: fix caused previously passing tests to fail
- **crash**: detection command failed to run — fix if trivial, skip if fundamental
- **Branch**: `bug-fix/<tag>` — each fix attempt is a commit, discards are `git reset --hard`
