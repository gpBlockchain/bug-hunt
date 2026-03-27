# bug-fix

An autonomous bug-hunting, unit-test-writing, and bug-fixing skill for OpenCode.

> 一个自动持续补单测、找 bug、修 bug 的 OpenCode skill。核心循环：写单测 → 发现 bug → 修复 → 验证 → 保留或丢弃，永不停歇。

## Overview

This skill enables two tightly coupled activities running in a continuous loop:

1. **Write unit tests** — Add new tests to increase coverage, expose untested edge cases, and discover hidden bugs
2. **Find & fix bugs** — When tests fail (new or existing), propose fixes, verify them, keep fixes that pass, discard those that fail or regress

The agent alternates between writing tests and fixing bugs autonomously, growing the test suite while reducing the bug count.

## Inspiration

This project is inspired by [karpathy/autoresearch](https://github.com/karpathy/autoresearch) - Andrej Karpathy's research on autonomous code improvement through systematic experimentation.

## How It Works

1. **Setup**: Configure test commands, test framework, editable scope, and safety timeouts
2. **Loop**: The agent writes unit tests to find bugs, then fixes the bugs it finds — keeps going indefinitely
3. **Analysis**: View structured results, tests written, bugs fixed, and coverage progress over time

## Key Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill definition and workflow routing |
| `setup.md` | Interactive first-run configuration |
| `loop.md` | Autonomous test-writing and bug-fixing loop |
| `analysis.md` | Result analysis and recommendations |
| `bug-fix.toml` | Configuration (test commands, framework, scope) |
| `bug-fix-context.md` | Agent's knowledge base |

## Usage

Invoke the `bug-fix` skill when you want to autonomously write unit tests, find bugs, and fix them — using tests, linters, static analysis, or code review.
