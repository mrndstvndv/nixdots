{ lib, pkgs, homebrew-nikitabobko, homebrew-thermalforge, ... }:
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

  # Homebrew 6 removed `must_succeed` from install-step `run`, but the
  # mutable AeroSpace tap still emits it. Keep this tap declarative and patch
  # the generated cask until upstream catches up.
  aerospace-tap = pkgs.runCommandLocal "homebrew-tap-nikitabobko" { } ''
    cp -r ${homebrew-nikitabobko} $out
    chmod -R u+w $out
    cp ${../pkgs/aerospace.rb} $out/Casks/aerospace.rb
  '';
in
{
  nix-homebrew = {
    enable = true;

    # Disable Rosetta 2 support
    enableRosetta = false;

    # User owning the Homebrew prefix
    user = "steven";

    # Keep patched taps in Nix. Homebrew owns the other clones so `brew update`
    # can advance their metadata without changing the flake.
    taps = {
      "nikitabobko/homebrew-tap" = aerospace-tap;
      "ProducerGuy/homebrew-tap" = thermalforge-tap;
    };

    # Allow Homebrew to update its mutable tap clones.
    mutableTaps = true;

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

  # The old immutable setup leaves this path as a Nix-store symlink. Remove
  # only that link before nix-homebrew creates mutable tap directories.
  system.activationScripts.setup-homebrew.text = lib.mkBefore ''
    taps=/opt/homebrew/Library/Taps
    if [[ -L "$taps" && "$(/usr/bin/readlink "$taps")" == /nix/store/* ]]; then
      rm "$taps"
      mkdir -p "$taps"
      chown steven:admin "$taps"
      chmod ug+rwx "$taps"
    fi
  '';

  # Homebrew configuration
  homebrew = {
    # Enable the homebrew module
    enable = true;

    # User owning the Homebrew installation
    user = "steven";

    # Refresh package metadata before manually invoked Homebrew commands.
    global.autoUpdate = true;

    # Keep third-party tap membership declarative while leaving repository
    # contents to Homebrew, except for the locally patched taps above. Core
    # and cask metadata come from Homebrew's API.
    taps = builtins.map (name: {
      inherit name;
      # Without this, brew bundle's cleanup does `Trust.replace!` on every
      # switch, which wipes tap trust entries added by nix-homebrew's
      # `trust.taps` and breaks `brew cleanup` for third-party taps.
      trusted = true;
    }) [
      "narugit/homebrew-tap"
      "egoist/homebrew-tap"
      "ProducerGuy/homebrew-tap"
      "nikitabobko/homebrew-tap"
    ];

    # Lifecycle automation
    onActivation = {
      autoUpdate = false;       # Keep metadata updates manual
      upgrade = false;          # Keep package upgrades manual
      cleanup = "uninstall";    # Remove untracked packages on rebuild
    };

    # Install OrbStack via Homebrew
    # OrbStack is pinned by default (no greedy/auto-updates)
    casks = [
      "orbstack"
      "brave-browser@nightly"
      "crossover"
      "proton-pass"
      "protonvpn"
      "stolendata-mpv"
      "obs"
      "steam"
      "qbittorrent"
      "helium-browser"
      "telegram"
      "codex"
      "nikitabobko/tap/aerospace"
      "kde-connect"
    ];

    brews = [
      "fish"
      "herdr"
      "smctemp"
      "jadx"
      "apktool"
      "azure-cli"
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
