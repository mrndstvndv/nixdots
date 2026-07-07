{ config, pkgs, homebrew-core, homebrew-cask, homebrew-smctemp, ... }:
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

    # Enable mutable taps so brew can create the correct
    # homebrew-repo directory name for taps not following the
    # homebrew-* naming convention.
    mutableTaps = true;
  };

  # Homebrew configuration
  homebrew = {
    # Enable the homebrew module
    enable = true;

    # User owning the Homebrew installation
    user = "steven";

    # Sync taps with nix-homebrew.taps, but use clone_target for
    # taps whose GitHub repo doesn't follow the homebrew- naming
    # convention (nix-homebrew creates wrong directory names for those).
    taps = (builtins.map (name: { inherit name; }) (
      builtins.attrNames config.nix-homebrew.taps
    ));

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
      "antigravity"
      "proton-pass"
      "protonvpn"
      "mpv"
      "obs"
      "brave-browser@nightly"
      "steam"
      "localsend"
    ];

    brews = [
      "herdr"
      "smctemp"
      "jadx"
      "ripgrep"
    ];
  };
}
