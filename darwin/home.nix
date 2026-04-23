{ pkgs, ... }:
{
  imports = [
    ../modules/packages-gui.nix
    ../modules/fish.nix
    ./aerospace.nix
  ];

  home.packages = [
    # pkgs.daisydisk
    pkgs.tailscale
    pkgs.android-cli
  ];

  # Darwin-specific bun and fish config
  custom.bun.installDir = "/Volumes/realme/.bun";
}
