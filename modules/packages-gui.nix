{ pkgs, ... }:
{
  imports = [ ./ghostty.nix ];

  home.packages = [
    pkgs.mpv
    pkgs.localsend
    pkgs.jetbrains.idea
  ];
}
