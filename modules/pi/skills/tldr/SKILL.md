---
name: tldr
description: Token-efficient code analysis using llm-tldr. Extracts structure, call graphs, and program slices to save context tokens. Use for deep codebase understanding, semantic search, and debugging.
---

# TLDR Skill: Code Analysis for LLMs

Use the `tldr` tool (via `uv run --with llm-tldr tldr`) to analyze code efficiently. This tool extracts structure, dependencies, and program slices, providing 95% token savings compared to raw code.

## Key Workflows

### 1. Initialization
Run this once to index the project (builds AST, call graphs, and semantic index):
```bash
uv run --with llm-tldr tldr warm .
```

### 2. Context Extraction (95% Token Savings)
Instead of reading a whole file, get a summary of a function and its dependencies:
```bash
uv run --with llm-tldr tldr context <function_name> --project .
```

### 3. Semantic Search
Find code by behavior (e.g., "validate JWT") instead of just text matching:
```bash
uv run --with llm-tldr tldr semantic "what you're looking for" .
```

### 4. Debugging with Slices
Show ONLY the lines of code that affect a specific line (e.g., line 42 in `auth.py`):
```bash
uv run --with llm-tldr tldr slice src/auth.py login 42
```

### 5. Impact Analysis
See who calls a function before refactoring:
```bash
uv run --with llm-tldr tldr impact <function_name> .
```

### 6. Exploration
- `tldr structure .` - See all classes and methods.
- `tldr tree .` - See the file structure (respects `.tldrignore`).
- `tldr dead .` - Find unreachable code.

## Guidelines
- Always use `uv run --with llm-tldr tldr` to ensure the tool is available.
- Use `tldr context` before reading large files.
- Use `tldr slice` for debugging complex logic.
- Use `tldr impact` before changing function signatures.
