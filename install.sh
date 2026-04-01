#!/bin/bash
set -euo pipefail

# bug-hunt skill installer
# Install the bug-hunt autonomous test-writing and bug-finding skill
# into the current project directory.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/install.sh | bash -s -- --claude
#   curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/install.sh | bash -s -- --opencode
#   curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/install.sh | bash -s -- --all

REPO="gpBlockchain/bug-hunt"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[bug-hunt]${NC} $*"; }
warn()  { echo -e "${YELLOW}[bug-hunt]${NC} $*"; }
error() { echo -e "${RED}[bug-hunt]${NC} $*" >&2; }

# Workflow files that power the skill
WORKFLOW_FILES="setup.md loop.md analysis.md analysis-engine.md adaptive-strategy.md"

download_file() {
  local url="$1"
  local dest="$2"
  if ! curl -fsSL "$url" -o "$dest"; then
    error "Failed to download: $url"
    return 1
  fi
}

install_workflow_files() {
  info "Downloading workflow files..."
  for f in $WORKFLOW_FILES; do
    download_file "${BASE_URL}/${f}" "$f"
    info "  ✓ $f"
  done
}

install_claude_code() {
  info "Setting up Claude Code skill..."

  # Download .claude/commands/bug-hunt.md
  mkdir -p .claude/commands
  download_file "${BASE_URL}/.claude/commands/bug-hunt.md" ".claude/commands/bug-hunt.md"
  info "  ✓ .claude/commands/bug-hunt.md"

  # Handle CLAUDE.md — append if exists, create if not
  local tmp_claude
  tmp_claude=$(mktemp)
  download_file "${BASE_URL}/CLAUDE.md" "$tmp_claude"

  if [ -f "CLAUDE.md" ]; then
    # Check if bug-hunt instructions already exist
    if grep -q "bug-hunt: Autonomous Unit-Test Writing and Bug Finding" "CLAUDE.md" 2>/dev/null; then
      warn "CLAUDE.md already contains bug-hunt instructions, skipping append"
    else
      info "  Appending bug-hunt instructions to existing CLAUDE.md..."
      {
        echo ""
        echo "---"
        echo ""
        cat "$tmp_claude"
      } >> CLAUDE.md
    fi
  else
    cp "$tmp_claude" CLAUDE.md
  fi
  rm -f "$tmp_claude"
  info "  ✓ CLAUDE.md"
}

install_opencode() {
  info "Setting up OpenCode skill..."
  download_file "${BASE_URL}/SKILL.md" "SKILL.md"
  info "  ✓ SKILL.md"
}

show_usage() {
  cat <<EOF
bug-hunt skill installer

Usage:
  install.sh [OPTIONS]

Options:
  --claude    Install for Claude Code only
  --opencode  Install for OpenCode only
  --all       Install for both Claude Code and OpenCode (default)
  --help      Show this help message

Examples:
  # Install for both Claude Code and OpenCode (default)
  curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/install.sh | bash

  # Install for Claude Code only
  curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/install.sh | bash -s -- --claude

  # Install for OpenCode only
  curl -fsSL https://raw.githubusercontent.com/gpBlockchain/bug-hunt/main/install.sh | bash -s -- --opencode
EOF
}

main() {
  local mode="all"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --claude)   mode="claude";   shift ;;
      --opencode) mode="opencode"; shift ;;
      --all)      mode="all";      shift ;;
      --help|-h)  show_usage;      exit 0 ;;
      *)          error "Unknown option: $1"; show_usage; exit 1 ;;
    esac
  done

  echo ""
  info "Installing bug-hunt skill into $(pwd)"
  echo ""

  # Always install workflow files
  install_workflow_files
  echo ""

  case "$mode" in
    claude)
      install_claude_code
      ;;
    opencode)
      install_opencode
      ;;
    all)
      install_claude_code
      echo ""
      install_opencode
      ;;
  esac

  echo ""
  info "✅ bug-hunt skill installed successfully!"
  echo ""
  info "Next steps:"

  case "$mode" in
    claude)
      info "  Run /bug-hunt in Claude Code to start"
      ;;
    opencode)
      info "  Invoke the bug-hunt skill in OpenCode to start"
      ;;
    all)
      info "  Claude Code: Run /bug-hunt to start"
      info "  OpenCode:    Invoke the bug-hunt skill to start"
      ;;
  esac

  echo ""
  info "The skill will guide you through setup on first run."
  echo ""
}

main "$@"
