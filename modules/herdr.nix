{ pkgs, ... }:
let
  tabBarStatus = if pkgs.stdenv.isDarwin then ''
    tab_bar_right = [
      { type = "command", command = "/opt/homebrew/bin/smctemp -c | sed 's/$/°/'", interval_seconds = 2, timeout_seconds = 2 },
      { type = "command", command = "used=$(vm_stat | awk '/page size of/ { page_size = $8 } /^Pages active:/ { active = $3 } /^Pages wired down:/ { wired = $4 } /^Pages purgeable:/ { purgeable = $2 } /^Pages occupied by compressor:/ { compressed = $5 } END { printf \"%.0fG\", (active + wired + compressed - purgeable) * page_size / 1024 / 1024 / 1024 }'); total=$(sysctl -n hw.memsize); echo RAM:$used/$((total / 1024 / 1024 / 1024))G", interval_seconds = 2, timeout_seconds = 2 },
      { type = "command", command = "sysctl -n vm.swapusage | sed -E 's|.*total *= *([^ ]+) +used *= *([^ ]+).*|SW:\\2/\\1|'", interval_seconds = 2, timeout_seconds = 2 },
    ]
    tab_bar_right_separator = " | "
  '' else "";
in
{
  home.file.".config/herdr/config.toml".text = ''
    onboarding = false

    [ui]
    prompt_new_tab_name = false
    show_agent_labels_on_pane_borders = false
    sidebar_collapsed_mode = "hidden"
    ${tabBarStatus}

    [keys]
    settings = ""
    workspace_picker = "prefix+s"
    previous_workspace = "ctrl+J"
    next_workspace = "ctrl+K"
    split_vertical = "prefix+%"
    split_horizontal = 'prefix+"'
    detach = ["prefix+q", "prefix+d"]
    focus_pane_left = "prefix+left"
    focus_pane_down = "prefix+down"
    focus_pane_up = "prefix+up"
    focus_pane_right = "prefix+right"

    [[keys.command]]
    key = "prefix+l"
    type = "pane"
    command = "lazygit"

    [[keys.command]]
    key = "prefix+t"
    type = "pane"
    command = "wt exit"
    description = "git worktree manager"

    [ui.toast]
    delivery = "terminal"

    [ui.sound]
    enabled = false

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
