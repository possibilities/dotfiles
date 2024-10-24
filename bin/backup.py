#!/usr/bin/python3

import sys
import subprocess


def main():
    if len(sys.argv) != 3:
        print("Usage: {} <source_path> <destination_path>".format(sys.argv[0]))
        sys.exit(1)

    source_path = sys.argv[1]
    destination_path = sys.argv[2]

    mount_points = []
    if source_path.startswith("/media"):
        mount_points.append("/".join(source_path.split("/")[0:3]))
    if destination_path.startswith("/media"):
        mount_points.append("/".join(destination_path.split("/")[0:3]))

    lock_name = "_".join([source_path.strip("/"), destination_path.strip("/")]).replace(
        "/", "-"
    )

    rsync_options = "-av --delete"

    try:
        for mount_point in mount_points:
            subprocess.check_output(["mountpoint", "-q", mount_point])

        lockfile = f"/tmp/rclone.{lock_name}.lockfile"
        lock_command = [
            "/usr/bin/flock",
            "-n",
            lockfile,
            "rsync",
            *rsync_options.split(" "),
            source_path,
            destination_path,
        ]
        result = subprocess.run(lock_command)

        if result.returncode == 0:
            print(
                f"Backup from {source_path} to {destination_path} completed successfully."
            )
        else:
            print("Backup failed during rsync operation.")

    except subprocess.CalledProcessError:
        print(f"destination_path {destination_path} not mounted. Backup not performed.")

    # show the output of du -sch for the source and destination paths
    print("Source path size:")
    sys.stdout.flush()
    subprocess.run(["du", "-sch", source_path])
    print("Destination path size:")
    sys.stdout.flush()
    subprocess.run(["du", "-sch", destination_path])


if __name__ == "__main__":
    main()
