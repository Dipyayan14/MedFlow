# Flutter & Dart AI Agent Guidelines

Refer to official documentation: https://docs.flutter.dev/ai/tools

## MCP Server & Tooling Workflow
- **Hot Reload & Hot Restart**: Proactively trigger a stateful hot reload or hot restart after modifying Flutter widgets or logic using the `dart-mcp-server` tools (`hot_reload`, `hot_restart`).
- **App Introspection**: If not connected to a running app instance, use `dtd` (Dart Tooling Daemon) to discover and connect to running Flutter apps.
- **Dependency & Package Investigation**: Use `read_package_uris` and `rip_grep_packages` to explore dependencies. `package-root:` URIs resolve to package roots for examples and tests.
- **Static Analysis**: Run static analysis using `analyze_files` and `lsp` to detect and fix analyzer issues early.

## Code Quality & Architecture
- Follow official Flutter architectural standards: separate presentation, business logic, and data layers.
- Apply Dart 3 patterns, exhaustive switch expressions, and records idiomatically.
- Keep widget build methods clean, performant, and properly constrained.
