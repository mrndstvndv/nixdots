{ pkgs, ... }:
{
  home.file.".config/herdr/config.toml".text = ''
    onboarding = false

    [theme]
    name = "terminal"

    [ui]
    prompt_new_tab_name = false

    [keys]
    focus_pane_right = ""
    detach = "prefix+d"
    split_vertical = "prefix+%"
    split_horizontal = "prefix+\""

    [terminal]
    default_shell = "fish"
    shell_mode = "auto"
    new_cwd = "follow"

    [[keys.command]]
    key = "prefix+l"
    type = "pane"
    command = "lazygit"
    description = "open lazygit"

    [session]
    resume_agents_on_restore = true
  '';
}
