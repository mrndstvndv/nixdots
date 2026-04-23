{ pkgs, my-neovim, piAgent ? null, lib, ... }:
{
  imports =
    lib.optionals (piAgent != null) [
      piAgent.homeManagerModules.default
    ]
    ++ [
      ../modules/fish.nix
      ../modules/tmux.nix
      ../modules/neovim.nix
      ../modules/packages-common.nix
      ../modules/packages-gui.nix
    ];

  home.stateVersion = "26.05";
}
