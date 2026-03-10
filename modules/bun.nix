{ config, pkgs, lib, ... }:

let
  cfg = config.custom.bun;
in
{
  options.custom.bun = {
    enable = lib.mkEnableOption "bun configuration";
    installPackage = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install the bun package from nixpkgs.";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bun;
      description = "The bun package to use.";
    };
    installDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.bun";
      description = "The directory where bun is installed (BUN_INSTALL).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional cfg.installPackage cfg.package;

    home.sessionVariables = {
      BUN_INSTALL = cfg.installDir;
    };

    home.sessionPath = [
      "${cfg.installDir}/bin"
    ];

    # The fish PATH and environment additions are already handled by modules/fish.nix
    # which iterates over config.home.sessionPath and config.home.sessionVariables.
  };
}
