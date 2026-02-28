{ pkgs, lib, my-neovim ? null, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  useMyNeovim =
    my-neovim != null
    && my-neovim ? packages
    && builtins.hasAttr system my-neovim.packages;
in
{
  home.packages =
    if useMyNeovim then
      [ my-neovim.packages.${system}.default ]
    else
      [ pkgs.neovim ];
}
