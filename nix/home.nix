{ config, pkgs, lib, username, homeDirectory, ... }:

let
  # Where the checkout lives. Files are symlinked back out to it rather than
  # copied into the nix store, so editing ~/.config/hypr/... still edits the
  # repo, exactly as it did with setup.py. Change this if you clone elsewhere.
  dotfiles = "${homeDirectory}/.dotfiles";

  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;

  # Never change this after the first activation; it is not "the version you
  # want", it is the release whose defaults this config was written against.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # ------------------------------------------------------------- configs ---
  # Scope is ~/.config only, matching what setup.py already did.

  xdg.configFile = {
    "hypr".source = link "hypr";
    "waybar".source = link "waybar";
    "rofi".source = link "rofi";
    "dunst".source = link "dunst";
    "wlogout".source = link "wlogout";
    "quickshell".source = link "quickshell";
    "btop".source = link "btop";
    "nvim".source = link "nvim";
  };

  home.file.".local/bin/volume".source = link "scripts/volume";

  # ------------------------------------------------------------ packages ---
  # Only command-line tools here. See the note below before adding GUI apps.

  # hyprshot is deliberately absent: it depends on hyprland, which pulls in Qt 6
  # via hyprland-qtutils, so a 60 KB screenshot script costs 1.2 GiB of closure.
  # The distro package provides it instead - see ../packages/manual.md.
  home.packages = with pkgs; [
    # clipboard, screenshots, media, audio, power
    cliphist
    wl-clipboard
    grim
    slurp
    playerctl
    brightnessctl
    pulseaudio      # provides pactl, used by scripts/volume
    # misc tooling the configs shell out to
    jq
    imagemagick     # provides "magick"; cache.sh accepts either name
    btop
  ];

  # --- Why the GUI applications are not in that list -----------------------
  #
  # This is a non-NixOS machine, so anything that talks to the GPU (the
  # compositor, terminals, quickshell, waybar) would be built against the
  # nixpkgs Mesa while the running kernel and drivers come from Ubuntu. The
  # usual symptom is a GL/EGL failure at startup rather than a clean error.
  #
  # The fix is nixGL (github:nix-community/nixGL), which wraps a program so it
  # picks up the host's drivers. This machine is Intel/Mesa, which is the case
  # nixGL handles best - NVIDIA is where it gets painful.
  #
  # Deliberate split: keep the compositor and GUI apps coming from Ubuntu's
  # packages (packages/ubuntu.txt), and let Nix own the configs and the CLI
  # tools. That is the boring combination that works. Moving the compositor
  # itself into Nix is a separate project, and on a laptop you actually use
  # daily it is worth doing on a spare machine first.
}
