{ pkgs, ... }:
{
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
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
