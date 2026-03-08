{ pkgs, my-neovim, lib, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ../modules/nushell.nix
    ../modules/tmux.nix
    ../modules/zsh.nix
    ../modules/neovim.nix
    ../modules/packages-common.nix
    ../modules/packages-gui.nix
    ../modules/opencode
    ../modules/pi
  ];

  home.stateVersion = "26.05";
}
