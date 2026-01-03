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
    my-neovim.url = "github:crimera/nvim.config";
    opencode.url = "github:crimera/opencode-flake";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      # Reuse our home-manager input inside nix-on-droid
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, zen, home-manager, my-neovim, nix-homebrew, homebrew-core, homebrew-cask, nix-on-droid }:
   let
      configuration = { pkgs, zen, home-manager, nixpkgs, ... }:
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
            home-manager.extraSpecialArgs = { inherit (inputs) my-neovim opencode; };
           home-manager.backupFileExtension = "backup";
          home-manager.users.steven = {
            imports = [
              ./home-manager.nix
              ./darwin/home.nix
            ];
          };
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages =
           [
 	zenWithPolicies
           ];



      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

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
      specialArgs = { inherit zen home-manager; inherit (inputs) my-neovim homebrew-nix homebrew-core homebrew-cask; };
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
        { _module.args.my-neovim = my-neovim; }
        ./nix-on-droid/system.nix
      ];
    };
  };
}
