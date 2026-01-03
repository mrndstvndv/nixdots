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

  home.file.".config/opencode/skill/ast-grep/SKILL.md".source = ./skill/ast-grep/SKILL.md;
  home.file.".config/opencode/skill/ast-grep/references/rule_reference.md".source = ./skill/ast-grep/references/rule_reference.md;

  home.file.".config/opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    theme = "gruvbox-transparent";
    plugin = [
      "opencode-google-antigravity-auth"
      "opencode-supermemory@latest"
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
      plan.model = "google/gemini-claude-opus-4-5-thinking";
      build.model = "opencode/minimax-m2.1-free";
    };
    default_agent = "plan";
  };

  home.file.".config/opencode/themes/gruvbox-transparent.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/theme.json";
    defs = {
      darkBg0 = "transparent";
      darkBg1 = "transparent";
      darkBg2 = "transparent";
      darkBg3 = "#665c54";
      darkFg0 = "#fbf1c7";
      darkFg1 = "#ebdbb2";
      darkGray = "#928374";
      darkRed = "#cc241d";
      darkGreen = "#98971a";
      darkYellow = "#d79921";
      darkBlue = "#458588";
      darkPurple = "#b16286";
      darkAqua = "#689d6a";
      darkOrange = "#d65d0e";
      darkRedBright = "#fb4934";
      darkGreenBright = "#b8bb26";
      darkYellowBright = "#fabd2f";
      darkBlueBright = "#83a598";
      darkPurpleBright = "#d3869b";
      darkAquaBright = "#8ec07c";
      darkOrangeBright = "#fe8019";
      lightBg0 = "transparent";
      lightBg1 = "transparent";
      lightBg2 = "transparent";
      lightBg3 = "#bdae93";
      lightFg0 = "#282828";
      lightFg1 = "#3c3836";
      lightGray = "#7c6f64";
      lightRed = "#9d0006";
      lightGreen = "#79740e";
      lightYellow = "#b57614";
      lightBlue = "#076678";
      lightPurple = "#8f3f71";
      lightAqua = "#427b58";
      lightOrange = "#af3a03";
    };
    theme = {
      primary = "lightBlue";
      secondary = "lightPurple";
      accent = "lightAqua";
      error = "lightRed";
      warning = "lightOrange";
      success = "lightGreen";
      info = "lightYellow";
      text = "lightFg1";
      textMuted = "lightGray";
      background = "lightBg0";
      backgroundPanel = "lightBg1";
      backgroundElement = "lightBg2";
      border = "lightBg3";
      borderActive = "lightFg1";
      borderSubtle = "lightBg2";
      diffAdded = "lightGreen";
      diffRemoved = "lightRed";
      diffContext = "lightGray";
      diffHunkHeader = "lightAqua";
      diffHighlightAdded = "lightGreen";
      diffHighlightRemoved = "lightRed";
      diffAddedBg = "#e2e0b5";
      diffRemovedBg = "#e9d8d5";
      diffContextBg = "lightBg1";
      diffLineNumber = "lightBg3";
      diffAddedLineNumberBg = "#d4d2a9";
      diffRemovedLineNumberBg = "#d8cbc8";
      markdownText = "lightFg1";
      markdownHeading = "lightBlue";
      markdownLink = "lightAqua";
      markdownLinkText = "lightGreen";
      markdownCode = "lightYellow";
      markdownBlockQuote = "lightGray";
      markdownEmph = "lightPurple";
      markdownStrong = "lightOrange";
      markdownHorizontalRule = "lightGray";
      markdownListItem = "lightBlue";
      markdownListEnumeration = "lightAqua";
      markdownImage = "lightAqua";
      markdownImageText = "lightGreen";
      markdownCodeBlock = "lightFg1";
      syntaxComment = "lightGray";
      syntaxKeyword = "lightRed";
      syntaxFunction = "lightGreen";
      syntaxVariable = "lightBlue";
      syntaxString = "lightYellow";
      syntaxNumber = "lightPurple";
      syntaxType = "lightAqua";
      syntaxOperator = "lightOrange";
      syntaxPunctuation = "lightFg1";
    };
  };
}
