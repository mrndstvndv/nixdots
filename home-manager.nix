{ pkgs, ... }:
{
  home.packages = [
    pkgs.neovim
    pkgs.bun
    pkgs.lazygit
    pkgs.gh
    pkgs.git
    pkgs.zoxide
  ];

  home.sessionPath = [
    "/Users/steven/.bun/bin"
  ];

  programs.zsh.enable = true;

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    enableZshIntegration = true;

    settings = {
      command = "/run/current-system/sw/bin/tmux new -As0";

      background-opacity = "0.9";
      background-blur = true;
      
      window-padding-x = 0;
      window-padding-y = 0;
      window-padding-balance = true;
      window-padding-color = "extend";
      window-decoration = false;

      font-size = 20;
    };
  };

  home.stateVersion = "26.05";
}