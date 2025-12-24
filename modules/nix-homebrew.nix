{ config, homebrew-core, homebrew-cask, ... }:
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
    };

    # Disable mutable taps - only manage taps via nix config
    mutableTaps = false;
  };

  # Sync homebrew.taps with nix-homebrew.taps to avoid mismatches
  homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
}
