{ pkgs, ... }:
{
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      edit_mode = "vi";
    };
    shellAliases = {
      ll = "ls -lah";
    };
    extraConfig = ''
      # Remove right-side date/time in the prompt (disable right prompt)
      $env.PROMPT_COMMAND_RIGHT = ""

      # Add nix paths to PATH
      $env.PATH = ($env.PATH | split row (char esep) | prepend "~/.nix-profile/bin")
      $env.PATH = ($env.PATH | split row (char esep) | prepend "/run/current-system/sw/bin")
    '';
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };
}
