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
  # Everything the configs invoke, from Nix. Split in two because a non-NixOS
  # host makes one half harder than the other.

  home.packages =
    let
      # Programs that open a window need the host's GPU drivers, not the Mesa
      # that nixpkgs built them against. nixGL injects the former at launch.
      # This machine and the desktop both use integrated graphics, which is
      # the case Mesa/nixGL handles cleanly.
      nixGL = lib.getExe pkgs.nixgl.nixGLIntel;

      wrapGL = pkg: pkgs.runCommand "${pkg.name}-nixgl" { } ''
        mkdir -p $out/bin
        # Keep everything except bin/ as-is: .desktop files, icons, shares.
        for d in ${pkg}/*; do
          [ "$(basename "$d")" = bin ] || ln -s "$d" "$out/$(basename "$d")"
        done
        for bin in ${pkg}/bin/*; do
          out_bin="$out/bin/$(basename "$bin")"
          printf '#!/bin/sh\nexec %s "%s" "$@"\n' ${nixGL} "$bin" > "$out_bin"
          chmod +x "$out_bin"
        done
      '';
    in
    # --- no GPU involved: safe as-is ---
    (with pkgs; [
      cliphist
      wl-clipboard
      grim
      slurp
      playerctl
      brightnessctl
      pulseaudio        # pactl, used by scripts/volume
      wireplumber       # wpctl, used by the volume keybinds
      jq
      imagemagick
      btop
      neovim
      awww              # the fork the config calls; nixpkgs renamed swww to this
    ])
    ++
    # --- opens windows: wrapped so it finds the host drivers ---
    (map wrapGL (with pkgs; [
      waybar
      rofi
      kitty
      alacritty
      dunst
      wlogout
      quickshell
      pavucontrol
      networkmanagerapplet   # nm-applet
      brave
    ]));

  # --- The compositor is deliberately NOT here ---------------------------
  #
  # Hyprland itself still comes from Ubuntu. Not because it is missing from
  # nixpkgs - it is there, same 0.56.2 - but because of the failure mode: a
  # compositor that will not start leaves you with no session to fix it from,
  # while a terminal that will not start is an annoyance you fix from another
  # terminal.
  #
  # It also has to be found by the login manager, which reads session files
  # from /usr/share/wayland-sessions. That is outside home-manager's scope
  # and outside the ~/.config scope of this repo.
  #
  # If you do want it from Nix: add `hyprland` to the wrapped list above, then
  # write a session file pointing at the wrapped binary, and keep the Ubuntu
  # package installed so you always have a session that boots.
}
