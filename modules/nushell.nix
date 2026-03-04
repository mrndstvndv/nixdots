{ pkgs, config, lib, ... }:
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
      $env.PATH = ($env.PATH | split row (char esep) | prepend "${config.home.homeDirectory}/.nix-profile/bin")
      $env.PATH = ($env.PATH | split row (char esep) | prepend "/run/current-system/sw/bin")

      # Add custom session paths
      ${lib.concatMapStrings (path: ''
        $env.PATH = ($env.PATH | split row (char esep) | prepend "${path}")
      '') config.home.sessionPath}

      # Add home.sessionVariables to nushell
      ${lib.concatStrings (lib.mapAttrsToList (name: value: ''
        $env.${name} = "${toString value}"
      '') config.home.sessionVariables)}
    '';
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };
}
