# bug-hunt

An autonomous bug-hunting and unit-test-writing skill for AI coding agents. Supports [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [OpenCode](https://github.com/opencode-ai/opencode), [Cursor](https://cursor.sh), [Codex](https://openai.com/index/codex/), and [Gemini CLI](https://github.com/google-gemini/gemini-cli).

> 一个自动持续补单测、找 bug 的 AI 编程智能体 skill，支持 Claude Code、OpenCode、Cursor、Codex、Gemini CLI。核心循环：写单测 → 发现 bug → 记录 → 继续写下一个测试，永不停歇。**只找 bug，不修复。**

## Overview

This skill focuses on one activity: finding bugs by writing tests.

1. **Write unit tests** — Add new tests to increase coverage, expose untested edge cases, and discover hidden bugs

The agent writes tests autonomously, recording every bug it finds — without attempting to fix anything. Multiple agents can run in parallel, each covering a different module.

## Inspiration

This project is inspired by [karpathy/autoresearch](https://github.com/karpathy/autoresearch) - Andrej Karpathy's research on autonomous code improvement through systematic experimentation.

## Installation

### Quick Install (All Agents)

Install to any supported agent (Claude Code, Cursor, Codex, OpenCode, Gemini CLI, GitHub Copilot, and [40+ more](https://github.com/vercel-labs/skills#supported-agents)) using the [skills CLI](https://skills.sh):

```bash
npx skills add gpBlockchain/bug-hunt
```

Browse on the skills directory: [skills.sh](https://skills.sh)

### Platform-specific Installation

Choose the method for your coding agent below.

#### Claude Code (via Plugin Marketplace)

In Claude Code, register the marketplace first:

```bash
/plugin marketplace add gpBlockchain/bug-hunt
```

Then install the plugin:

```bash
/plugin install bug-hunt@bug-hunt-dev
```

#### Claude Code (Manual)

Clone into your project and the skill is auto-discovered via `CLAUDE.md`:

```bash
git clone https://github.com/gpBlockchain/bug-hunt.git
```

Then use the `/bug-hunt` slash command.

#### Cursor

In Cursor Agent chat, install from marketplace:

```text
/add-plugin bug-hunt
```

Or search for "bug-hunt" in the plugin marketplace.

#### Codex

Tell Codex:

```
Fetch and follow instructions from https://raw.githubusercontent.com/gpBlockchain/bug-hunt/refs/heads/main/.codex/INSTALL.md
```

**Detailed docs:** [.codex/INSTALL.md](.codex/INSTALL.md)

#### OpenCode

Add to your `opencode.json`:

```json
{
  "plugin": ["bug-hunt@git+https://github.com/gpBlockchain/bug-hunt.git"]
}
```

Restart OpenCode. **Detailed docs:** [.opencode/INSTALL.md](.opencode/INSTALL.md)

#### Gemini CLI

```bash
gemini extensions install https://github.com/gpBlockchain/bug-hunt
```

To update:

```bash
gemini extensions update bug-hunt
```

#### Verify Installation

Start a new session in your chosen platform and ask: "Tell me about bug-hunt" or invoke it directly. The agent should recognize the skill and offer to start a bug-hunting run.

#### Updating

**Claude Code:**
```bash
/plugin update bug-hunt
```

**Codex:**
```bash
cd ~/.codex/bug-hunt && git pull
```

**OpenCode:** Restart OpenCode (auto-updates).

**Gemini CLI:**
```bash
gemini extensions update bug-hunt
```

## How It Works

1. **Setup**: Configure test commands, test framework, editable test scope, and safety timeouts. Runs code risk analysis to generate `risk-map.json`, then automatically performs codebase reconnaissance (`recon.md`) to detect the tech stack, entry points, and trust boundaries.
2. **Loop**: The agent writes unit tests to find bugs — records every bug found and keeps going indefinitely. After each potential bug, a verification step (`verification.md`) filters out flaky tests and false positives, assigning a confidence score to every confirmed finding. Security-oriented test types (`injection`, `auth-bypass`, `idor`, etc.) are prioritized for high-risk entry points identified during recon.
3. **Analysis**: View structured results, tests written, bugs found (with confidence scores), and coverage progress over time.
4. **Evaluation** *(optional)*: Run `/bug-hunt --eval` to measure the skill's effectiveness against a controlled test fixture with planted bugs — reports detection rate, false positive rate, and efficiency.

## Key Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill definition and workflow routing (OpenCode) |
| `CLAUDE.md` | Skill definition and workflow routing (Claude Code) |
| `.claude/commands/bug-hunt.md` | `/bug-hunt` slash command (Claude Code) |
| `setup.md` | Interactive first-run configuration |
| `loop.md` | Autonomous test-writing loop |
| `analysis.md` | Result analysis and recommendations |
| `recon.md` | Codebase reconnaissance: tech stack, entry points, trust boundaries |
| `verification.md` | Bug verification and false-positive filtering |
| `eval.md` | Self-test evaluation and effectiveness benchmarking |
| `adaptive-strategy.md` | Self-learning test selection and fuzz testing strategy |
| `analysis-engine.md` | Code risk scoring (6 dimensions including Security) |
| `bug-hunt.toml` | Configuration (test commands, framework, scope) |
| `bug-hunt-context.md` | Agent's knowledge base |
| `recon-report.json` | Tech stack, entry points, trust boundaries (generated at setup) |
| `llms.txt` | Short LLM-facing project summary |
| `llms-full.txt` | Full LLM-facing reference |

## Usage

### Claude Code

Run the `/bug-hunt` slash command from the Claude Code prompt:

```
/bug-hunt
```

Or for analysis of a previous run:

```
/bug-hunt analysis
```

### OpenCode

Invoke the `bug-hunt` skill when you want to autonomously write unit tests and find bugs — using tests, linters, static analysis, or code review. The skill only finds bugs; it never modifies source code.

### Codex / Gemini CLI / Cursor

Simply ask the agent to "run bug-hunt" or "find bugs in this codebase" — the skill is automatically discovered and activated.
