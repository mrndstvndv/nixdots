{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    zen.url = "github:0xc000022070/zen-browser-flake";
    zen.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, zen}:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
	pkgs.neovim
	pkgs.ghostty-bin
	pkgs.aerospace
	pkgs.raycast
	pkgs.bun
	pkgs.lazygit
	pkgs.gh
	pkgs.git
        ];

      programs.zsh = {
        enable = true;
	shellInit = ''
	  export PATH="/Users/steven/.bun/bin:$PATH"
	'';
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

	set-option -g default-shell /opt/homebrew/bin/fish

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

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      nixpkgs.config.allowUnfree = true;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Stevens-Mac-mini
    darwinConfigurations."Stevens-Mac-mini" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
