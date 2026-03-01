{ pkgs, lib, ... }:
{
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  imports = [
    ../modules/nushell.nix
    ../modules/tmux.nix
    ../modules/neovim.nix
    ../modules/packages-common.nix
  ];

  custom.tmux.statusPosition = "bottom";

  home.packages = [
    pkgs.tzdata
  ];

  home.sessionVariables = {
    TZ = "Asia/Manila";
  };

  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "25.05";

  # Required for standalone home-manager
  programs.home-manager.enable = true;

  # Disable manpage generation
  manual.manpages.enable = false;
}
