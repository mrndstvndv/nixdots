{ pkgs, ... }:
{
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

      # set -g status-position top

      # Statusbar styling - Gruvbox dark inspired
      set -g status-style 'bg=default,fg=default'

      # Left: session name in warm orange-brown
      set -g status-left '#[fg=colour130,bold]#S #[fg=default]| '
      set -g status-left-length 20

      # Right: disabled
      set -g status-right ""

      # Window list: minimal format
      set -g window-status-format '#[fg=colour245]#I #W '
      set -g window-status-current-format '#[fg=colour223,bold]#I #W '

      # Remove separators
      set -g window-status-separator ""

      set-option -g default-shell "${pkgs.fish}/bin/fish"
      set-option -g default-command "${pkgs.fish}/bin/fish -i"

      # toggle lazygit pane in current directory
      bind-key l display-popup -E -d "#{pane_current_path}" -w 90% -h 90% "lazygit"

      # open new windows in current path
      bind-key c new-window -c "#{pane_current_path}"

      # split panes in current path
      bind-key '"' split-window -v -c "#{pane_current_path}"
      bind-key % split-window -h -c "#{pane_current_path}"

      set -g mouse on

      unbind-key -n C-r

      # rename window with Ctrl+b r
      bind-key r command-prompt -I "#W" "rename-window '%%'"

      set-window-option -g automatic-rename on
      set-window-option -g automatic-rename-format '#{b:pane_current_path}'
    '';
  };
}
