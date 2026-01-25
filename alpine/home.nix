{ pkgs, lib, ... }:
{
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  imports = [
    ../modules/fish.nix
    (import ../modules/tmux.nix { inherit pkgs lib; statusPosition = "bottom"; })
    ../modules/neovim.nix
    ../modules/packages-common.nix
    ../modules/opencode  # TODO: add after musl support
  ];

  home.packages = [
    pkgs.tzdata
  ];

  home.sessionVariables = {
    TZ = "Asia/Manila";
  };

  home.username = "steven";
  home.homeDirectory = "/home/steven";
  home.stateVersion = "24.05";

  # Required for standalone home-manager
  programs.home-manager.enable = true;

  # Disable manpage generation - fails in chroot due to missing /dev/shm
  manual.manpages.enable = false;
}
