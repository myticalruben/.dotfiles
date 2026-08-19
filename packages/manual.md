# Dependencies no distro packages for you

These are the reason "the same dotfiles on any machine" is not purely a
symlink problem. Each one has to be installed by hand, or from a third-party
source, on at least one of the target distros.

The state below was read off a working Ubuntu 24.04 install — where each
binary actually lives and whether a package owns it — so it reflects what was
really done here, not what the docs suggest.

## rofi (Wayland fork)

Ubuntu's `rofi` is X11-only and will not work under Hyprland. What is running
here is `rofi 1.7.8+wayland1` in `/usr/local/bin`, built from source; no apt
package owns it.

**Both are installed on this machine**, and the working one wins only because
`/usr/local/bin` comes before `/usr/bin` in `PATH`:

| Path | Version | Source |
|---|---|---|
| `/usr/local/bin/rofi` | 1.7.8+wayland1 | built from source, works |
| `/usr/bin/rofi` | 1.7.5 | apt package `rofi`, X11-only |

If anything ever reorders `PATH`, the launcher silently becomes the X11 build
and stops working under Hyprland. Removing the apt package (`sudo apt remove
rofi`) makes that impossible. `ubuntu.txt` deliberately does **not** list
`rofi` for this reason - installing it would only recreate the shadowing.

- Arch: `rofi-wayland` is in the official repos, nothing to do.
- Ubuntu/Debian: build from <https://github.com/lbonn/rofi>.

## quickshell

The SUPER+W wallpaper picker. Built from source into `/usr/local/bin` here
(the checkout is in `~/Downloads/quickshell`, which is itself a reproducibility
problem — it should live somewhere deliberate).

- Arch: `quickshell-git` in the AUR.
- Ubuntu/Debian: build from <https://git.outfoxxed.me/outfoxxed/quickshell>.

## awww / awww-daemon

A fork of `swww`, used to set the wallpaper. The binaries sit in `/usr/bin` but
**no dpkg package owns them** — they were copied in by hand, which means an
apt upgrade will never touch them and a fresh machine will not have them.

- Arch: `swww` is in the AUR; the `awww` fork is not packaged anywhere.
- Everywhere else: build from source, or switch the config to plain `swww`.

## hyprshot

A single bash script, in `/usr/local/bin` here.

- Arch: `hyprshot` in the AUR.
- Ubuntu/Debian: drop the script from
  <https://github.com/Gustash/Hyprshot> onto your PATH.

## neovim

The config in this repo is LazyVim, which needs a recent Neovim. Ubuntu 24.04
ships 0.9.x; what is installed here is **0.11.6** in `~/.local/bin`.

- Arch: `neovim` in the repos is current.
- Ubuntu/Debian: use the upstream AppImage or tarball, not the distro package.

## brave-browser

Ships its own apt repository and its own signing key — see
<https://brave.com/linux/>. On Arch it is `brave-bin` in the AUR.

Note the binary name differs by distro: the apt package installs
`brave-browser`, the AUR package installs `brave`. `modules/keysbindings.lua`
picks whichever exists rather than assuming one.

## pomobar

Your own project, referenced by the waybar `custom/pomobar` module at
`$HOME/Documents/pomobar/`. Nothing installs it, and the module is not
currently in `modules-right`, so the bar works without it.

## Fonts

The configs ask for three families:

| Font | Referenced by | Installed here |
|---|---|---|
| FantasqueSansMono Nerd Font | waybar | yes |
| Iosevka | rofi | **no** |
| CaskaydiaCove Nerd Font | waybar, hyprlock | **no** |

Two of the three are missing on this machine already, so those configs are
silently falling back to a default font. Either install them from
<https://github.com/ryanoasis/nerd-fonts> into `~/.local/share/fonts` (then
`fc-cache -f`), or change the configs to a font you actually have.
