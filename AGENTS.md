## Github interactions
When you find yourself needing to browse code hosted in github you can use github cli via `gh`

## Commit Guidelines

This project uses a simple `scope: description` format (NOT semantic commits).

- Format: `<scope>: <short description>`
- Scopes: `opencode`, `pkgs`, `flake`, `homebrew`, `fish`, `tmux`, `ghostty`, or the relevant module name
- Style: all lowercase, imperative mood, no period at end
- Max 50 characters total
- Examples:
  - `opencode: add context7`
  - `pkgs: add tailscale`
  - `fish: remove tmux autostart`
  - `flake: update amp`
