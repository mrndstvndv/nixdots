{ pkgs, ... }:
{
  home.file.".pi/agent/AGENTS.md".source = ./AGENTS.md;
  home.file.".pi/agent/settings.json".source = ./settings.json;
  home.file.".pi/agent/extensions".source = ./extensions;
}
