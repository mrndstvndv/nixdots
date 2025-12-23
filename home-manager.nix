{
  pkgs,
  nixpkgs,
  my-neovim,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = [
    my-neovim.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.bun
    pkgs.lazygit
    pkgs.gh
    pkgs.git
    pkgs.daisydisk
    pkgs.raycast
    pkgs.cursor-cli
  ];

  home.sessionPath = [
    "/Users/steven/.bun/bin"
  ];

  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;

  programs.aerospace = {
    enable = true;
    launchd.enable = true;
    settings = {
      start-at-login = true;

      mode.main.binding = {
        alt-enter = ''exec-and-forget open -a "/Users/steven/Applications/Home Manager Apps/Ghostty.app"'';

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        alt-shift-semicolon = "mode service";
      };
      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        down = "volume down";
        up = "volume up";
      };
    };
  };

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
        # Emulates vim's cursor shape behavior
        # Set the normal and visual mode cursors to a block
        set fish_cursor_default block
        # Set the insert mode cursor to a line
        set fish_cursor_insert line
        # Set the replace mode cursors to an underscore
        set fish_cursor_replace_one underscore
        set fish_cursor_replace underscore
        # Set the external cursor to a line. The external cursor appears when a command is started.
        # The cursor shape takes the value of fish_cursor_default when fish_cursor_external is not specified.
        set fish_cursor_external line
        # The following variable can be used to configure cursor shape in
        # visual mode, but due to fish_cursor_default, is redundant here
        set fish_cursor_visual block
      end
    '';
  };

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    enableFishIntegration = true;

    settings = {
      command = "${pkgs.fish}/bin/fish --login -c '${pkgs.tmux}/bin/tmux new -As0'";
      background-opacity = "0.9";
      background-blur = true;

      window-padding-x = 0;
      window-padding-y = 0;
      window-padding-balance = true;
      window-padding-color = "extend";
      window-decoration = false;

      font-size = 16;
    };
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -sg escape-time 5

      bind -n M-k select-pane -U
      bind -n M-j select-pane -D
      bind -n M-h select-pane -L
      bind -n M-l select-pane -R

      bind -n M-Left previous-window
      bind -n M-Right next-window

      set-window-option -g mode-keys vi

      set -g status-position top

      set -g status-right "#($HOME/.local/bin/tmux_status.sh)"

       set-option -g default-shell "${pkgs.fish}/bin/fish"

      # toggle opencode pane in current directory
      bind-key o run-shell "~/.local/bin/toggle_opencode.sh"

      # toggle lazygit pane in current directory
      bind-key l display-popup -E -d "#{pane_current_path}" -w 90% -h 90% "lazygit"

      # open new windows in current path
      bind-key c new-window -c "#{pane_current_path}"

      # split panes in current path
      bind-key '"' split-window -v -c "#{pane_current_path}"
      bind-key % split-window -h -c "#{pane_current_path}"

      set -g mouse on

      unbind-key -n C-r

      # bind -r -n C-S-Left resize-pane -L 5

      # rename window with Ctrl+b r
      bind-key r command-prompt -I "#W" "rename-window '%%'"

      set-window-option -g automatic-rename on
      set-window-option -g automatic-rename-format '#{b:pane_current_path}'
    '';
  };

  home.stateVersion = "26.05";
}
