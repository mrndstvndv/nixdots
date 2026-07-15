{ pkgs, ... }:

{
  launchd.daemons.mount-realme = {
    script = ''
      # Wait for the realme disk to be recognized and mount it
      VOLUME_NAME="realme"
      i=1
      while [ $i -le 30 ]; do
        # Check if it's already mounted
        if /usr/sbin/diskutil info "$VOLUME_NAME" 2>/dev/null | /usr/bin/grep -q "Mounted: *Yes"; then
          echo "Disk $VOLUME_NAME is already mounted."
          exit 0
        fi

        # Try to mount it
        if /usr/sbin/diskutil mount "$VOLUME_NAME" 2>/dev/null; then
          echo "Successfully mounted disk $VOLUME_NAME."
          exit 0
        fi

        echo "Waiting for disk $VOLUME_NAME... (attempt $i/30)"
        /bin/sleep 1
        i=$((i + 1))
      done

      echo "Failed to mount disk $VOLUME_NAME after 30 attempts."
      exit 1
    '';
    serviceConfig = {
      Label = "org.nixos.mount-realme";
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/var/log/mount-realme.log";
      StandardErrorPath = "/var/log/mount-realme.err.log";
    };
  };
}
