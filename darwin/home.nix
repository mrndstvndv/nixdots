{ pkgs, ... }:
{
  imports = [
    ../modules/packages-gui.nix
    ../modules/fish.nix
    ./aerospace.nix
  ];

  home.packages = [
    # pkgs.daisydisk
    pkgs.tailscale
  ];

  home.sessionVariables = {
    SHELL = "${pkgs.fish}/bin/fish";
  };

  # Darwin-specific bun and fish config
  custom.bun.installDir = "/Volumes/realme/.bun";



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
