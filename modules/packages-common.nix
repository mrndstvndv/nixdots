{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.bun
    pkgs.lazygit
    pkgs.gh
    pkgs.git
    pkgs.uv
    pkgs.cursor-cli
    pkgs.ffmpeg
    pkgs.android-tools
  ];

  programs.direnv = {
    enable = true;
    silent = true;
  };

  # Common PATH additions
  home.sessionPath = [
    "${config.home.homeDirectory}/.bun/bin"
  ];
}
