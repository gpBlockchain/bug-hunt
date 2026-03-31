# bug-hunt

An autonomous bug-hunting and unit-test-writing skill for OpenCode.

> 一个自动持续补单测、找 bug 的 OpenCode skill。核心循环：写单测 → 发现 bug → 记录 → 继续写下一个测试，永不停歇。**只找 bug，不修复。**

## Overview

This skill focuses on one activity: finding bugs by writing tests.

1. **Write unit tests** — Add new tests to increase coverage, expose untested edge cases, and discover hidden bugs

The agent writes tests autonomously, recording every bug it finds — without attempting to fix anything. Multiple agents can run in parallel, each covering a different module.

## Inspiration

This project is inspired by [karpathy/autoresearch](https://github.com/karpathy/autoresearch) - Andrej Karpathy's research on autonomous code improvement through systematic experimentation.

## How It Works

1. **Setup**: Configure test commands, test framework, editable test scope, and safety timeouts
2. **Loop**: The agent writes unit tests to find bugs — records every bug found and keeps going indefinitely
3. **Analysis**: View structured results, tests written, bugs found, and coverage progress over time

## Key Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill definition and workflow routing |
| `setup.md` | Interactive first-run configuration |
| `loop.md` | Autonomous test-writing loop |
| `analysis.md` | Result analysis and recommendations |
| `bug-hunt.toml` | Configuration (test commands, framework, scope) |
| `bug-hunt-context.md` | Agent's knowledge base |

## Usage

Invoke the `bug-hunt` skill when you want to autonomously write unit tests and find bugs — using tests, linters, static analysis, or code review. The skill only finds bugs; it never modifies source code.
