{ ... }:
{
  # Rio terminal config: https://rioterm.com/docs/config
  home.file.".config/rio/config.toml".text = ''
    # Transparency — opacity applies to the window background, blur gives the
    # frosted look. opacity-cells extends it to cells with explicit
    # background colors (tmux, nvim, lazygit panels) so TUIs match the
    # translucent window like ghostty's background-opacity does.
    [window]
    opacity = 0.45
    opacity-cells = true
    blur = true

    [shell]
    program = "/opt/homebrew/bin/fish"
    args = [ "--login" ]

    [fonts]
    size = 18
  '';
}
