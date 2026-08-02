{ pkgs, ... }:

# herdr server as a system LaunchDaemon.
#
# Background: when herdr runs in the user "Background" launchd session (spawned
# via SSH), macOS applies a seatbelt sandbox once the console goes unattended
# (display/machine sleep). The sandbox denies /nix/store reads, so every Nix
# binary in herdr panes dies in dyld with "file system sandbox blocked open()".
#
# A system-domain daemon (UserName = steven) is never sandboxed and needs no
# GUI console session, which is exactly the headless SSH-only setup here.
# SSH clients then attach to the already-running server via its socket
# (~/.config/herdr/herdr.sock) — use `herdr` (launch-or-attach) or
# `herdr session attach`, NOT `herdr server`, from the client side.
{
  launchd.daemons.herdr = {
    script = ''
      exec /opt/homebrew/bin/herdr server
    '';
    serviceConfig = {
      Label = "org.nixos.herdr";
      UserName = "steven";
      RunAtLoad = true;
      KeepAlive = true;
      WorkingDirectory = "/Users/steven";
      EnvironmentVariables = {
        HOME = "/Users/steven";
        PATH = "/Users/steven/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      StandardOutPath = "/var/log/herdr.log";
      StandardErrorPath = "/var/log/herdr.err.log";
    };
  };
}
