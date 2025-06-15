#!/usr/bin/python3

# a python script that works on debian linux that copies the current timestamp to the clipboard. If it is run again and the current clipboard has one or more lines of text with timestamps on it the new timestamp is added to the list and it is added to the clipboard.

# When copying use xclip with subcommand rather than any external library

# For example the first time it is pressed the clipboard might contain

# ```
# 1000000000.01
# ```

# After pressing it a second time it might contain:

# ```
# 1000000000.01
# 2000000000.02
# ```


def main():
    import subprocess
    import time
    import re

    # Get the current timestamp
    timestamp = time.time()
    timestamp_str = f"{timestamp:.2f}"

    # Get the current clipboard
    clipboard = subprocess.run(
        ["xclip", "-o", "-selection", "clipboard"], stdout=subprocess.PIPE
    )
    clipboard_str = clipboard.stdout.decode("utf-8")

    # If the clipboard is empty, set it to the timestamp
    if clipboard_str == "":
        subprocess.run(
            ["xclip", "-selection", "clipboard"], input=timestamp_str.encode("utf-8")
        )
        return

    # If the clipboard contains a timestamp, add the new timestamp to the end
    if re.match(r"\d+\.\d+", clipboard_str):
        new_clipboard_str = f"{clipboard_str}, {timestamp_str}"
        subprocess.run(
            ["xclip", "-selection", "clipboard"],
            input=new_clipboard_str.encode("utf-8"),
        )
        return

    # If the clipboard contains multiple timestamps, add the new timestamp to the end
    if re.match(r"(\d+\.\d+\n)+\d+\.\d+", clipboard_str):
        new_clipboard_str = f"{clipboard_str}{timestamp_str}"
        subprocess.run(
            ["xclip", "-selection", "clipboard"],
            input=new_clipboard_str.encode("utf-8"),
        )
        return

    # If the clipboard contains something else, set it to the timestamp
    subprocess.run(
        ["xclip", "-selection", "clipboard"], input=timestamp_str.encode("utf-8")
    )

    subprocess.run(["notify-send", "-t", "12000", "Timestamp copied to clipboard"])


if __name__ == "__main__":
    main()
