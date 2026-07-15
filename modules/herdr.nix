{ pkgs, ... }:
{
  home.file.".config/herdr/config.toml".text = ''
    onboarding = false

    [ui]
    prompt_new_tab_name = false
    show_agent_labels_on_pane_borders = false

    [keys]
    settings = ""
    workspace_picker = "prefix+s"
    previous_workspace = "prefix+("
    next_workspace = "prefix+)"
    split_vertical = "prefix+%"
    split_horizontal = 'prefix+"'
    detach = ["prefix+q", "prefix+d"]
    focus_pane_right = ""

    [[keys.command]]
    key = "prefix+l"
    type = "pane"
    command = "lazygit"

    [ui.toast]
    delivery = "terminal"

    [ui.sound]
    enabled = true

    [experimental]
    pane_history = true

    [terminal]
    default_shell = "fish"

    [session]
    resume_agents_on_restore = true

    [theme]
    name = "terminal"
  '';
}
