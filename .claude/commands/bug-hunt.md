Autonomously write unit tests and find bugs in this codebase.

Read the CLAUDE.md file at the project root to understand the routing logic, then follow the appropriate workflow:

1. If `bug-hunt.toml` does not exist, follow `setup.md` to configure the run
2. If `bug-hunt.toml` exists and the user passes arguments (available as $ARGUMENTS) containing "analysis" or "summary", follow `analysis.md`
3. Otherwise, follow `loop.md` to start the autonomous test-writing loop

Do NOT modify source code — only add/modify test files. Record every bug found. Run indefinitely until manually stopped or `max_iterations` is reached.
