{ pkgs, ... }:
{
  home.packages = [
    pkgs.mpv
    pkgs.localsend
  ];

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    enableFishIntegration = true;

    settings = {
      command = "${pkgs.fish}/bin/fish --login -c '${pkgs.tmux}/bin/tmux new -As0'";
      background-opacity = "0.9";
      background-blur = true;

      window-padding-x = 0;
      window-padding-y = 0;
      window-padding-balance = true;
      window-padding-color = "extend";
      window-decoration = false;

      font-size = 18;
    };
  };
}
