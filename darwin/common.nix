{ pkgs, my-neovim, lib, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ../modules/fish.nix
    ../modules/tmux.nix
    ../modules/neovim.nix
    ../modules/packages-common.nix
    ../modules/packages-gui.nix
    ../modules/pi
  ];

  home.stateVersion = "26.05";
}
