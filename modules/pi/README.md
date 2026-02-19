# Pi Configuration Module

This nix module manages the [pi coding agent](https://github.com/badlogic/pi-mono) configuration declaratively.

## Overview

This module builds a custom pi extensions package with npm dependencies and generates the `settings.json` configuration file. All pi configuration is managed through nix for reproducibility across systems.

## Structure

```
modules/pi/
├── default.nix          # Main module configuration
├── package/             # NPM package containing extensions
│   ├── package.json     # Dependencies and pi manifest
│   ├── package-lock.json # Vendored lockfile (required for nix build)
│   └── extensions/      # Local extension TypeScript files
├── agents/              # Subagent definitions
│   └── scout.md         # Example: GitHub Copilot scout agent
├── settings.json        # Base pi settings
└── AGENTS.md            # Global AGENTS.md context
```

## How It Works

### 1. NPM Package Build

The `default.nix` uses `pkgs.buildNpmPackage` to create a deterministic npm package:

- Sources from `./package` directory
- Uses `package-lock.json` to fetch exact dependency versions
- `npmDepsHash` ensures reproducible builds
- Output is stored in the nix store

### 2. Settings Generation

The module generates `~/.pi/agent/settings.json` with:
- Base settings from `settings.json`
- `packages` array pointing to the nix store path of the built extensions

### 3. Agent Definitions

Subagents are defined in `./agents/*.md` and symlinked to `~/.pi/agent/agents/`.

## Adding New Extensions

### Option 1: NPM Package (Recommended for published packages)

1. **Add dependency to `package/package.json`:**

```json
{
  "dependencies": {
    "existing-dep": "^1.0.0",
    "new-package": "^2.0.0"
  },
  "pi": {
    "extensions": [
      "./node_modules/new-package/dist/index.js"
    ]
  }
}
```

2. **Update lockfile:**

```bash
cd modules/pi/package
rm -rf node_modules bun.lock bun.lockb
npm install
```

3. **Get new npmDepsHash:**

```bash
cd /private/etc/nix-darwin
# Set npmDepsHash = ""; in default.nix first
nix build .#darwinConfigurations.proputer.config.home-manager.users.steven.home.file.".pi/agent/settings.json".source 2>&1 | grep "got:"
# Copy the sha256 hash into default.nix
```

4. **Apply changes:**

```bash
sudo darwin-rebuild switch --flake .#proputer
```

### Option 2: Local Extension (For custom extensions)

1. **Create extension file in `package/extensions/`:**

```typescript
// package/extensions/my-extension.ts
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "my_tool",
    description: "Does something cool",
    parameters: {/* ... */},
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      // Tool implementation
      return { content: [{ type: "text", text: "Done!" }] };
    }
  });
}
```

2. **Register in `package/package.json`:**

```json
{
  "pi": {
    "extensions": [
      "./extensions/my-extension.ts"
    ]
  }
}
```

3. **Update hash and rebuild** (same as Option 1, steps 3-4)

### Option 3: Git-based Package

For packages not on npm, add them to the `pi` section:

```json
{
  "pi": {
    "extensions": [
      "git:github.com/user/repo/extension.ts"
    ]
  }
}
```

Note: This requires the package to be installable via `pi install git:...` syntax.

## Adding New Subagents

Subagents are specialized agents that run in isolated context windows.

1. **Create agent definition in `agents/`:**

```markdown
---
name: my-agent
description: What this agent does
tools: read, grep, find, ls, bash
model: claude-haiku-4-5  # Optional - uses default if omitted
---

System prompt for the agent goes here.
```

2. **Register in `default.nix`:**

```nix
home.file.".pi/agent/agents/my-agent.md".source = ./agents/my-agent.md;
```

3. **Rebuild:**

```bash
sudo darwin-rebuild switch --flake .#proputer
```

## Model Configuration

### Per-Agent Model

Specify in the agent's YAML frontmatter:

```yaml
---
name: scout
model: github-copilot/claude-haiku-4-5
---
```

Available model formats:
- `claude-sonnet-4-5` - Short name (uses first provider with this model)
- `github-copilot/claude-sonnet-4-5` - Provider-prefixed (explicit)
- `anthropic/claude-opus-4-5` - Provider-prefixed (explicit)

### Default Model Fallback

If no model is specified, the subagent uses the **default model from your main pi session** (set via `/model` or `defaultModel` in settings).

## Tips

- Always use `npm install` (not bun) for the lockfile - nix expects `package-lock.json`
- Keep the `npmDepsHash` updated whenever dependencies change
- The module manages `~/.pi/agent/settings.json` - don't edit it manually
- Local extensions are referenced relative to the package root: `./extensions/...`
- NPM packages are referenced: `./node_modules/package-name/path/to/entry.js`

## Troubleshooting

### Hash mismatch errors

If you see:
```
error: hash mismatch in fixed-output derivation
         specified: sha256-...
         got:       sha256-NEW_HASH
```

Copy the "got" hash into `default.nix` and rebuild.

### Extension not loading

Check the extension path in `package.json`. Common issues:
- Wrong path separator (use `/`, not `\`)
- Missing `./` prefix for local files
- TypeScript file not found in the built package

### Verify loaded extensions

In pi, run:
```
/extensions
```

Or check the generated settings:
```bash
cat ~/.pi/agent/settings.json
```
