{ pkgs, helium, ... }:
{
  imports = [ ./ghostty.nix ];

  home.packages = [
    # pkgs.mpv  # Using Homebrew instead to avoid building Swift
    pkgs.localsend
    pkgs.jetbrains.idea
    pkgs.qbittorrent
    helium.packages.${pkgs.system}.default
  ];
}
