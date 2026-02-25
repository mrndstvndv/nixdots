{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    my-neovim.url = "github:crimera/nvim.config";
    opencode.url = "github:mrndstvndv/opencode-flake";
    amp.url = "github:mrndstvndv/amp-flake";
    amp.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-smctemp = {
      url = "github:narugit/homebrew-tap";
      flake = false;
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      # Reuse our home-manager input inside nix-on-droid
      inputs.home-manager.follows = "home-manager";
    };

    # Codex CLI flake from GitHub
    codex = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

   outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, my-neovim, opencode, amp, helium, codex, nix-homebrew, homebrew-core, homebrew-cask, homebrew-smctemp, nix-on-droid }:
   let
      configuration = { pkgs, home-manager, nixpkgs, ... }:
       {
         imports = [ inputs.home-manager.darwinModules.home-manager ];
         users.users.steven = {
           name = "steven";
           home = "/Users/steven";
         };
         home-manager.extraSpecialArgs = { inherit (inputs) my-neovim opencode amp helium codex; };
         home-manager.backupFileExtension = "backup";
         home-manager.users.steven = {
           imports = [
             ./darwin/common.nix
             ./darwin/home.nix
           ];
         };

         # List packages installed in system profile. To search by name, run:
         # $ nix-env -qaP | grep wget
         environment.systemPackages = [];

      # For darwin-nix to work on determinate nix
      nix.enable = false;

      # Necessary for using flakes on this system.
      # nix.settings.experimental-features = "nix-command flakes";
      # nix.optimise.automatic = true;

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#proputer
    darwinConfigurations."proputer" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit home-manager; inherit (inputs) my-neovim homebrew-nix homebrew-core homebrew-cask homebrew-smctemp codex; };
      modules = [ 
        inputs.nix-homebrew.darwinModules.nix-homebrew
        ./modules/nix-homebrew.nix
        configuration 
      ];
    };

    # Nix-on-Droid configuration. Home Manager is wired through
    # nix-on-droid itself (see nix-on-droid/system.nix).
    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = import nixpkgs { system = "aarch64-linux"; };
      modules = [
        # Inject flake input my-neovim into _module.args, so all
        # nix-on-droid modules (including HM) can see it.
        { _module.args.my-neovim = my-neovim; _module.args.amp = amp; }
        ./nix-on-droid/system.nix
      ];
    };

    # Standalone Home Manager for Alpine chroot (Termux)
    homeConfigurations."alpine" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      extraSpecialArgs = { inherit my-neovim opencode amp codex; };
      modules = [
        ./alpine/home.nix
        {
          nixpkgs.config = {
            allowUnfree = true;
            allowUnfreePredicate = (_: true);
          };
        }
      ];
    };
  };
}
