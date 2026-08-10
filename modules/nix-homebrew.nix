{ config, pkgs, homebrew-core, homebrew-cask, homebrew-smctemp, homebrew-egoist, homebrew-thermalforge, homebrew-nikitabobko, ... }:
let
  # Upstream thermalforge formula is broken in three ways: requires full
  # Xcode.app (CLT's swift suffices), v0.1.0 tag is missing the icon files,
  # and post_install can't write /Applications from the brew sandbox.
  # See pkgs/thermalforge.rb for the fixes.
  thermalforge-tap = pkgs.runCommandLocal "homebrew-tap-thermalforge" { } ''
    cp -r ${homebrew-thermalforge} $out
    chmod -R u+w $out
    cp ${../pkgs/thermalforge.rb} $out/Formula/thermalforge.rb
  '';
in
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
      "egoist/homebrew-tap" = homebrew-egoist;
      "ProducerGuy/homebrew-tap" = thermalforge-tap;
      "nikitabobko/homebrew-tap" = homebrew-nikitabobko;
    };

    # Taps are pinned and managed declaratively by this flake.
    mutableTaps = false;

    # Auto-trust third-party taps
    trust = {
      taps = [
        "narugit/homebrew-tap"
        "narugit/tap"
        "egoist/homebrew-tap"
        "egoist/tap"
        "ProducerGuy/homebrew-tap"
        "ProducerGuy/tap"
        "nikitabobko/homebrew-tap"
        "nikitabobko/tap"
      ];
    };
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
      "stolendata-mpv"
      "obs"
      "steam"
      "github-copilot-app"
      "visual-studio-code@insiders"
      "android-studio"
      "qbittorrent"
      "helium-browser"
      "fluidvoice"
      "telegram"
      "hermes-desktop"
      "codex"
      "nikitabobko/tap/aerospace"
    ];

    brews = [
      "fish"
      "herdr"
      "smctemp"
      "jadx"
      "apktool"
      "ProducerGuy/tap/thermalforge"
    ];
  };

  # Wait for the SMC to answer before starting either process. At boot the
  # hardware can lag launchd; retrying here prevents a one-shot failed start.
  launchd.daemons."com.thermalforge.daemon" = {
    serviceConfig = {
      Label = "com.thermalforge.daemon";
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          until /usr/local/bin/thermalforge status >/dev/null 2>&1; do
            /bin/sleep 2
          done
          exec /usr/local/bin/thermalforge daemon
        ''
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      ThrottleInterval = 5;
      StandardOutPath = "/dev/null";
      StandardErrorPath = "/dev/null";
    };
  };

  launchd.daemons."com.thermalforge.smart" = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          until /usr/local/bin/thermalforge status >/dev/null 2>&1; do
            /bin/sleep 2
          done
          exec /usr/local/bin/thermalforge watch --profile smart
        ''
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      ThrottleInterval = 5;
      StandardOutPath = "/dev/null";
      StandardErrorPath = "/dev/null";
    };
  };
}
