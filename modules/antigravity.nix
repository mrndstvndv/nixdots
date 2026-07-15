{ config, ... }:

{
  home.file.".gemini/config/hooks.json".text = builtins.toJSON {
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
}
