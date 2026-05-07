{ config, lib, pkgs, piAgent ? null, ... }:
{
  # Backup etc files instead of failing to activate generation if a file
  # already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set the default login shell for the nix-on-droid user.
  # This must be the *binary path*, not the package.
  user.shell = "${pkgs.fish}/bin/fish";

  # Configure home-manager (nix-on-droid integrates it for us).
  home-manager = {
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = { inherit piAgent; };

    # Reuse our shared Home Manager config, which pulls in fish, tmux,
    # and common packages.
    config = import ./home.nix;
  };
}
