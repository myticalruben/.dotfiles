# Dependencies

Linking the configs is the easy half. The hard half is that these dotfiles
depend on ~30 programs, and the set of distros that package all of them is
empty. This directory is the honest map of that gap.

## Files

| File | What it is |
|---|---|
| `required-commands.txt` | Runtime deps as **commands**, not package names. The source of truth: `install.sh --check` reads it. |
| `ubuntu.txt` | apt names for Ubuntu 24.04. **Verified** against `apt-cache` on a working machine. |
| `ubuntu-ppa.txt` | PPAs `ubuntu.txt` depends on. |
| `debian.txt` | apt names for Debian trixie/sid. **Unverified.** |
| `arch.txt` | pacman names. **Unverified.** |
| `arch-aur.txt` | AUR names. **Unverified.** `install.sh` prints these rather than installing them. |
| `manual.md` | The ones no distro packages at all. |

"Unverified" means the names were derived, not checked on that distro. Run
`./install.sh --verify-names` on the target machine: it reports every name the
local package manager cannot resolve, changes nothing, and turns the guesswork
into a fixed list.

## Usage

```sh
./install.sh              # report what is missing, change nothing
./install.sh --verify-names   # check the package names resolve here
./install.sh --install    # add repos, install, then link the configs
```

`--install` is the only mode that touches the system, and it asks before
adding a PPA.

## Availability

The uncomfortable summary: **no distro gets you all the way**. Ubuntu needs a
PPA plus five manual builds; Arch covers the most but leans on the AUR.

| Dependency | Ubuntu 24.04 | Debian trixie | Arch |
|---|---|---|---|
| hyprland, hyprlock | PPA `cppiber` | repos | repos |
| waybar | PPA (0.14; archive has older) | repos | repos |
| wlogout, cliphist, dunst | universe | repos | AUR (wlogout) / repos |
| kitty, thunar, btop, grim, slurp, jq | universe | repos | repos |
| alacritty | PPA `aslatter` | repos | repos |
| rofi **(Wayland fork)** | build from source | build from source | `rofi-wayland` |
| quickshell | build from source | build from source | AUR |
| awww / swww | build from source | build from source | AUR (`swww`) |
| hyprshot | drop in the script | drop in the script | AUR |
| neovim (recent enough) | upstream tarball | repos | repos |
| brave | own apt repo | own apt repo | AUR |

Debian **stable** is not on this table on purpose: Hyprland is far too new for
it. Trixie or sid, or nothing.

See `manual.md` for what to do about each build-from-source entry.

## Adding a dependency

1. Add the command to `required-commands.txt` with what breaks without it.
2. Add the package name to each distro file that has one.
3. If no distro packages it, write it up in `manual.md` instead.
