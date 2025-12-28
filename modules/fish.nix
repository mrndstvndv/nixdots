{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
      interactiveShellInit = ''
        # Source nix-darwin environment if not already done
        if test -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE"
          fish_add_path --prepend /run/current-system/sw.bin
          fish_add_path --prepend $HOME/.nix-profile/bin

           # Use external storage on macOS if available
           if test (uname) = Darwin; and test -d "/Volumes/realme"
               set --export UV_CACHE_DIR "/Volumes/realme/.cache/uv"
               set --export GRADLE_USER_HOME "/Volumes/realme/.gradle"
               set --export BUN_INSTALL "/Volumes/realme/.bun"
               fish_add_path --prepend "/Volumes/realme/.bun/bin"
           end

          fish_vi_key_bindings
          bind -M insert \cr history-pager
          # Emulate Vim cursor shapes
          set fish_cursor_default block
          set fish_cursor_insert line
          set fish_cursor_replace_one underscore
          set fish_cursor_replace underscore
          set fish_cursor_external line
          set fish_cursor_visual block
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
