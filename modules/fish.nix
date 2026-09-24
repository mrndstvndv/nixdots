{ pkgs, ... }:

{
  home.sessionVariables = {
    UV_CACHE_DIR = "/Volumes/realme/.cache/uv";
    GRADLE_USER_HOME = "/Volumes/realme/.gradle";
    ANDROID_HOME = "/Volumes/realme/Dev/AndroidSdk";
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      agy = "~/.local/bin/agy";
      gci = "git clone --depth 1";
    };
    interactiveShellInit = ''
      fish_vi_key_bindings
      bind -M insert \cr history-pager
      bind \cz 'fg 2>/dev/null; commandline -f repaint'
      bind -M insert \cz 'fg 2>/dev/null; commandline -f repaint'

      # Emulate Vim cursor shapes
      set fish_cursor_default block
      set fish_cursor_insert line
      set fish_cursor_replace_one underscore
      set fish_cursor_replace underscore
      set fish_cursor_external line
      set fish_cursor_visual block

      function prompt_login
        # Return empty to remove username@hostname from prompt
      end

      set fish_greeting ""

      # Desktop notification for long-running commands (>1s)
      function notify_long_cmd --on-event fish_postexec
        if test "$CMD_DURATION" -ge 10000
          set -l msg (string replace -a '\n' ' ' -- "$argv")
          osc-notify "Fish" "$msg"
        end
      end

      # Add bun to PATH if external storage mounted
      if test -d "/Volumes/realme"
        fish_add_path --prepend "/Volumes/realme/.bun/bin"
      end

      # Helper: update flakes (optionally specific inputs) and rebuild nix-darwin
      function update-darwin-flake
        # Collect optional inputs: `update-darwin-flake nixpkgs home-manager`
        set -l update_args
        for input in $argv
          set update_args $update_args --update-input $input
        end

        if test (count $update_args) -gt 0
          echo "Updating specified flakes: $argv"
          nix flake update $update_args
        else
          echo "Updating all flake inputs"
          nix flake update
        end

        if test $status -eq 0
          echo "Rebuilding configuration"
          sudo darwin-rebuild switch --flake .#proputer
        else
          echo "flake update failed; rebuild skipped"
        end
      end
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
