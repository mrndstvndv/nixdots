{ config, pkgs, ... }:
{
  imports = [ ./bun.nix ];

  custom.bun.enable = true;

  home.packages = [
    pkgs.lazygit
    pkgs.gh
    pkgs.git
    pkgs.uv
    pkgs.fzf
    pkgs.zoxide
    pkgs.ffmpeg
    pkgs.android-tools
    pkgs.htop
    pkgs.nodejs_24
    pkgs.jq
    pkgs.aria2
    pkgs.unzip
    pkgs.p7zip
    pkgs.neovim
    pkgs.jdk17_headless
    pkgs.cargo

    pkgs.ripgrep
  ];

  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };

  # Common PATH additions
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.config/nixdots/bin"
  ];
}
