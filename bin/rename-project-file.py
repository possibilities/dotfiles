#!/usr/bin/python3

import os
import sys
import re


def replace_function_name(old_name, new_name):
    project_dir = os.getcwd()
    old_file_path = None

    for root, dirs, files in os.walk(project_dir):
        if f"{old_name}.py" in files:
            old_file_path = os.path.join(root, f"{old_name}.py")
            break

    if old_file_path is None:
        print(f"File {old_name}.py not found.")
        sys.exit(1)

    with open(old_file_path, "r") as file:
        content = file.read()

    if f"def {old_name}(" not in content:
        print(f"Function {old_name} not found in {old_name}.py.")
        sys.exit(1)

    for root, dirs, files in os.walk(project_dir):
        for file in files:
            file_path = os.path.join(root, file)
            if file_path.endswith(".py"):
                with open(file_path, "r") as f:
                    file_content = f.read()
                file_content = re.sub(f"\\b{old_name}\\b", new_name, file_content)
                with open(file_path, "w") as f:
                    f.write(file_content)

    new_file_path = os.path.join(os.path.dirname(old_file_path), f"{new_name}.py")
    print(old_file_path, new_file_path)
    return
    os.rename(old_file_path, new_file_path)
    print(f"Renamed {old_name}.py to {new_name}.py")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python rename-project-file old_name new_name")
        sys.exit(1)
    old_name = sys.argv[1]
    new_name = sys.argv[2]
    replace_function_name(old_name, new_name)
