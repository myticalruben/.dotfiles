"""Helpers to link this repo's configs into the places apps expect them.

Every path is derived at runtime from $HOME / the XDG variables and from the
location of this file, so the same checkout works on any machine and from any
working directory.
"""

import os
import sys
from enum import Enum
from pathlib import Path

# Resolved from this file, not from os.getcwd(): running "python3 setup.py"
# from another directory used to create symlinks pointing at nothing.
dotfiles_dir = Path(__file__).resolve().parent

config_dir = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
local_bin_dir = Path.home() / ".local" / "bin"

# --force only ever replaces an existing symlink. Real files and directories are
# never touched, so a mistake here cannot destroy anything that is not a link.
force = "--force" in sys.argv

_results = {"linked": 0, "ok": 0, "skipped": 0}


class Type(Enum):
    FOLDER = 1
    FILE = 2
    BIN = 3


def _link(source: Path, target: Path) -> None:
    name = target.name

    if not source.exists():
        print(f"  !! {name}: missing in the repo ({source}), skipped")
        _results["skipped"] += 1
        return

    target.parent.mkdir(parents=True, exist_ok=True)

    if target.is_symlink():
        current = Path(os.readlink(target))
        if current == source:
            print(f"  == {name}: already linked")
            _results["ok"] += 1
            return
        if not force:
            print(f"  !! {name}: symlink points at {current}")
            print("     re-run with --force to repoint it")
            _results["skipped"] += 1
            return
        target.unlink()
        print(f"  ~~ {name}: replacing link to {current}")
    elif target.exists():
        kind = "directory" if target.is_dir() else "file"
        print(f"  !! {name}: a real {kind} is already there, left untouched")
        print(f"     move or delete {target} and re-run")
        _results["skipped"] += 1
        return

    target.symlink_to(source)
    print(f"  -> {name}: linked")
    _results["linked"] += 1


def ccf(name: str, type: Type) -> None:
    source = dotfiles_dir / name
    if type is Type.BIN:
        # Link name is the basename, so ccf("scripts/volume") lands on
        # ~/.local/bin/volume rather than ~/.local/bin/scripts/volume.
        _link(source, local_bin_dir / source.name)
    else:
        _link(source, config_dir / name)


def summary() -> int:
    print()
    print(f"linked: {_results['linked']}   already ok: {_results['ok']}   "
          f"skipped: {_results['skipped']}")
    if _results["skipped"]:
        print("Some entries were skipped; nothing was deleted.")
        return 1
    return 0
