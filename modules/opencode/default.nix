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
    plugin = [
      "opencode-google-antigravity-auth@0.2.12"
      "opencode-supermemory@0.1.5"
    ];
    provider = {
      google.models = {
        "gemini-3-pro-preview".options.thinkingConfig = {
          thinkingLevel = "high";
          includeThoughts = true;
        };
        "gemini-3-flash".options.thinkingConfig = {
          thinkingLevel = "medium";
          includeThoughts = true;
        };
        "gemini-2.5-flash".options.thinkingConfig = {
          thinkingBudget = 8192;
          includeThoughts = true;
        };
        "gemini-claude-opus-4-5-thinking".options.thinkingConfig = {
          thinkingBudget = 32000;
          includeThoughts = true;
        };
      };
    };
    agent = {
      plan = {
        model = "google/gemini-claude-opus-4-5-thinking";
      };
      build = {
        model = "opencode/minimax-m2.1-free";
      };
      coder = {
        description = "Primary coding agent using GLM-4.7";
        mode = "primary";
        model = "opencode/glm-4.7-free";
        temperature = 0.2;
        tools = {
          write = true;
          edit = true;
          bash = true;
        };
      };
    };
    default_agent = "plan";
  };

}
