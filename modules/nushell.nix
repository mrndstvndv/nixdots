{ pkgs, ... }:
{
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      # Use Vi modal editing (normal/insert)
      edit_mode = "vi";
    };
    shellAliases = {
      ll = "ls -lah";
    };
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };
}
