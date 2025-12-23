{ pkgs, ... }:
{
  home.packages = [
    pkgs.neovim
    pkgs.bun
    pkgs.lazygit
    pkgs.gh
    pkgs.git
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
        esc = ["reload-config" "mode main"];
	down = "volume down";
	up = "volume up";
      };
    };
  };

  programs.fish.enable = true;

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    enableFishIntegration = true;

    settings = {
      command = "${pkgs.tmux}/bin/tmux new -As0";

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
