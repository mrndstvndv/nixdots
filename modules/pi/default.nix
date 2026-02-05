{ pkgs, lib, ... }:
{
  home.file.".pi/agent/AGENTS.md".source = ./AGENTS.md;
  home.file.".pi/agent/settings.json".source = ./settings.json;

  # Copy package to ~/.pi/packages/nixdots-extensions to allow node_modules to work
  # (Symlinks resolve to Nix store where node_modules doesn't exist)
  home.activation.installPiExtensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
    pkgDir="$HOME/.pi/packages/nixdots-extensions"
    mkdir -p "$pkgDir"
    
    # Sync files from store, overwriting existing ones but preserving node_modules
    # We use rsync to efficiently update and handle permissions
    ${pkgs.rsync}/bin/rsync -a --chmod=u+w --exclude=node_modules --exclude=package-lock.json ${./package}/ $pkgDir/
  '';
}
