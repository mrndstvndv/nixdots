{ pkgs, ... }:
{
  home.packages = [
    pkgs.bun
    pkgs.lazygit
    pkgs.gh
    pkgs.git
    pkgs.cursor-cli
  ];

  # Common PATH additions
  home.sessionPath = [
    "/Users/steven/.bun/bin"
  ];
}
