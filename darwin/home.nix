{ pkgs, ... }:
{
  imports = [
    ../modules/packages-gui.nix
    ../modules/nushell.nix
    ./aerospace.nix
  ];

  home.packages = [
    # pkgs.daisydisk
    pkgs.tailscale
  ];

  home.sessionVariables = {
    SHELL = "${pkgs.nushell}/bin/nu";
  };

  # Darwin-specific bun and nushell config
  custom.bun.installDir = "/Volumes/realme/.bun";

  programs.nushell = {
    environmentVariables = {
      UV_CACHE_DIR = "/Volumes/realme/.cache/uv";
      GRADLE_USER_HOME = "/Volumes/realme/.gradle";
    };
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
