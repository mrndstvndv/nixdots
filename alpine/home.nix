{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ../modules/fish.nix
    ../modules/tmux.nix
    ../modules/neovim.nix
    ../modules/packages-common.nix
    # ../modules/opencode  # TODO: add after musl support
  ];

  home.username = "steven";
  home.homeDirectory = "/home/steven";
  home.stateVersion = "24.05";

  # Required for standalone home-manager
  programs.home-manager.enable = true;

  # Disable manpage generation - fails in chroot due to missing /dev/shm
  manual.manpages.enable = false;
}
