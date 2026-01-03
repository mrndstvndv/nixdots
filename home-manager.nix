{ pkgs, my-neovim, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./modules/fish.nix
    ./modules/tmux.nix
    ./modules/neovim.nix
    ./modules/packages-common.nix
    ./modules/opencode.nix
  ];

  home.stateVersion = "26.05";
}
