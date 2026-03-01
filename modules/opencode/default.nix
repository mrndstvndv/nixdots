{ pkgs, opencode, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;

  extraPackages = with pkgs; [
    ast-grep
    ktlint
    ruff
    pyright
    nixd
  ];

  wrappedOpencode = pkgs.symlinkJoin {
    name = "opencode-wrapped";
    paths = [ opencode.packages.${system}.opencode ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/opencode \
        --suffix PATH : ${pkgs.lib.makeBinPath extraPackages}
    '';
  };
in {
  home.packages = [ wrappedOpencode ];

  home.file.".config/opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    permission = {
      external_directory = {
        "/nix/store/*-zig-*/lib/std/**" = "allow";
      };
      edit = {
        "/nix/store/*-zig-*/lib/std/**" = "deny";
      };
    };
    mcp = {
      context7 = {
        type = "remote";
        url = "https://mcp.context7.com/mcp";
      };
    };

  };

  home.file.".config/opencode/AGENTS.md".text = ''
    Do not write code before stating assumptions.
    Do not claim correctness you haven't verified.
    Do not handle only the happy path.
    Under what conditions does this work?

    Whenever you try to use python to run a python script/program use uv
  '';

  home.file.".config/opencode/skill".source = ./skills;
  # home.file.".config/opencode/plugins".source = ./plugins;
  home.file.".config/opencode/agent".source = ./agents;
  home.file.".config/opencode/command".source = ./commands;

}
