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
      "opencode-antigravity-auth@1.2.8"
    ];
    provider = {
      google = {
        models = {
          "antigravity-claude-opus-4-5-thinking-low" = {
            name = "Claude Opus 4.5 Think Low (Antigravity)";
            limit = { context = 200000; output = 64000; };
            modalities = { input = ["text" "image" "pdf"]; output = ["text"]; };
          };
          "antigravity-claude-opus-4-5-thinking-medium" = {
            name = "Claude Opus 4.5 Think Medium (Antigravity)";
            limit = { context = 200000; output = 64000; };
            modalities = { input = ["text" "image" "pdf"]; output = ["text"]; };
          };
          "antigravity-claude-opus-4-5-thinking-high" = {
            name = "Claude Opus 4.5 Think High (Antigravity)";
            limit = { context = 200000; output = 64000; };
            modalities = { input = ["text" "image" "pdf"]; output = ["text"]; };
          };
          "antigravity-gemini-3-pro-low" = {
            name = "Gemini 3 Pro Low (Antigravity)";
            limit = { context = 1048576; output = 65535; };
            modalities = { input = ["text" "image" "pdf"]; output = ["text"]; };
          };
          "antigravity-gemini-3-pro-high" = {
            name = "Gemini 3 Pro High (Antigravity)";
            limit = { context = 1048576; output = 65535; };
            modalities = { input = ["text" "image" "pdf"]; output = ["text"]; };
          };
          "antigravity-gemini-3-flash" = {
            name = "Gemini 3 Flash (Antigravity)";
            limit = { context = 1048576; output = 65536; };
            modalities = { input = ["text" "image" "pdf"]; output = ["text"]; };
          };
        };
      };
    };
    agent = {
      coder = {
        description = "Primary coding agent using GLM-4.7";
        mode = "subagent";
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
