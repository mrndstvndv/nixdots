{ pkgs, ... }:
{
  imports = [
    ../modules/packages-gui.nix
    ./aerospace.nix
  ];

  home.packages = [
    pkgs.daisydisk
    pkgs.raycast
    pkgs.tailscale
  ];
}
