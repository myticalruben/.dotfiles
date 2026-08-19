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

## Why the GUI apps are not managed here

This is Ubuntu, not NixOS. Anything that talks to the GPU - the compositor,
terminals, waybar, quickshell - would be built against nixpkgs' Mesa while the
kernel and drivers come from Ubuntu. It usually fails at startup with a GL or
EGL error.

[nixGL](https://github.com/nix-community/nixGL) wraps a program so it picks up
the host drivers. This machine is Intel/Mesa, which is the case nixGL handles
best; NVIDIA is where it gets painful.

The split here is deliberate: **Ubuntu keeps the compositor and the GUI apps,
Nix owns the configs and the CLI tools.** That is the combination that just
works. Moving the compositor into Nix is a separate project - and worth trying
on a spare machine before a laptop you use daily.

## What Nix would solve, if you did go further

Five of the six build-it-yourself dependencies in `../packages/manual.md`
already exist in nixpkgs, verified at the pinned revision:

| From manual.md | In nixpkgs |
|---|---|
| quickshell (source build) | `quickshell` 0.3.0 |
| awww / swww (source build) | `swww` — resolves to **awww 0.12.1**, your fork |
| hyprshot (drop in a script) | `hyprshot` 1.3.0 |
| neovim (upstream tarball) | `neovim` 0.12.4 |
| brave (own apt repo) | `brave` 1.93.136 |
| rofi Wayland fork (source build) | `rofi` **2.0.0** - 2.x has Wayland upstream, but it is a big jump from the 1.7.8 this repo's `.rasi` files were written for |

So the dependency problem from `packages/` mostly dissolves under Nix. The GPU
boundary above is what stops it being a clean win today.

## stateVersion

`home.stateVersion = "24.11"` in `home.nix` is **not** "the version I want".
It is the release whose defaults this config was written against, and changing
it later can silently alter behaviour. Leave it.

## Verification

Everything here was checked in a `nixos/nix` container, never on this machine:

- the flake resolves its inputs and the configuration evaluates to a
  derivation, deterministically before and after `flake.lock`
- controls confirm the evaluation is meaningful: a bogus option fails with
  ``The option `xdg.opcionQueNoExiste' does not exist``, and a bogus package
  name fails too
- all 11 CLI packages resolve to concrete versions at the locked revision

Not verified: an actual `home-manager switch`, which needs Nix installed on a
real machine.
