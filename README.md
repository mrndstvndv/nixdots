# nixdots

Personal Nix configurations for macOS (nix-darwin), Android (nix-on-droid), and Alpine Linux chroot.

## Configurations

| Configuration | Platform | Command |
|---------------|----------|---------|
| `proputer` | macOS (nix-darwin) | `darwin-rebuild switch --flake .#proputer` |
| `default` | Android (nix-on-droid) | `nix-on-droid switch --flake .` |
| `alpine` | Alpine chroot (Termux) | See below |

## Alpine Chroot (Termux)

### First-time setup

```bash
nix run home-manager -- switch --flake ~/.config/nixdots#alpine
```

### Subsequent updates

```bash
home-manager switch --flake ~/.config/nixdots#alpine
```
