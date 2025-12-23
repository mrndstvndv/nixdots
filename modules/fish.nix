{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Source nix-darwin environment if not already done
      if test -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE"
        fish_add_path --prepend /run/current-system/sw/bin
        fish_add_path --prepend $HOME/.nix-profile/bin

        # Use external storage on macOS if available
        if test (uname) = Darwin; and test -d "/Volumes/realme"
            set --export UV_CACHE_DIR "/Volumes/realme/.cache/uv"
            set --export GRADLE_USER_HOME "/Volumes/realme/.gradle"
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
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
