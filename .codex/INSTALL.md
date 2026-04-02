# Installing Bug Hunt for Codex

Enable the bug-hunt skill in Codex via native skill discovery. Clone and symlink.

## Prerequisites

- Git

## Installation

1. **Clone the bug-hunt repository:**
   ```bash
   git clone https://github.com/gpBlockchain/bug-hunt.git ~/.codex/bug-hunt
   ```

2. **Create the skills symlink:**
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/bug-hunt ~/.agents/skills/bug-hunt
   ```

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
   cmd /c mklink /J "$env:USERPROFILE\.agents\skills\bug-hunt" "$env:USERPROFILE\.codex\bug-hunt"
   ```

3. **Restart Codex** (quit and relaunch the CLI) to discover the skill.

## Verify

```bash
ls -la ~/.agents/skills/bug-hunt
```

You should see a symlink (or junction on Windows) pointing to your bug-hunt directory.

## Usage

Tell Codex:

```
use bug-hunt to find bugs in this codebase
```

Or:

```
run the bug-hunt skill
```

## Updating

```bash
cd ~/.codex/bug-hunt && git pull
```

The skill updates instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/bug-hunt
```

Optionally delete the clone: `rm -rf ~/.codex/bug-hunt`.
