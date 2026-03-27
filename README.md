# bench-optimize

An autonomous benchmark optimization skill for OpenCode.

## Overview

This skill enables continuous optimization of a program's benchmark score by proposing code changes, running benchmarks, and intelligently keeping improvements while discarding regressions.

## Inspiration

This project is inspired by [karpathy/autoresearch](https://github.com/karpathy/autoresearch) - Andrej Karpathy's research on autonomous code optimization through systematic experimentation.

## How It Works

1. **Setup**: Configure the benchmark command, metric, editable scope, and variance thresholds
2. **Loop**: The agent proposes code changes, runs benchmarks, and keeps improvements
3. **Analysis**: View structured results and progress over time

## Key Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill definition and workflow routing |
| `setup.md` | Interactive first-run configuration |
| `loop.md` | Autonomous optimization loop |
| `analysis.md` | Result analysis and recommendations |
| `bench-optimize.toml` | Benchmark configuration |
| `bench-optimize-context.md` | Agent's knowledge base |

## Usage

Invoke the `bench-optimize` skill when optimizing any program against a measurable benchmark.
