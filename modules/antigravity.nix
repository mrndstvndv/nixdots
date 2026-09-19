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

    ".gemini/config/hooks/herdr-agent-state.sh" = {
      executable = true;
      force = true;
      text = ''
        #!/bin/sh
        # installed by herdr
        # managed by herdr; reinstalling or updating the integration overwrites this file.
        # add custom hooks beside this file instead of editing it.
        # HERDR_INTEGRATION_ID=antigravity_cli
        # HERDR_INTEGRATION_VERSION=3

        # Session-only: this hook reports the Antigravity conversation so Herdr can
        # resume the pane. Lifecycle state comes from Herdr's screen detection.

        set -eu

        # Antigravity CLI expects a JSON object on stdout and this hook never injects
        # anything, so every exit path emits an empty object.
        emit_and_exit() {
          printf '{}\n'
          exit 0
        }

        [ "''${1:-}" = "session" ] || emit_and_exit
        [ "''${HERDR_ENV:-}" = "1" ] || emit_and_exit
        [ -n "''${HERDR_SOCKET_PATH:-}" ] || emit_and_exit
        [ -n "''${HERDR_PANE_ID:-}" ] || emit_and_exit
        command -v python3 >/dev/null 2>&1 || emit_and_exit

        python3 -c '
        import json
        import os
        import socket
        import sys
        import time

        try:
            payload = json.load(sys.stdin)
        except Exception:
            raise SystemExit(0)

        if not isinstance(payload, dict):
            raise SystemExit(0)

        def text(name):
            value = payload.get(name)
            return value if isinstance(value, str) and value else None

        session_id = text("conversationId")
        if session_id is None:
            raise SystemExit(0)

        seq = time.time_ns()
        params = {
            "pane_id": os.environ["HERDR_PANE_ID"],
            "source": "herdr:antigravity_cli",
            "agent": "agy",
            "seq": seq,
            "agent_session_id": session_id,
        }

        transcript_path = text("transcriptPath")
        if transcript_path is not None:
            params["agent_session_path"] = transcript_path

        request = json.dumps({
            "id": f"herdr:antigravity_cli:{seq}",
            "method": "pane.report_agent_session",
            "params": params,
        })
        try:
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
                client.settimeout(0.5)
                client.connect(os.environ["HERDR_SOCKET_PATH"])
                client.sendall((request + "\n").encode())
                client.recv(4096)
        except Exception:
            pass
        ' 2>/dev/null || true

        emit_and_exit
      '';
    };

    ".gemini/config/hooks.json".force = true;
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
      herdr = {
        PreInvocation = [
          {
            type = "command";
            command = "bash '${config.home.homeDirectory}/.gemini/config/hooks/herdr-agent-state.sh' session";
            timeout = 10;
          }
        ];
      };
    };
  };
}
