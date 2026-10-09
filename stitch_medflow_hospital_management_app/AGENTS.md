# Workspace Agent Rules: Flutter & Dart Development

Official Reference: https://docs.flutter.dev/ai/tools

## Core Practices
1. **Dart & Flutter MCP Server**: Use the integrated `dart-mcp-server` tools (`dtd`, `analyze_files`, `hot_reload`, `hot_restart`, `widget_inspector`, `lsp`, `pub`, `pub_dev_search`) during development sessions.
2. **Proactive Hot Reload**: After editing widgets or business logic in a running app session, automatically trigger hot reload.
3. **Diagnostics & Fixes**: Run static analysis via `analyze_files` or `lsp` to ensure clean code with zero analyzer warnings.
4. **Agent Skills**: Leverage the 25 official Flutter and Dart skills located in `.agents/skills/` for tasks like responsive layouts, declarative routing, widget testing, and mock generation.
