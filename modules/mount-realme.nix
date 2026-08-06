{ pkgs, lib, ... }:

let
  realmeUuid = "F6DFCF4D-2D36-4697-85A3-A7AAD0B064EA";
  mountRealme = pkgs.writeTextFile {
    name = "mount-realme";
    executable = true;
    text = ''
      #!/bin/sh
      VOLUME_NAME="realme"
      i=1
      while [ "$i" -le 120 ]; do
        if /usr/sbin/diskutil info "$VOLUME_NAME" 2>/dev/null | /usr/bin/grep -q "Mounted: *Yes"; then
          echo "Disk $VOLUME_NAME is already mounted."
          exit 0
        fi

        if /usr/sbin/diskutil mount "$VOLUME_NAME" >/tmp/mount-realme.err 2>&1; then
          echo "Successfully mounted disk $VOLUME_NAME."
          exit 0
        fi

        echo "Waiting for disk $VOLUME_NAME... (attempt $i/120) $(/bin/cat /tmp/mount-realme.err)"
        /bin/sleep 1
        i=$((i + 1))
      done

      echo "Failed to mount disk $VOLUME_NAME after 120 attempts."
      exit 1
    '';
  };
in
{
  # launchd cannot execute the generated script directly from /nix/store on
  # this host, so copy it to a stable system path during activation.
  system.activationScripts.extraActivation.text = lib.mkAfter ''
    set -eu

    /usr/bin/install -d -m 0755 /usr/local/sbin
    /usr/bin/install -m 0755 ${mountRealme} /usr/local/sbin/mount-realme

    # Remove the temporary fstab workaround; the daemon retries after login
    # instead of relying on diskarbitrationd's pre-console mount policy.
    FSTAB=/etc/fstab
    FSTAB_TMP="$FSTAB.nixdots"
    REALME_UUID="${realmeUuid}"
    if [ -f "$FSTAB" ]; then
      /usr/bin/awk -v uuid="$REALME_UUID" '$1 != "UUID=" uuid { print }' "$FSTAB" > "$FSTAB_TMP"
      /usr/bin/install -m 0644 "$FSTAB_TMP" "$FSTAB"
      /bin/rm -f "$FSTAB_TMP"
    fi
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
