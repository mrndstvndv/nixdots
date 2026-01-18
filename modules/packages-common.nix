{ config, pkgs, amp, ... }:
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
    pkgs.ntfy-sh
    pkgs.htop
    pkgs.tailscale
    pkgs.github-copilot-cli
    (amp.lib.mkAmp pkgs.system pkgs)
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
