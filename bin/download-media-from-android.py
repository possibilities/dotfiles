#!/usr/bin/env python3

import subprocess
import os

android_root = "/sdcard"
local_root = "/media/cooper/android"


def download_all_files(device_path, local_root):
    # Use adb shell ls to list files and directories
    command = ["adb", "shell", "ls", "-1", device_path]
    result = subprocess.run(command, capture_output=True, text=True)

    # Check if the command was successful
    if result.returncode != 0:
        print(f"Failed to list directory: {device_path}")
        return []

    # Split the output into lines
    entries = result.stdout.splitlines()

    valid_extensions = {
        ".jpg",
        ".jpeg",
        ".png",
        ".gif",
        ".bmp",
        ".mp4",
        ".mov",
        ".avi",
        ".mkv",
    }

    for entry in entries:
        # Quote the entry to handle spaces
        full_path = f"{device_path}/{entry}"
        quoted_full_path = f"'{full_path}'"

        check_command = ["adb", "shell", "stat", "-c", "%F", quoted_full_path]
        check_result = subprocess.run(
            check_command, shell=True, capture_output=True, text=True
        )

        if check_result.returncode != 0:
            print(f"Failed to check entry: {full_path}")
            continue

        entry_type = check_result.stdout.strip()

        if entry_type == "directory":
            if full_path != "/sdcard/Android":
                download_all_files(full_path, local_root)
        elif entry_type == "regular file":
            if any(entry.lower().endswith(ext) for ext in valid_extensions):
                relative_path = os.path.relpath(full_path, "/sdcard")
                local_path = os.path.join(local_root, relative_path)

                if os.path.exists(local_path):
                    print(f"File already exists: {local_path[len(local_root):]}")
                    delete_command = ["adb", "shell", "rm", quoted_full_path]
                    delete_result = subprocess.run(
                        delete_command, shell=True, capture_output=True, text=True
                    )
                    if delete_result.returncode != 0:
                        print(f"Failed to delete file: {full_path}")
                    continue

                os.makedirs(os.path.dirname(local_path), exist_ok=True)

                print(f"Downloading: {local_path[len(local_root):]}")
                pull_command = f"adb pull {quoted_full_path} '{local_path}'"
                pull_result = subprocess.run(
                    pull_command, shell=True, capture_output=True, text=True
                )

                if pull_result.returncode != 0:
                    print(f"Failed to download file: {full_path}")
                else:
                    delete_command = ["adb", "shell", "rm", quoted_full_path]
                    delete_result = subprocess.run(
                        delete_command, shell=True, capture_output=True, text=True
                    )
                    if delete_result.returncode != 0:
                        print(f"Failed to delete file: {full_path}")


def main():
    adb_devices_command = "adb devices"
    result = subprocess.run(
        adb_devices_command, shell=True, capture_output=True, text=True
    )

    if result.stdout.strip().split("\n")[1:]:
        download_all_files(android_root, local_root)
    else:
        print("No devices found")


if __name__ == "__main__":
    main()
