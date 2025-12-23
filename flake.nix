{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    zen.url = "github:0xc000022070/zen-browser-flake";
    zen.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, zen, home-manager}:
   let
      configuration = { pkgs, zen, home-manager, ... }:
       let
         zenWithPolicies =
           pkgs.wrapFirefox
             (zen.packages.aarch64-darwin.beta-unwrapped.override {
               policies = {
                 DisableAppUpdate = true;
                 DisableTelemetry = true;
               };
             })
             {
               icon = "zen-browser";
             };
       in
        {
          imports = [ inputs.home-manager.darwinModules.home-manager ];
          users.users.steven = {
            name = "steven";
            home = "/Users/steven";
          };
          home-manager.users.steven = { pkgs, ... }: {
            home.packages = [
	      pkgs.neovim
	      pkgs.bun
	      pkgs.lazygit
	      pkgs.gh
	      pkgs.git
	      pkgs.zoxide
	    ];

	    home.sessionPath = [
	      "/Users/steven/.bun/bin"
	    ];

            programs.zsh.enable = true;

	    programs.ghostty = {
	      enable = true;
	      package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
	      enableZshIntegration = true;

	      settings = {
		command = "/run/current-system/sw/bin/tmux new -As0";

		background-opacity = "0.9";
		background-blur = true;
		
		window-padding-x = 0;
		window-padding-y = 0;
		window-padding-balance = true;
		window-padding-color = "extend";
		window-decoration = false;

		font-size = 20;
	      };
	    };

            home.stateVersion = "26.05";
          };
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages =
           [
 	pkgs.aerospace
 	pkgs.raycast
 	zenWithPolicies
           ];

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
        specialArgs = { inherit zen home-manager; };
        modules = [ configuration ];
      };
  };
}
