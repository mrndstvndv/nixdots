# nixdots

Personal Nix configurations for macOS (nix-darwin), Android (nix-on-droid), and Alpine Linux chroot.

## Configurations

| Configuration | Platform | Command |
|---------------|----------|---------|
| `proputer` | macOS (nix-darwin) | `darwin-rebuild switch --flake .#proputer` |
| `default` | Android (nix-on-droid) | `nix-on-droid switch --flake .` |
| `alpine` | Alpine chroot (Termux) | `nix run ~/.config/nixdots#alpine` |

## Alpine Chroot (Termux)

Run the auto-detected switch app:

```bash
nix run ~/.config/nixdots#alpine
```

If you want to call Home Manager directly instead:

```bash
home-manager switch --flake ~/.config/nixdots#alpine --impure
```

Explicit system targets stay available:

- `home-manager switch --flake ~/.config/nixdots#alpine-aarch64-linux`
- `home-manager switch --flake ~/.config/nixdots#alpine-x86_64-linux`
