{ pkgs, my-neovim, ... }:
{
  home.packages = [
    my-neovim.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
