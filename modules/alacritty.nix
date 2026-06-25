{ ... }:
{
  home.file.".config/alacritty/alacritty.toml".text = ''
    [window]
    opacity = 0.95
    blur = true
    decorations = "Buttonless"
    option_as_alt = "OnlyLeft"
    dynamic_padding = true
    padding = { x = 6, y = 6 }

    [font]
    size = 16.0

    [selection]
    save_to_clipboard = true

    [mouse]
    hide_when_typing = true
  '';
}
