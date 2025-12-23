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
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, zen, home-manager, my-neovim }:
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
           home-manager.extraSpecialArgs = { inherit (inputs) my-neovim; };
           home-manager.users.steven = import ./home-manager.nix;
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
    # $ darwin-rebuild build --flake .#Stevens-Mac-mini
      darwinConfigurations."Stevens-Mac-mini" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit zen home-manager; inherit (inputs) my-neovim; };
        modules = [ configuration ];
      };
  };
}
