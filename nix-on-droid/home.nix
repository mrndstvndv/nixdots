{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ../modules/nushell.nix
    ../modules/tmux.nix
    ../modules/neovim.nix
    ../modules/packages-common.nix
  ];

  # Home Manager user for nix-on-droid.
  home.username = "nix-on-droid";
  home.homeDirectory = "/data/data/com.termux.nix/files/home";

  # Separate Home Manager state version for the phone.
  home.stateVersion = "24.05";
}
