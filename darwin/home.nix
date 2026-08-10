{ pkgs, piAgent ? null, lib, ... }:
{
  imports =
    lib.optionals (piAgent != null) [
      piAgent.homeManagerModules.default
    ]
    ++ [
      ../modules/fish.nix
      ../modules/tmux.nix
      ../modules/packages-common.nix
      ../modules/packages-gui.nix
      ./aerospace.nix
    ];

  home.packages = [
    # pkgs.daisydisk
    pkgs.tailscale
    pkgs.android-cli
  ];

  # Darwin-specific bun and fish config
  custom.bun.installDir = "/Volumes/realme/.bun";

  home.stateVersion = "26.05";
}
