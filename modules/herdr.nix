{ pkgs, ... }:
{
  home.file.".config/herdr/config.toml".text = ''
    onboarding = false

    [terminal]
    default_shell = "fish"
    shell_mode = "auto"
    new_cwd = "follow"

    [session]
    resume_agents_on_restore = true
  '';
}
