#!/usr/bin/env python3

import os
import subprocess
import getpass

device_mount_pairs = [
    ("/dev/disk/by-id/ata-SanDisk_SSD_G5_BICS4_20191T469207", "/media/briggs"),
    (
        "/dev/disk/by-id/nvme-Seagate_BarraCuda_Q5_ZP500CV30001_7TV01LA5",
        "/media/jacoby",
    ),
    (
        "/dev/disk/by-id/usb-Seagate_BUP_Slim_00000000NABDP3GV-0:0-part1",
        "/media/cooper",
    ),
    ("/dev/disk/by-id/usb-Seagate_BUP_Slim_00000000NAB55K1W-0:0", "/media/laura"),
    # "/dev/disk/by-id/usb-WD_My_Passport_2626_575833324433324B30455633-0:0-part1|/media/bob1"
    # "/dev/disk/by-id/usb-WD_My_Passport_2626_575833324433324B30455633-0:0-part2|/media/bob2"
    # "/dev/disk/by-id/usb-WD_My_Passport_2626_575833324433324B30455633-0:0-part3|/media/bob3"
]


def is_mounted(path):
    try:
        subprocess.run(["mountpoint", "-q", path], check=True)
        return True
    except subprocess.CalledProcessError:
        return False


def device_exists(path):
    return os.path.exists(path)


needs_mounting = any(
    not device_exists(device) or not is_mounted(mount_point)
    for device, mount_point in device_mount_pairs
)


def main():
    vc_password = getpass.getpass("Password: ") if needs_mounting else ""

    for device, mount_point in device_mount_pairs:
        if not device_exists(device):
            print(f"Device {mount_point} does not exist. Skipping...")
            continue
        if is_mounted(mount_point):
            print(f"{mount_point} is already mounted.")
        else:
            os.makedirs(mount_point, exist_ok=True)
            print(f"Mounting {mount_point}")
            try:
                subprocess.run(
                    [
                        "sudo",
                        "veracrypt",
                        "--text",
                        "--mount",
                        device,
                        mount_point,
                        "--pim",
                        "0",
                        "--keyfiles",
                        "",
                        "--protect-hidden",
                        "no",
                        "--stdin",
                        "--non-interactive",
                    ],
                    input=vc_password,
                    check=True,
                    text=True,
                    capture_output=True,
                )
            except subprocess.CalledProcessError as result:
                print(result.stderr)
                main()

    del vc_password


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("Exiting...")
