{ pkgs, ... }:
{
  home.file.".config/opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
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
}
