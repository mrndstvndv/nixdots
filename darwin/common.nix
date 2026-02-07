{ pkgs, my-neovim, lib, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ../modules/fish.nix
    ../modules/tmux.nix
    ../modules/zsh.nix
    ../modules/neovim.nix
    ../modules/packages-common.nix
    ../modules/packages-gui.nix
    ../modules/opencode
    ../modules/pi
  ];

  # Activation script: Prompt for WebDAV password if config doesn't exist
  home.activation.setupWebDavPassword = lib.hm.dag.entryAfter ["writeBoundary"] ''
    HTPASSWD_FILE="$HOME/.config/rclone/htpasswd"
    
    if [ ! -f "$HTPASSWD_FILE" ]; then
      echo "----------------------------------------------------------------"
      echo "⚠️  RCLONE WEBDAV PASSWORD SETUP REQUIRED ⚠️"
      echo ""
      echo "The WebDAV service requires a password file to start."
      echo ""
      
      # Only prompt if this is an interactive terminal
      if [ -t 0 ]; then
        read -s -p "Enter password for WebDAV user 'steven': " PASS
        echo ""
        mkdir -p "$HOME/.config/rclone"
        ${pkgs.apacheHttpd}/bin/htpasswd -cb "$HTPASSWD_FILE" steven "$PASS"
        echo "✅ Password saved to $HTPASSWD_FILE"
      else
        echo "❌ Non-interactive session detected."
        echo "Run this manually to set password:"
        echo "  htpasswd -c $HTPASSWD_FILE steven"
      fi
      
      echo "----------------------------------------------------------------"
    fi
  '';

  home.stateVersion = "26.05";
}
