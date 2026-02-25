{ config, pkgs, amp, codex, ... }:
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
    pkgs.jujutsu
    pkgs.nodejs_24
    pkgs.jq
    pkgs.aria2
    pkgs.unzip
    (amp.lib.mkAmp pkgs.system pkgs)

    # OpenAI Codex CLI from external flake input
    # Use the flake's package matching our system
    (builtins.getAttr pkgs.system codex.packages).codex
  ];

  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };

  # Common PATH additions
  home.sessionPath = [
    "${config.home.homeDirectory}/.bun/bin"
    "${config.home.homeDirectory}/.config/nixdots/bin"
  ];
}
