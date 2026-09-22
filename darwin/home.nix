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
      ../modules/rio.nix
      ../modules/codex.nix
      ./aerospace.nix
      ../modules/hm-activation-fixes.nix
    ];

  home.packages = [
    # pkgs.daisydisk
    pkgs.tailscale
    pkgs.android-cli
  ];

  # Darwin-specific bun and fish config
  custom.bun.installDir = "/Volumes/realme/.bun";

  # macOS ships its own man, so HM 26.05+ leaves programs.man.package null on
  # Darwin, making fish's mkDefault generateCaches=true a no-op (and warn).
  programs.man.generateCaches = false;

  home.stateVersion = "26.05";
}
