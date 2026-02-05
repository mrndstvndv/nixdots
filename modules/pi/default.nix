{ pkgs, lib, ... }:
{
  home.file.".pi/agent/AGENTS.md".source = ./AGENTS.md;
  home.file.".pi/agent/settings.json".source = ./settings.json;

  # Copy package to ~/.pi/packages/nixdots-extensions to allow node_modules to work
  # (Symlinks resolve to Nix store where node_modules doesn't exist)
  home.activation.installPiExtensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
    pkgDir="$HOME/.pi/packages/nixdots-extensions"
    mkdir -p "$pkgDir"
    
    # Remove managed files/dirs to ensure clean slate (avoids stale files)
    # node_modules and package-lock.json are NOT removed
    rm -rf "$pkgDir/extensions"
    rm -f "$pkgDir/package.json"
    rm -f "$pkgDir/README.md"

    # Copy fresh content from store (dereferencing symlinks with -L)
    cp -Lr ${./package}/* "$pkgDir"/
  '';
}
