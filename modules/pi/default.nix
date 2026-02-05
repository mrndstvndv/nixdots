{ pkgs, lib, ... }:
{
  home.file.".pi/agent/AGENTS.md".source = ./AGENTS.md;
  home.file.".pi/agent/settings.json".source = ./settings.json;

  # Copy package to ~/.pi/packages/nixdots-extensions to allow node_modules to work
  # (Symlinks resolve to Nix store where node_modules doesn't exist)
  home.activation.installPiExtensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
    pkgDir="$HOME/.pi/packages/nixdots-extensions"
    mkdir -p "$pkgDir"
    
    # Sync files from store. --delete removes stale files from target.
    # --exclude protects node_modules and package-lock.json from being deleted.
    ${pkgs.rsync}/bin/rsync -a --chmod=u+w --delete --exclude=node_modules --exclude=package-lock.json ${./package}/ $pkgDir/
  '';
}
