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
          "antigravity-claude-opus-4-5-thinking" = {
            name = "Claude Opus 4.5 Thinking (Antigravity)";
            limit = { context = 200000; output = 64000; };
            modalities = { input = ["text" "image" "pdf"]; output = ["text"]; };
            variants = {
              low = { thinkingConfig = { thinkingBudget = 8192; }; };
              max = { thinkingConfig = { thinkingBudget = 32768; }; };
            };
          };
          "antigravity-gemini-3-pro" = {
            name = "Gemini 3 Pro (Antigravity)";
            limit = { context = 1048576; output = 65535; };
            modalities = { input = ["text" "image" "pdf"]; output = ["text"]; };
            variants = {
              low = { thinkingLevel = "low"; };
              high = { thinkingLevel = "high"; };
            };
          };
          "antigravity-gemini-3-flash" = {
            name = "Gemini 3 Flash (Antigravity)";
            limit = { context = 1048576; output = 65536; };
            modalities = { input = ["text" "image" "pdf"]; output = ["text"]; };
            variants = {
              minimal = { thinkingLevel = "minimal"; };
              low = { thinkingLevel = "low"; };
              medium = { thinkingLevel = "medium"; };
              high = { thinkingLevel = "high"; };
            };
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

  home.file.".config/opencode/AGENTS.md".text = ''
    Do not write code before stating assumptions.
    Do not claim correctness you haven't verified.
    Do not handle only the happy path.
    Under what conditions does this work?
  '';

  home.file.".config/opencode/skill/llms-txt/SKILL.md".source = ./skills/llms-txt/SKILL.md;

  home.file.".config/opencode/plugin/notify.ts".source = ./plugins/notify.ts;

}
