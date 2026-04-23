{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    neru.url = "github:y3owk1n/neru";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    my-neovim.url = "github:crimera/nvim.config";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
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

    piAgent = {
      url = "github:mrndstvndv/pi-coding-agent-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

   outputs = inputs@{ self, nix-darwin, nixpkgs, neru, home-manager, my-neovim, codex, nix-homebrew, homebrew-core, homebrew-cask, homebrew-smctemp, nix-on-droid, piAgent ? null }:
   let
      supportedStandaloneHomeSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      androidCliSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      androidCliOverlay = final: prev: {
        android-cli = final.callPackage ./pkgs/android-cli.nix { };
      };

      currentStandaloneHomeSystem =
        if !(builtins ? currentSystem) then
          throw ''
            homeConfigurations.alpine needs host system detection, which requires impure flake evaluation.
            Use one of:
              - home-manager switch --flake .#alpine --impure
              - nix run .#alpine
              - home-manager switch --flake .#alpine-aarch64-linux
              - home-manager switch --flake .#alpine-x86_64-linux
          ''
        else if builtins.elem builtins.currentSystem supportedStandaloneHomeSystems then
          builtins.currentSystem
        else
          throw ''
            Unsupported standalone Home Manager system: ${builtins.currentSystem}
            Supported systems: ${builtins.concatStringsSep ", " supportedStandaloneHomeSystems}
          '';

      mkStandaloneHomeConfiguration = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit my-neovim codex piAgent; };
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

      mkStandaloneHomeApp = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          homeManager = home-manager.packages.${system}.default;
          switchScript = pkgs.writeShellApplication {
            name = "alpine-home-manager";
            runtimeInputs = [ homeManager ];
            text = ''
              exec home-manager switch --flake ${self.outPath}#alpine-${system} "$@"
            '';
          };
        in {
          type = "app";
          program = "${switchScript}/bin/alpine-home-manager";
        };

      mkAndroidCliPackages = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ androidCliOverlay ];
            config = {
              allowUnfree = true;
              allowUnfreePredicate = (_: true);
            };
          };
          package = pkgs.android-cli;
        in {
          default = package;
          android-cli = package;
        };

      configuration = { pkgs, home-manager, nixpkgs, ... }:
       {
         imports = [ inputs.home-manager.darwinModules.home-manager ];
         nixpkgs.config = {
           allowUnfree = true;
           allowUnfreePredicate = (_: true);
         };
         users.users.steven = {
           name = "steven";
           home = "/Users/steven";
           shell = pkgs.fish;
         };
         home-manager.useGlobalPkgs = true;
         home-manager.extraSpecialArgs = { inherit (inputs) my-neovim codex; inherit piAgent; };
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
         environment.systemPath = [ "/nix/var/nix/profiles/default/bin" ];

      # For darwin-nix to work on determinate nix
      nix.enable = false;

      # Necessary for using flakes on this system.
      # nix.settings.experimental-features = "nix-command flakes";
      # nix.optimise.automatic = true;

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Required for launchd user agents (like neru)
      system.primaryUser = "steven";
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
        neru.darwinModules.default
        { nixpkgs.overlays = [ neru.overlays.default androidCliOverlay ]; }
        { services.neru.enable = true; }
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
        { _module.args.my-neovim = my-neovim; _module.args.piAgent = piAgent; }
        ./nix-on-droid/system.nix
      ];
    };

    packages = nixpkgs.lib.genAttrs androidCliSystems mkAndroidCliPackages;

    apps = nixpkgs.lib.genAttrs supportedStandaloneHomeSystems (system: {
      alpine = mkStandaloneHomeApp system;
    });

    # Standalone Home Manager for Alpine chroot (Termux)
    homeConfigurations = {
      alpine = mkStandaloneHomeConfiguration currentStandaloneHomeSystem;
      alpine-aarch64 = mkStandaloneHomeConfiguration "aarch64-linux";
      alpine-aarch64-linux = mkStandaloneHomeConfiguration "aarch64-linux";
      alpine-x86_64 = mkStandaloneHomeConfiguration "x86_64-linux";
      alpine-x86_64-linux = mkStandaloneHomeConfiguration "x86_64-linux";
    };
  };
}
