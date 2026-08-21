{ config, pkgs, lib, username, homeDirectory
, # Where the config directories come from.
  #
  #   true  - symlinked back out to the checkout, so editing ~/.config/hypr
  #           still edits the repo. What a daily machine wants.
  #   false - copied into /nix/store, read-only. What a VM wants: it proves
  #           the session comes up from nothing but the flake, with no
  #           checkout in any particular place and nothing edited by hand.
  mutableConfigs
, # Whether Hyprland itself comes from Nix instead of the distro package.
  # Read the long note at the bottom of this file before turning it on for a
  # machine you need to log into tomorrow.
  compositorFromNix
, ...
}:

# Both flags are required rather than defaulted. A module argument with a
# default is resolved through `_module.args`, which needs `config`, and that
# is a cycle as soon as the flag decides an option that feeds home.file -
# which `xdg.dataFile` below does. The flake passes both, always.

let
  # Where the checkout lives, when mutableConfigs is on. Change this if you
  # clone elsewhere.
  dotfiles = "${homeDirectory}/.dotfiles";

  link = path:
    if mutableConfigs
    then config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}"
    else ../. + "/${path}";

  # Programs that open a window need the host's GPU drivers, not the Mesa that
  # nixpkgs built them against. nixGL injects the former at launch. This
  # machine and the desktop both use integrated graphics, which is the case
  # Mesa/nixGL handles cleanly.
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

  # ---------------------------------------------------------- compositor ---

  hyprlandWrapped = wrapGL pkgs.hyprland;

  # The display manager execs this directly, so it is the first thing that
  # runs in the session - and the only place that can fix the environment
  # before the compositor starts. modules/envs.lua cannot help here: it is
  # read by Hyprland, so it cannot be what makes Hyprland findable.
  hyprlandSession = pkgs.writeShellScriptBin "hyprland-session" ''
    export PATH="$HOME/.nix-profile/bin:$HOME/.local/bin:$PATH"

    hm_vars="$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    [ -r "$hm_vars" ] && . "$hm_vars"

    # Per-machine escape hatch, sourced before the compositor starts. It is
    # deliberately outside ~/.config/hypr: with mutableConfigs = false that
    # directory is a read-only store path, so nothing can be dropped into it.
    #
    # This is the only place some settings can go at all. A virtualised GPU
    # that needs LIBGL_ALWAYS_SOFTWARE has to have it set before Hyprland
    # picks a renderer, which is earlier than any config file it reads.
    session_env="''${XDG_CONFIG_HOME:-$HOME/.config}/hyprland-session.env"
    [ -r "$session_env" ] && . "$session_env"

    exec ${hyprlandWrapped}/bin/Hyprland "$@"
  '';

  # Exec points at the profile, not at a store path, so the entry keeps
  # working after every `home-manager switch` instead of pinning the
  # generation that happened to be current when it was installed.
  sessionDesktop = pkgs.writeText "hyprland-nix.desktop" ''
    [Desktop Entry]
    Name=Hyprland (Nix)
    Comment=Hyprland desde Nix, con el entorno de sesion ya preparado
    Exec=${homeDirectory}/.nix-profile/bin/hyprland-session
    Type=Application
    DesktopNames=Hyprland
  '';

  # The one step home-manager cannot take: the greeter reads its session list
  # as root, long before this user exists to it.
  #
  # Which directory it reads is not the same everywhere, and guessing wrong
  # means the entry simply never appears - no error, just a session that is
  # not offered. So it is detected rather than assumed. See the case below.
  installSession = pkgs.writeShellScriptBin "install-hyprland-session" ''
    set -eu

    dry_run=0
    forced_dir=""

    for arg in "$@"; do
      case "$arg" in
        --dry-run) dry_run=1 ;;
        --dir=*)   forced_dir="''${arg#*=}" ;;
        -h|--help)
          echo "Uso: install-hyprland-session [--dry-run] [--dir=RUTA]"
          echo
          echo "Registra la sesion \"Hyprland (Nix)\" donde el gestor de acceso"
          echo "de esta maquina la vaya a leer. Sin argumentos lo detecta solo."
          echo
          echo "  --dry-run   dice que haria, sin escribir y sin necesitar root"
          echo "  --dir=RUTA  salta la deteccion y usa RUTA"
          exit 0 ;;
        *) echo "opcion desconocida: $arg" >&2; exit 2 ;;
      esac
    done

    # SDDM: SessionDir, en /etc/sddm.conf o en /etc/sddm.conf.d/*.conf.
    sddm_dir() {
      d="$(cat /etc/sddm.conf /etc/sddm.conf.d/*.conf 2>/dev/null \
           | grep -E '^[[:space:]]*SessionDir[[:space:]]*=' \
           | tail -n1 | cut -d= -f2- | tr -d '[:space:]')" || true
      d="''${d%%,*}"
      printf '%s' "''${d:-/usr/share/wayland-sessions}"
    }

    # LightDM: sessions-directory, que es una lista separada por ':'.
    lightdm_dir() {
      d="$(cat /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.d/*.conf 2>/dev/null \
           | grep -E '^[[:space:]]*sessions-directory[[:space:]]*=' \
           | tail -n1 | cut -d= -f2- | tr -d '[:space:]')" || true
      case "$d" in
        *wayland-sessions*)
          printf '%s' "$d" | tr ':' '\n' | grep wayland-sessions | head -n1 ;;
        *)
          printf '%s' /usr/share/wayland-sessions ;;
      esac
    }

    # Cual manda de verdad. systemd mantiene display-manager.service como
    # alias del que este activado, y esa es la unica respuesta que vale igual
    # en Ubuntu, Mint y Arch.
    dm=""
    if command -v systemctl >/dev/null 2>&1; then
      dm="$(systemctl show display-manager.service -p Id --value 2>/dev/null)" || true
    fi
    if [ -z "$dm" ] && [ -r /etc/X11/default-display-manager ]; then
      dm="$(basename "$(cat /etc/X11/default-display-manager)")"
    fi
    dm="$(printf '%s' "$dm" | sed 's/\.service$//')"

    # GDM es un programa GLib: pega "wayland-sessions" a los directorios de
    # datos del sistema, y esos incluyen /usr/local/share. Ahi es donde debe
    # ir, fuera del territorio de la distro.
    #
    # SDDM y LightDM no funcionan asi. Cada uno lee una lista explicita de su
    # propia configuracion, y ninguna incluye /usr/local/share por defecto,
    # de modo que ahi el archivo tiene que ir a /usr/share/wayland-sessions.
    # El nombre hyprland-nix.desktop es solo nuestro, asi que no pisa nada de
    # lo que traiga la distro.
    case "$dm" in
      gdm|gdm3)
        dir=/usr/local/share/wayland-sessions
        why="GDM lee XDG_DATA_DIRS, que incluye /usr/local/share" ;;
      sddm)
        dir="$(sddm_dir)"
        why="SDDM usa el SessionDir de su configuracion" ;;
      lightdm)
        dir="$(lightdm_dir)"
        why="LightDM usa el sessions-directory de su configuracion" ;;
      "")
        dir=/usr/local/share/wayland-sessions
        why="no se detecto gestor de acceso" ;;
      *)
        dir=/usr/share/wayland-sessions
        why="gestor no reconocido ($dm): se usa la ruta estandar" ;;
    esac

    if [ -n "$forced_dir" ]; then
      dir="$forced_dir"
      why="forzado con --dir"
    fi

    target="$dir/hyprland-nix.desktop"

    echo "Gestor de acceso : ''${dm:-ninguno detectado}"
    echo "Directorio       : $dir"
    echo "Motivo           : $why"
    echo "Archivo          : $target"

    if [ "$dry_run" -eq 1 ]; then
      echo
      echo "(--dry-run: no se ha escrito nada)"
      exit 0
    fi

    if [ "$(id -u)" -ne 0 ]; then
      echo >&2
      echo "Hace falta root para escribir en $dir:" >&2
      echo "  sudo install-hyprland-session" >&2
      exit 1
    fi

    mkdir -p "$dir"
    cp ${sessionDesktop} "$target"
    chmod 0644 "$target"

    echo
    echo "Instalado. Apunta a ${homeDirectory}/.nix-profile/bin/hyprland-session"
    if [ -z "$dm" ]; then
      echo
      echo "Sin gestor de acceso detectado. Arranca desde una TTY con:"
      echo "  hyprland-session"
    else
      echo "Reinicia $dm (o la maquina) para que lo lea."
    fi
  '';
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

      # waybar, rofi y hyprlock piden "JetBrainsMono Nerd Font". El paquete de
      # Debian/Ubuntu (fonts-jetbrains-mono) es la fuente sin parchear: le
      # faltan los glifos de iconos que usan los tres, así que no sirve.
      nerd-fonts.jetbrains-mono
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
    ]))
    ++
    # --- the compositor, only when asked for ---
    lib.optionals compositorFromNix [
      hyprlandWrapped
      hyprlandSession
      installSession
    ];

  # Written for the display managers that honour XDG_DATA_DIRS. GDM does not -
  # it reads its list as root, before this directory is any of its business -
  # so `sudo install-hyprland-session` stays the step that matters.
  xdg.dataFile = lib.mkIf compositorFromNix {
    "wayland-sessions/hyprland-nix.desktop".source = sessionDesktop;
  };

  # --- Why the compositor is opt-in ---------------------------------------
  #
  # `compositorFromNix` defaults to false, and that default is the whole
  # point. The risk is not that Hyprland is hard to package - nixpkgs has it,
  # the same 0.56.2 - it is the failure mode. A terminal that will not start
  # is an annoyance you fix from another terminal. A compositor that will not
  # start leaves you with no session to fix it from.
  #
  # So the distro package stays installed and its session entry stays in
  # /usr/share/wayland-sessions. This one installs alongside it, in
  # /usr/local/share, under a different name ("Hyprland (Nix)"). Both show up
  # in the greeter, and a Nix session that will not come up costs you one
  # logout instead of your machine.
  #
  # Turning it on takes two steps, not one:
  #
  #   home-manager switch --flake .#ruben   # installs it
  #   sudo install-hyprland-session         # makes the greeter offer it
  #
  # The second needs root and therefore cannot be part of activation. It only
  # has to run once: the entry points at ~/.nix-profile/bin, which follows
  # your generations, not at the store path current on the day you ran it.
}
