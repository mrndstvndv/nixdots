{ config, homebrew-core, homebrew-cask, homebrew-smctemp, ... }:
{
  nix-homebrew = {
    enable = true;

    # Disable Rosetta 2 support
    enableRosetta = false;

    # User owning the Homebrew prefix
    user = "steven";

    # Declarative tap management
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "narugit/homebrew-tap" = homebrew-smctemp;
    };

    # Disable mutable taps - only manage taps via nix config
    mutableTaps = false;
  };

  # Homebrew configuration
  homebrew = {
    # Enable the homebrew module
    enable = true;

    # User owning the Homebrew installation
    user = "steven";

    # Sync taps with nix-homebrew.taps to avoid mismatches
    taps = builtins.attrNames config.nix-homebrew.taps;

    # Lifecycle automation
    onActivation = {
      autoUpdate = true;        # Update Homebrew itself on rebuild
      upgrade = true;           # Upgrade installed packages on rebuild
      cleanup = "uninstall";    # Remove untracked packages on rebuild
    };

    # Install OrbStack via Homebrew
    # OrbStack is pinned by default (no greedy/auto-updates)
    casks = [
      "orbstack"
      "crossover"
    ];

    brews = [
      "smctemp"
    ];
  };
}
