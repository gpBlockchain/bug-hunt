# bug-hunt

An autonomous bug-hunting and unit-test-writing skill for AI coding agents. Supports [OpenCode](https://github.com/opencode-ai/opencode) and [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

> 一个自动持续补单测、找 bug 的 AI 编程智能体 skill，支持 OpenCode 与 Claude Code。核心循环：写单测 → 发现 bug → 记录 → 继续写下一个测试，永不停歇。**只找 bug，不修复。**

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
| `SKILL.md` | Skill definition and workflow routing (OpenCode) |
| `CLAUDE.md` | Skill definition and workflow routing (Claude Code) |
| `.claude/commands/bug-hunt.md` | `/bug-hunt` slash command (Claude Code) |
| `setup.md` | Interactive first-run configuration |
| `loop.md` | Autonomous test-writing loop |
| `analysis.md` | Result analysis and recommendations |
| `bug-hunt.toml` | Configuration (test commands, framework, scope) |
| `bug-hunt-context.md` | Agent's knowledge base |

## Installation

### Quick Install (Recommended)

Run this one-liner in your project root to install for both Claude Code and OpenCode:

```bash
curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/install.sh | bash
```

Install for a specific agent only:

```bash
# Claude Code only
curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/install.sh | bash -s -- --claude

# OpenCode only
curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/install.sh | bash -s -- --opencode
```

### Manual Install

If you prefer to install manually, download the following files into your project root:

**Workflow files** (required):

```bash
# Download all workflow files
for f in setup.md loop.md analysis.md analysis-engine.md adaptive-strategy.md; do
  curl -fsSL "https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/$f" -o "$f"
done
```

**Claude Code** — add the CLAUDE.md instructions and slash command:

```bash
# Append bug-hunt instructions to CLAUDE.md (skip if already present)
grep -q "bug-hunt: Autonomous Unit-Test Writing" CLAUDE.md 2>/dev/null || \
  curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/CLAUDE.md >> CLAUDE.md
mkdir -p .claude/commands
curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/.claude/commands/bug-hunt.md -o .claude/commands/bug-hunt.md
```

**OpenCode** — add the skill definition:

```bash
curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/SKILL.md -o SKILL.md
```

### Uninstall

Remove the installed files:

```bash
rm -f setup.md loop.md analysis.md analysis-engine.md adaptive-strategy.md SKILL.md
rm -f .claude/commands/bug-hunt.md
# Manually remove bug-hunt section from CLAUDE.md if needed
```

## Usage

### OpenCode

Invoke the `bug-hunt` skill when you want to autonomously write unit tests and find bugs — using tests, linters, static analysis, or code review. The skill only finds bugs; it never modifies source code.

### Claude Code

Run the `/bug-hunt` slash command from the Claude Code prompt:

```
/bug-hunt
```

Or for analysis of a previous run:

```
/bug-hunt analysis
```
