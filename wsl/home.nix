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
    ../modules/pi
  ];

  custom.tmux.statusPosition = "bottom";

  home.packages = [
    pkgs.tzdata
  ];

  home.sessionVariables = {
    TZ = "Asia/Manila";
  };

  programs.nushell.extraConfig = ''
    # Add bun to PATH
    $env.PATH = ($env.PATH | split row (char esep) | prepend "~/.bun/bin")
  '';

  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "25.05";

  # Required for standalone home-manager
  programs.home-manager.enable = true;

  # Force overwrite existing files
  home.file.".pi/agent/settings.json".force = true;

  # Disable manpage generation
  manual.manpages.enable = false;
}
