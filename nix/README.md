# Nix + home-manager

An alternative to `setup.py` that manages the same `~/.config` files, but with
pinned versions: `flake.lock` records exact revisions of nixpkgs and
home-manager, so another machine gets *the same* tools, not "whatever the
distro ships today".

**Pick one.** Do not run `setup.py` and home-manager at the same time - both
want to own `~/.config/hypr` and home-manager refuses to clobber a symlink it
did not create. Remove the `setup.py` links first (they are only symlinks;
deleting them touches nothing in the repo).

## Setup

Nix is not installed by this repo: it needs root, creates `/nix`, and adds a
daemon. Install it yourself first - the Determinate installer is the usual
choice, and unlike the upstream one it enables flakes by default:

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Then, from the repo:

```sh
nix run home-manager/master -- switch --flake .#ruben-alexander
```

After the first activation, `home-manager switch --flake .#ruben-alexander` is
enough. `nix develop` gives you a shell with home-manager on PATH without
installing it into your profile.

## On another machine

Change `username` and `homeDirectory` in `flake.nix`, or add a second
`homeConfigurations` entry and select it by name. `dotfiles` in `home.nix`
assumes the checkout is at `~/.dotfiles`.

## The configs stay editable

`home.nix` links with `mkOutOfStoreSymlink`, not the default copy-into-the-
store. So `~/.config/hypr/hyprland.lua` still points back into this repo and
editing it still edits the checkout - the same workflow `setup.py` gave you.

The usual home-manager behaviour would copy the files into `/nix/store` as
read-only, and every edit would mean `home-manager switch`. That is more
rigorous and much more annoying for a config you tune daily.

## How the packages are split

Everything the configs invoke now comes from Nix, in two groups.

**No GPU involved** — installed as-is: `cliphist`, `wl-clipboard`, `grim`,
`slurp`, `playerctl`, `brightnessctl`, `pulseaudio` (pactl), `wireplumber`
(wpctl), `jq`, `imagemagick`, `btop`, `neovim`, `awww`.

**Opens windows** — wrapped with [nixGL](https://github.com/nix-community/nixGL):
`waybar`, `rofi`, `kitty`, `alacritty`, `dunst`, `wlogout`, `quickshell`,
`pavucontrol`, `networkmanagerapplet`, `brave`.

The wrapping matters because this is not NixOS. Those programs were built
against nixpkgs' Mesa, while the kernel and drivers come from Ubuntu; without
nixGL they typically die at startup with a GL or EGL error. `wrapGL` in
`home.nix` replaces each binary with a shim that execs it through
`nixGLIntel`, and symlinks everything else (`.desktop` files, icons, shares)
through untouched.

Both machines here use integrated graphics, which is the case Mesa and nixGL
handle cleanly. NVIDIA is where this gets painful, and would need
`nixGLNvidia` and a driver version that matches the host exactly.

## Why the compositor is not in that list

Hyprland itself still comes from Ubuntu, and this is deliberate. It is not
missing from nixpkgs - it is there, the same 0.56.2 - the reason is the
failure mode. A terminal that will not start is an annoyance you fix from
another terminal. A compositor that will not start leaves you with no session
to fix it from.

It also has to be found by the login manager, which reads session files from
`/usr/share/wayland-sessions`. That is outside both home-manager's reach and
this repo's `~/.config` scope.

To move it anyway: add `hyprland` to the wrapped list, write a session file
pointing at the wrapped binary, and **keep the Ubuntu package installed** so
there is always a session that boots.

## On the desktop machine

Ubuntu with integrated graphics, so the same split applies unchanged. Clone to
`~/.dotfiles`, adjust `username` and `homeDirectory` in `flake.nix` if the
account differs, and activate. Hyprland itself still comes from
`packages/ubuntu.txt` (the `cppiber` PPA).

## stateVersion

`home.stateVersion = "24.11"` in `home.nix` is **not** "the version I want".
It is the release whose defaults this config was written against, and changing
it later can silently alter behaviour. Leave it.

## Verification

Evaluated in a `nixos/nix` container and then activated for real on the Ubuntu
machine:

- the flake resolves its inputs and evaluates to the same derivation path in
  the container and on the host - deterministic across machines
- controls confirm the evaluation is meaningful: a bogus option fails with
  ``The option `xdg.opcionQueNoExiste' does not exist``, and a bogus package
  name fails too
- all 11 CLI packages resolve to concrete versions at the locked revision
- `activate` ran and the generation is live. The six configs setup.py already
  owned were reported "skipped since they are the same", confirming the two
  approaches produce identical link targets
- the out-of-store design holds: `~/.config/hypr` resolves through the store
  back to `~/.dotfiles/hypr`, `hyprland.lua` has the **same inode** as the
  file in the checkout, and it is writable. Editing through `~/.config` still
  edits the repo
- `hyprland --verify-config` still passes after activation

### A wrinkle worth knowing

`hyprshot` depends on `hyprland`, which pulls `hyprland-qtutils` and with it
Qt 6 - so a 60 KB screenshot script drags in the compositor. It has been
dropped from `home.packages`; the distro package at `/usr/local/bin` provides
it instead.

Measured, not estimated:

| | Closure |
|---|---|
| with `hyprshot` | 1.6 GiB |
| without | **1005 MiB** |

So it cost about 640 MiB in practice, less than the 1.2 GiB its own closure
suggests, because `imagemagick`, `cliphist` and GTK share much of the rest.
