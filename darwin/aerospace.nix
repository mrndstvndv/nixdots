{ ... }:
{
  programs.aerospace = {
    enable = true;
    launchd.enable = true;
    settings = {
      config-version = 2;
      persistent-workspaces = [
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
      ];
      start-at-login = true;

      # Ghostty workaround: prevent tabs from being tiled as separate windows
      # https://ghostty.org/docs/help/macos-tiling-wms
      on-window-detected = [
        {
          "if".app-id = "com.mitchellh.ghostty";
          run = [ "layout tiling" ];
        }
      ];

      mode.main.binding = {
        alt-enter = ''exec-and-forget open -a "/Users/steven/Applications/Home Manager Apps/Ghostty.app"'';

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        alt-shift-semicolon = "mode service";
      };
      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        down = "volume down";
        up = "volume up";
      };
    };
  };
}
