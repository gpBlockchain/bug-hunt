# Installing Bug Hunt for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed

## Installation

Add bug-hunt to the `plugin` array in your `opencode.json` (global or project-level):

```json
{
  "plugin": ["bug-hunt@git+https://github.com/gpBlockchain/bug-hunt.git"]
}
```

Restart OpenCode. That's it — the plugin auto-installs and registers the skill.

Verify by asking: "Tell me about bug-hunt"

## Usage

Use OpenCode's native `skill` tool:

```
use skill tool to list skills
use skill tool to load bug-hunt
```

Or simply ask:

```
use bug-hunt to find bugs in this codebase
```

## Updating

Bug-hunt updates automatically when you restart OpenCode.

To pin a specific version:

```json
{
  "plugin": ["bug-hunt@git+https://github.com/gpBlockchain/bug-hunt.git#v1.0.0"]
}
```

## Troubleshooting

### Plugin not loading

1. Check logs: `opencode run --print-logs "hello" 2>&1 | grep -i bug-hunt`
2. Verify the plugin line in your `opencode.json`
3. Make sure you're running a recent version of OpenCode

### Skills not found

1. Use `skill` tool to list what's discovered
2. Check that the plugin is loading (see above)

## Getting Help

- Report issues: https://github.com/gpBlockchain/bug-hunt/issues
