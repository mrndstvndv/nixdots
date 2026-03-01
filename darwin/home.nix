{ pkgs, ... }:
{
  imports = [
    ../modules/packages-gui.nix
    ./aerospace.nix
  ];

  home.packages = [
    # pkgs.daisydisk
    pkgs.nushell
    pkgs.tailscale
    pkgs.rclone
    pkgs.apacheHttpd # for htpasswd
  ];

  home.sessionVariables = {
    SHELL = "${pkgs.nushell}/bin/nu";
  };

  # Nix environment for login shells and POSIX compatibility
  home.file.".profile".text = ''
    # Nix setup for login shells
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi

    # Fallback paths if nix-daemon.sh doesn't exist (Determinate Nix, etc.)
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"
    export PATH="$HOME/.nix-profile/bin:$PATH"
    export PATH="/run/current-system/sw/bin:$PATH"
  '';
}
