{ config, pkgs, codex, ... }:
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
    pkgs.cursor-cli
    pkgs.ffmpeg
    pkgs.android-tools
    pkgs.htop
    pkgs.jujutsu
    pkgs.nodejs_24
    pkgs.jq
    pkgs.aria2
    pkgs.unzip

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
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.config/nixdots/bin"
  ];
}
