{ pkgs, lib, config, ... }:
let
  # Build the pi extensions package with its npm dependencies
  piExtensions = pkgs.buildNpmPackage {
    pname = "nixdots-pi-extensions";
    version = "1.0.0";
    src = ./package;
    npmDepsHash = "sha256-fm99F+/XWFDWTRmE1ZkdKbPL9gW7DNbgRSgkGBifzeI=";
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out
      cp -r . $out/
    '';
  };

  # Generate settings.json with the nix store path baked in
  piSettings = builtins.fromJSON (builtins.readFile ./settings.json);
  piSettingsFinal = piSettings // {
    # Reference the package directly in the nix store (fully deterministic)
    packages = [ "${piExtensions}" ];
  };
in
{
  home.packages = with pkgs; [
    ddgr
  ];

  home.file.".pi/agent/AGENTS.md".source = ./AGENTS.md;
  
  # Subagent definitions managed by nix
  home.file.".pi/agent/agents/scout.md".source = ./agents/scout.md;
  
  # Pure, generated settings.json - no symlinks, no mutable state
  home.file.".pi/agent/settings.json".text = builtins.toJSON piSettingsFinal;
}
