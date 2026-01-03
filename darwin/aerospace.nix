{ ... }:
{
  programs.aerospace = {
    enable = true;
    launchd.enable = true;
    settings = {
      start-at-login = true;

      mode.main.binding = {
        alt-enter = ''exec-and-forget open -a "/Users/steven/Applications/Home Manager Apps/Ghostty.app"'';

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";

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
