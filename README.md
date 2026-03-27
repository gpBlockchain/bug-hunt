# bug-fix

An autonomous bug-hunting and fixing skill for OpenCode.

> 一个自动持续找 bug、修复 bug 的 OpenCode skill。核心循环：发现 bug → 提出修复 → 验证 → 保留或丢弃。

## Overview

This skill enables continuous discovery and repair of bugs by proposing code fixes, running tests and linters, and intelligently keeping fixes that pass while discarding those that fail or introduce regressions.

## Inspiration

This project is inspired by [karpathy/autoresearch](https://github.com/karpathy/autoresearch) - Andrej Karpathy's research on autonomous code improvement through systematic experimentation.

## How It Works

1. **Setup**: Configure bug detection commands, metric extraction, editable scope, and safety timeouts
2. **Loop**: The agent finds bugs, proposes fixes, verifies them, and keeps fixes that pass
3. **Analysis**: View structured results, fixed bugs, and remaining issues over time

## Key Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill definition and workflow routing |
| `setup.md` | Interactive first-run configuration |
| `loop.md` | Autonomous bug-hunting and fixing loop |
| `analysis.md` | Result analysis and recommendations |
| `bug-fix.toml` | Bug-hunting configuration |
| `bug-fix-context.md` | Agent's knowledge base |

## Usage

Invoke the `bug-fix` skill when you want to autonomously find and fix bugs in a codebase using tests, linters, static analysis, or fuzzing.
