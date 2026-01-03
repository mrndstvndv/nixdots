{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.bun
    pkgs.lazygit
    pkgs.gh
    pkgs.git
    pkgs.uv
    pkgs.cursor-cli
    pkgs.mpv
    pkgs.ffmpeg
    pkgs.localsend
    pkgs.android-tools
    pkgs.ktlint
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
