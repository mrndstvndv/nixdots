{ pkgs, lib, ... }:

let
  mountRealme = pkgs.writeTextFile {
    name = "mount-realme";
    executable = true;
    text = ''
      #!/bin/sh
      # Wait for the realme disk to be recognized and mount it.
      #
      # Mounts via the `mount` CLI instead of `diskutil mount`: determinate-nixd
      # registers a DiskArbitration dissenter (to protect /nix) whose rejection
      # also blocks DiskArbitration mounts of the whole container — every
      # `diskutil mount` of this volume fails with kDAReturnNotPrivileged. The
      # `mount` CLI calls mount_apfs directly, bypassing DiskArbitration, which
      # is how /nix itself gets mounted from fstab.
      VOLUME_NAME="realme"
      MOUNT_POINT="/Volumes/$VOLUME_NAME"
      i=1
      while [ "$i" -le 30 ]; do
        # Resolve the device node for the volume by name (read-only lookup).
        DEVICE=$(/usr/sbin/diskutil info "$VOLUME_NAME" 2>/dev/null | /usr/bin/sed -n 's/.*Device Identifier: *\(disk[0-9]*s[0-9]*\).*/\/dev\/\1/p')
        if [ -z "$DEVICE" ]; then
          echo "Waiting for disk $VOLUME_NAME to appear... (attempt $i/30)"
          /bin/sleep 1
          i=$((i + 1))
          continue
        fi

        # Check if it's already mounted.
        if /usr/sbin/diskutil info "$VOLUME_NAME" 2>/dev/null | /usr/bin/grep -q "Mounted: *Yes"; then
          echo "Disk $VOLUME_NAME is already mounted."
          exit 0
        fi

        /bin/mkdir -p "$MOUNT_POINT"
        if /sbin/mount -t apfs -o rw,noatime "$DEVICE" "$MOUNT_POINT" 2>/tmp/mount-realme.err; then
          echo "Successfully mounted disk $VOLUME_NAME ($DEVICE)."
          exit 0
        fi

        echo "Waiting for disk $VOLUME_NAME... (attempt $i/30) $(/bin/cat /tmp/mount-realme.err)"
        /bin/sleep 1
        i=$((i + 1))
      done

      echo "Failed to mount disk $VOLUME_NAME after 30 attempts."
      exit 1
    '';
  };
in
{
  # macOS System Policy blocks launchd daemons from reading/executing
  # scripts straight out of /nix/store (see herdr-daemon.nix for the same
  # issue) — so install the script to /usr/local/sbin at activation and
  # have launchd execute it from there instead of a Nix store path.
  #
  # NOTE: nix-darwin's activation script assembly only runs the scripts in
  # its hardcoded list (preActivation/extraActivation/postActivation/etc.),
  # so a custom name like `mountRealme` would silently never run. extraActivation
  # is one of the supported user extension points.
  system.activationScripts.extraActivation.text = lib.mkAfter ''
    install -d -m 0755 /usr/local/sbin
    install -m 0755 ${mountRealme} /usr/local/sbin/mount-realme
  '';

  launchd.daemons.mount-realme = {
    command = "/usr/local/sbin/mount-realme";
    serviceConfig = {
      Label = "org.nixos.mount-realme";
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/var/log/mount-realme.log";
      StandardErrorPath = "/var/log/mount-realme.err.log";
    };
  };
}