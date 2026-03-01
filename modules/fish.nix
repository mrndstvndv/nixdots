{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
      interactiveShellInit = ''
        # Source nix-darwin environment if not already done
        if test -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE"
          fish_add_path --prepend /run/current-system/sw/bin
          fish_add_path --prepend $HOME/.nix-profile/bin
        end

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
      '';

  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
