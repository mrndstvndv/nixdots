{ pkgs, ... }:
{
  imports = [
  ./ghostty.nix
  ./alacritty.nix
  ./herdr.nix
];

  home.packages = [
    # pkgs.mpv  # Using Homebrew instead to avoid building Swift
    pkgs.localsend
    pkgs.jetbrains.idea
  ];
}
