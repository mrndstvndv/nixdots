---
name: pi-config
description: Instructions for modifying pi configuration. Use when you need to change pi settings, skills, extensions, or prompts.
---

# Pi Config

All pi configuration is managed via nix in `~/.config/nixdots/modules/pi/`. Modify config there, not in default pi install locations.

## Location

```
~/.config/nixdots/modules/pi/
├── AGENTS.md          # Agent instructions
├── default.nix        # Nix module config
├── settings.json      # Pi settings
├── skills/            # Custom skills
├── extensions/       # Custom extensions
└── prompt-templates/ # Custom prompt templates
```

## Usage

- Skills: `~/.config/nixdots/modules/pi/skills/<name>/`
- Extensions: `~/.config/nixdots/modules/pi/extensions/`
- Settings: edit `~/.config/nixdots/modules/pi/settings.json`
