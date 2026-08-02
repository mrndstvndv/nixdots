# Testing 
sudo -H nix run nix-darwin/master#darwin-rebuild -- build --flake .#proputer

## ThermalForge

Formula is patched locally (`pkgs/thermalforge.rb`, overlaid in `modules/nix-homebrew.nix`). Upstream is broken: requires full Xcode.app (CLT suffices), v0.1.0 tag missing icon files, post_install can't write /Applications (sandbox), and v0.1.0 has no Smart profile.

- Builds from pinned main commit `f6eb5d23` (only place Smart exists) + `inreplace` adds `smart` to CLI's `builtIn` → `sudo thermalforge watch --profile smart` works
- Bump `revision` in the formula when changing it, or brew won't reinstall
- After rebuild, run manually:
  ```sh
  # launchd plist references /usr/local/bin/thermalforge, but brew's
  # symlink there is relative to /usr/local (dangling on ARM) -> daemon
  # exits 78 EX_CONFIG. Replace it with a real copy of the binary.
  sudo rm -f /usr/local/bin/thermalforge
  sudo install -m 755 /opt/homebrew/bin/thermalforge /usr/local/bin/thermalforge
  sudo launchctl kickstart -k system/com.thermalforge.daemon
  # post_install can't write /Applications from the brew sandbox
  sudo cp -R "$(brew --prefix)/Cellar/thermalforge/0.1.0_1/ThermalForge.app" /Applications/
  ```
- Known upstream bugs: daemon plist hardcodes /usr/local/bin (EX_CONFIG if symlink broken), profile selection not persisted (app starts at silent), CLI `watch` is a foreground loop (needs sudo, stops on exit)

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
  - `flake: update neru`
