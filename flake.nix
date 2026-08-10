{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    neru.url = "github:y3owk1n/neru";
    neru.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-homebrew.inputs.brew-src.url = "github:Homebrew/brew/6.0.15";
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
    homebrew-egoist = {
      url = "github:egoist/homebrew-tap";
      flake = false;
    };
    homebrew-thermalforge = {
      url = "github:ProducerGuy/homebrew-tap";
      flake = false;
    };
    homebrew-nikitabobko = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };


    piAgent = {
      url = "github:mrndstvndv/pi-coding-agent-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

   outputs = inputs@{ self, nix-darwin, nixpkgs, neru, home-manager, nix-homebrew, homebrew-core, homebrew-cask, homebrew-smctemp, homebrew-egoist, homebrew-thermalforge, homebrew-nikitabobko, piAgent ? null }:
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

      bunVersion = "1.3.14";
      bunOverlay = final: prev: {
        # nixpkgs is still on 1.3.13.
        bun = prev.bun.overrideAttrs (_: {
          version = bunVersion;
          src = final.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${bunVersion}/bun-darwin-aarch64.zip";
            hash = "sha256-2LliIYKK1vl6x6wKt+lYcjQa92MAHogD6CZ2UsJlJiA=";
          };
        });
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
          extraSpecialArgs = { inherit piAgent; };
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
         home-manager.extraSpecialArgs = { inherit piAgent; };
         home-manager.backupFileExtension = "backup";
         home-manager.users.steven = {
           imports = [
             ./darwin/home.nix
           ];
         };

         # List packages installed in system profile. To search by name, run:
         # $ nix-env -qaP | grep wget
         # Keep nix-darwin's activation checker rooted. Determinate Nixd's
         # automatic GC otherwise removes this build-time dependency after
         # each switch, forcing ShellCheck to be downloaded again.
         environment.systemPackages = [ pkgs.shellcheck ];
          environment.systemPath = [
            "/nix/var/nix/profiles/default/bin"
            "/opt/homebrew/bin"
          ];


      # For darwin-nix to work on determinate nix
      nix.enable = false;

      # Necessary for using flakes on this system.
      # nix.settings.experimental-features = "nix-command flakes";
      # nix.optimise.automatic = true;

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;
      environment.shells = [ pkgs.fish ];

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
      specialArgs = { inherit home-manager; inherit (inputs) homebrew-core homebrew-cask homebrew-smctemp homebrew-egoist homebrew-thermalforge homebrew-nikitabobko; };
      modules = [ 
        inputs.nix-homebrew.darwinModules.nix-homebrew
        ./modules/nix-homebrew.nix
        ./modules/mount-realme.nix
        ./modules/herdr-daemon.nix
        { nixpkgs.overlays = [ androidCliOverlay bunOverlay ]; }
        neru.darwinModules.default
        { nixpkgs.overlays = [ neru.overlays.default ]; }
        { services.neru.enable = true; }
        configuration 
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
