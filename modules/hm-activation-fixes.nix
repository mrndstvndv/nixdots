{
  config,
  lib,
  ...
}:

# Home Manager's activation still calls `nix profile install`, which recent
# Nix (2.33+/Determinate) deprecates in favour of `nix profile add`, printing:
#   warning: 'install' is a deprecated alias for 'add'
#
# Upstream can't rename unconditionally because Lix only ships `install`
# (revert #8835). This reimplements the installPackages step with a feature
# probe: prefer `add`, fall back to `install`.
#
# TODO(home-manager#9598): DELETE this module once upstream probes for
# `nix profile add` itself, then verify with `git -C ~/.config/nixdots log
# --oneline -- modules/hm-activation-fixes.nix` before removing.
# Track: https://github.com/nix-community/home-manager/issues/9598
let
  inherit (config.home) path profileDirectory;
in
{
  home.activation.installPackages = lib.mkForce (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ -e ${profileDirectory}/manifest.json ]] ; then
      nixProfileRemove 'home-manager-path'

      if nix profile add --help &> /dev/null ; then
        run nix profile add ${path}
      else
        run nix profile install ${path}
      fi
    else
      run nix-env -i ${path}
    fi
  '');
}
