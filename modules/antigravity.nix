{ config, pkgs, ... }:

let
  statusLine = pkgs.writeShellScript "antigravity-statusline" ''
    ${pkgs.jq}/bin/jq -r '
      def compact:
        if . >= 1000000 then "\((. / 100000 | floor) / 10)M"
        elif . >= 1000 then "\((. / 100 | floor) / 10)k"
        else tostring
        end;

      .context_window as $context
      | select($context.used_percentage != null)
      | (($context.total_input_tokens // 0) + ($context.total_output_tokens // 0)) as $used
      | "ctx \($used | compact)/\($context.context_window_size | compact) \((($context.used_percentage * 10 | floor) / 10))%"
    '
  '';
in
{
  home.file = {
    ".gemini/antigravity-cli/settings.json".force = true;
    ".gemini/antigravity-cli/settings.json".text = builtins.toJSON {
      allowNonWorkspaceAccess = true;
      editor = "nvim";
      enableTelemetry = false;
      model = "Gemini 3.7 Flash (Medium)";
      notifications = true;
      showFeedbackSurvey = false;
      statusLine = {
        type = "command";
        command = "${statusLine}";
        enabled = true;
        stack_with_default = true;
      };
      toolPermission = "always-proceed";
      trustedWorkspaces = [
        "/Volumes/realme/Dev/chobi"
        "${config.home.homeDirectory}/Library/Application Support/worktree-tui/Volumes-realme-Dev-chobi/splash-fix"
        "/Volumes/realme/Dev/KernelMan"
        "${config.home.homeDirectory}/Downloads"
        "/Volumes/realme/Dev/kiyoko"
        "${config.home.homeDirectory}/.copilot/repos/copilot-worktrees/Search/crimera-shiny-fiesta"
        "${config.home.homeDirectory}/Library/Application Support/worktree-tui/Volumes-realme-Dev-chobi/navigation-3"
        "${config.home.homeDirectory}/Library/Application Support/worktree-tui/Volumes-realme-Dev-Search/nav3"
        config.home.homeDirectory
        "/Volumes/realme/Dev/Search"
        "/Volumes/realme/Dev/expressive-design"
        "/Volumes/realme/Dev/TextGrab"
        "${config.home.homeDirectory}/.config/nixdots"
        "/Volumes/realme/Dev/prism-offline-patcher"
        "/Volumes/realme/Dev/termux-app"
        "/Volumes/realme/Dev/build-ladybird-macos"
        "/Volumes/realme/Dev/termux-ghostty"
        "${config.home.homeDirectory}/Library/Application Support/worktree-tui/Volumes-realme-Dev-termux-ghostty/url-parsing"
        "/Volumes/realme/Dev/piko"
        "/Volumes/realme/Dev/ARSCLib"
        "/Volumes/realme/Dev"
        "/Volumes/realme/Dev/ecto-v2"
        "/Volumes/realme/Dev/ecto-rs"
        "/Volumes/realme/Dev/dsh"
        "/Volumes/realme/Dev/piko-x-lite"
        "/Volumes/realme/Dev/twitter-analysis/apks"
        "/Volumes/realme/Dev/pi"
      ];
    };

    # Register shared skill dirs outside the default discovery paths
    ".gemini/config/skills.json".text = builtins.toJSON {
      entries = [
        { path = "${config.home.homeDirectory}/.agents/skills"; }
      ];
    };

    ".gemini/config/hooks.json".text = builtins.toJSON {
      agent-stop-notifier = {
        Stop = [
          {
            type = "command";
            command = "${config.home.homeDirectory}/.config/nixdots/bin/antigravity-stop-hook";
            timeout = 10;
          }
        ];
      };
    };
  };
}
