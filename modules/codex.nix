{ pkgs, lib, ... }:
let
  codexConfig = ''
    # Full access is intentional: Codex runs without command sandboxing or
    # approval prompts by default.
    approval_policy = "never"
    sandbox_mode = "danger-full-access"
  '';
in
{
  # Codex persists project trust in config.toml. Keep it writable instead of
  # deploying a read-only Home Manager symlink into the Nix store.
  home.activation.makeCodexConfigWritable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.codex"
    $DRY_RUN_CMD install -m 0644 "${pkgs.writeText "codex-config.toml" codexConfig}" "$HOME/.codex/.config.toml.tmp"
    $DRY_RUN_CMD mv -f "$HOME/.codex/.config.toml.tmp" "$HOME/.codex/config.toml"
  '';
}
