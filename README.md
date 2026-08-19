# dotfiles

Hyprland desktop configuration: Hyprland (Lua config), waybar, rofi, dunst,
wlogout, quickshell, btop, kitty and neovim.

## Install

```sh
git clone git@github.com:myticalruben/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh                # report what is missing, change nothing
./install.sh --install      # install dependencies, then link the configs
```

`install.sh` detects Ubuntu, Debian and Arch. Only `--install` touches the
system, and it asks before adding a third-party repository.

To link the configs without installing anything:

```sh
python3 setup.py            # safe to re-run; never deletes
python3 setup.py --force    # also repoint symlinks aiming elsewhere
```

`setup.py` symlinks each directory into `~/.config` (and `scripts/volume` into
`~/.local/bin`). It refuses to touch real files and directories, so a machine
with existing configs is never silently overwritten.

## Per-machine settings

Everything in this repo is portable: no absolute paths, no hardcoded monitor
names. Anything tied to one machine goes in one place:

```sh
cp hypr/modules/local.lua.example hypr/modules/local.lua
```

`local.lua` is gitignored and loaded last, so it overrides the shared
defaults. Use it for connector names, resolutions, scale and the wallpaper.
Without it, the config still works: `modules/monitors.lua` applies a catch-all
rule to every output.

## Two ways to install

| | |
|---|---|
| `install.sh` + `setup.py` | Distro packages, symlinked configs. What most machines here use. |
| Nix + home-manager | Pinned versions via `flake.lock` — see [`nix/`](nix/README.md). |

They are alternatives, not layers: both want to own `~/.config`, so pick one.

## Dependencies

See [`packages/`](packages/README.md). Short version: no distro packages
everything. Ubuntu needs a PPA plus a handful of source builds, Arch leans on
the AUR, and Debian stable is too old for Hyprland entirely.
[`packages/manual.md`](packages/manual.md) covers what has to be built by hand.

## Layout

| Path | |
|---|---|
| `hypr/` | Hyprland, in Lua, split into `modules/` |
| `waybar/`, `rofi/`, `dunst/`, `wlogout/` | bar, launcher, notifications, power menu |
| `quickshell/hyprquickpaper/` | SUPER+W wallpaper picker |
| `nvim/`, `btop/` | editor and system monitor |
| `scripts/`, `hypr/scripts/` | helper scripts |
| `packages/` | dependency manifests per distro |
