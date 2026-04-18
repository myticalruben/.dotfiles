import os
import subprocess
from enum import Enum
from pathlib import Path

config_dir = Path("~/.config").expanduser().as_posix()
local_bin_dir = Path("~/.local/bin").expanduser().as_posix()

dotfiles_dir = os.getcwd()


class Type(Enum):
    FOLDER = 1
    FILE = 2
    BIN = 3


def cpfold(name: str):
    if not os.path.exists(config_dir + f"/{name}"):
        print(f"{name.upper()} folder not exists")
        print(f"Coping {name.upper()} config folder from Dotfiles")
        subprocess.run(["ln", "-s", dotfiles_dir + f"/{name}", config_dir])
        print(f"{name.upper()} folder sucessfuly copy")
    else:
        print(f"{name.upper()} config exists")
        print("Remove them to copying this config")


def cpfile(name: str):
    if not os.path.exists(config_dir + f"/{name}"):
        print(f"{name} file not exists")
        print(f"Coping {name} config file from Dotfiles")
        subprocess.run(["ln", "-s", dotfiles_dir + f"/{name}", config_dir])
        print(f"{name} folder sucessfuly copy")
    else:
        print(f"{name} config exists")
        print("Remove them to copying this config")

def cpfilebin(name: str):
    if not os.path.exists(config_dir + f"/{name}"):
        print(f"{name} file not exists")
        print(f"Coping {name} bin file from Dotfiles")
        subprocess.run(["ln", "-s", dotfiles_dir + f"/{name}", local_bin_dir])
        print(f"{name} folder sucessfuly copy")
    else:
        print(f"{name} bin exists")
        print("Remove them to copying this bin")


def ccf(name: str, type: Type):
    if type == Type.FOLDER:
        cpfold(name)
    elif type == Type.FILE:
        cpfile(name)
    elif type == Type.BIN:
        cpfilebin(name)
