{ pkgs, ... }:
{
  imports = [ ./ghostty.nix ];

  home.packages = [
    # pkgs.mpv  # Using Homebrew instead to avoid building Swift
    pkgs.localsend
    pkgs.jetbrains.idea
    pkgs.qbittorrent
  ];
}
