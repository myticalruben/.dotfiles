# Graph Report - .dotfiles  (2026-08-28)

## Corpus Check
- Corpus is ~18,235 words - fits in a single context window. You may not need a graph.

## Summary
- 150 nodes · 238 edges · 31 communities (26 shown, 5 thin omitted)
- Extraction: 76% EXTRACTED · 21% INFERRED · 3% AMBIGUOUS · INFERRED: 50 edges (avg confidence: 0.9)
- Token cost: 263,949 input · 0 output

## Community Hubs (Navigation)
- Dependencias por Distro y PATH de Sesion
- Nix vs Distro: Estrategia de Instalacion
- setup.py: Enlazado de Configs
- check-config.py: Validacion de Referencias
- install.sh: Instalador por Distro
- CI y Comprobaciones de Fallo Silencioso
- bootstrap.sh: Arranque Minimo
- Script de Volumen
- Icono de Bloqueo de Pantalla
- Icono de Cerrar Sesion
- Icono de Reinicio
- Icono de Suspension
- Icono de Apagado
- Modulo Waybar: Reproduccion
- Script de Opacidad
- Script de Cache
- Script de Comandos
- Modulo Waybar: Bateria

## God Nodes (most connected - your core abstractions)
1. `Mapa de dependencias por distro` - 12 edges
2. `ubuntu.txt (Ubuntu 24.04 noble, verificado)` - 11 edges
3. `bootstrap.sh (Hyprland desde Nix en hardware real)` - 9 edges
4. `dotfiles (README principal)` - 8 edges
5. `Nix + home-manager como alternativa a setup.py` - 8 edges
6. `required-commands.txt (fuente de verdad de dependencias)` - 8 edges
7. `El PATH de la sesion (manual.md)` - 8 edges
8. `fail()` - 7 edges
9. `main()` - 7 edges
10. `CI workflow "check"` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Deteccion del directorio de wayland-sessions` --semantically_similar_to--> `Fallo silencioso de los dotfiles`  [INFERRED] [semantically similar]
  nix/setup/README.md → .github/workflows/check.yml
- `Fuentes: JetBrainsMono Nerd Font` --semantically_similar_to--> `Fallo silencioso de los dotfiles`  [INFERRED] [semantically similar]
  packages/manual.md → .github/workflows/check.yml
- `Deteccion del directorio de wayland-sessions` --semantically_similar_to--> `Lo que se detecta solo (monitores, bateria, navegador, ImageMagick, PATH)`  [INFERRED] [semantically similar]
  nix/setup/README.md → README.md
- `El PATH de la sesion (manual.md)` --semantically_similar_to--> `Sintoma: sesion a medio arrancar`  [INFERRED] [semantically similar]
  packages/manual.md → nix/README.md
- `hyprshot` --semantically_similar_to--> `Tamano del closure (4.4 / 4.7 GiB) y exclusion de hyprshot`  [INFERRED] [semantically similar]
  packages/manual.md → nix/README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Comprobaciones de CI contra los fallos silenciosos** — _github_workflows_check_silent_failure_rationale, _github_workflows_check_referencias, _github_workflows_check_shell, _github_workflows_check_lua, _github_workflows_check_python, _github_workflows_check_nix, readme_comprobaciones [EXTRACTED 1.00]
- **Modo de fallo del PATH de la sesion y lo que depende de el** — nix_readme_session_path, packages_manual_path_sesion, nix_readme_sesion_a_medio_arrancar, packages_manual_rofi, packages_manual_quickshell, packages_manual_awww, packages_manual_hyprshot, nix_readme_tamano_closure [EXTRACTED 1.00]
- **Manifiestos de dependencias por distro** — packages_required_commands_manifest, packages_ubuntu_manifest, packages_ubuntu_ppa_manifest, packages_debian_manifest, packages_arch_manifest, packages_arch_aur_manifest, packages_manual_path_sesion, packages_readme_dependencias [EXTRACTED 1.00]

## Communities (31 total, 5 thin omitted)

### Community 0 - "Dependencias por Distro y PATH de Sesion"
Cohesion: 0.15
Nodes (29): Sintoma: sesion a medio arrancar, El PATH de la sesion (envs.lua antepone ~/.nix-profile/bin), install.sh dice que faltan quickshell, awww o awww-daemon, ~/.config/hyprland-session.env como punto de extension, arch-aur.txt (AUR, solo se imprime), arch.txt (repos oficiales, sin verificar), debian.txt (trixie/sid, nombres verificados, instalacion no probada), awww / awww-daemon (fork de swww) (+21 more)

### Community 1 - "Nix vs Distro: Estrategia de Instalacion"
Cohesion: 0.22
Nodes (14): Por que Hyprland viene de la distro por defecto, Interruptor compositorFromNix, Nix + home-manager como alternativa a setup.py, mkOutOfStoreSymlink: las configs se editan en su sitio, wrapGL / nixGLIntel para los programas con ventana, home.stateVersion = 24.11, bootstrap.sh (Hyprland desde Nix en hardware real), Deteccion del directorio de wayland-sessions (+6 more)

### Community 2 - "setup.py: Enlazado de Configs"
Cohesion: 0.31
Nodes (11): Enum, Path, ccf(), _link(), _link_target(), Helpers to link this repo's configs into the places apps expect them. Every…, Where a symlink points, made absolute. os.readlink can return a relative path,…, _remove() (+3 more)

### Community 3 - "check-config.py: Validacion de Referencias"
Cohesion: 0.38
Nodes (12): check_referenced_scripts(), check_rofi_imports(), check_setup_sources(), check_shell_scripts(), check_waybar(), check_wlogout(), fail(), main() (+4 more)

### Community 4 - "install.sh: Instalador por Distro"
Cohesion: 0.40
Nodes (10): as_root(), check_commands(), confirm(), do_install(), have(), have_any(), install_ubuntu_ppas(), read_list() (+2 more)

### Community 5 - "CI y Comprobaciones de Fallo Silencioso"
Cohesion: 0.28
Nodes (9): job luacheck (hypr/), job nix flake check, job python (compileall), job referencias (tools/check-config.py), job shellcheck, Fallo silencioso de los dotfiles, CI workflow "check", Tamano del closure (4.4 / 4.7 GiB) y exclusion de hyprshot (+1 more)

### Community 6 - "bootstrap.sh: Arranque Minimo"
Cohesion: 0.67
Nodes (5): die(), install_git(), say(), bootstrap.sh script, warn()

### Community 7 - "Script de Volumen"
Cohesion: 0.67
Nodes (5): volume script, current_volume(), have(), is_muted(), set_relative()

### Community 8 - "Icono de Bloqueo de Pantalla"
Cohesion: 0.60
Nodes (5): Wlogout Lock Icon (lock.png), Monochrome Line-Art Icon Set Style, Padlock Outline Glyph, Screen Lock Action (wlogout menu button), wlogout Power Menu

### Community 9 - "Icono de Cerrar Sesion"
Cohesion: 0.70
Nodes (5): Action: End User Session (Log Out), Glyph: Rounded Door/Panel with Outward Arrow, wlogout Logout Icon, Style: White Thin-Stroke Line Art on Transparency, wlogout Power Menu Button Set

### Community 10 - "Icono de Reinicio"
Cohesion: 0.50
Nodes (5): Monochrome thin-stroke outline glyph style, Reboot Icon (circular arrow glyph), wlogout power menu icon set, wlogout reboot menu entry (systemctl reboot), #reboot button style rule

### Community 11 - "Icono de Suspension"
Cohesion: 0.70
Nodes (5): Suspend Icon (wlogout), Monochrome Line-Art Icon Style, Pause Glyph (two vertical bars in circle), Suspend Power Action, wlogout Logout Menu

### Community 12 - "Icono de Apagado"
Cohesion: 0.67
Nodes (4): wlogout Shutdown Icon, Monochrome Thin-Outline Transparent-Background Icon Style, wlogout Power Menu Shutdown Button, IEC Power Symbol Glyph (circle with vertical bar)

## Ambiguous Edges - Review These
- `job shellcheck` → `Tamano del closure (4.4 / 4.7 GiB) y exclusion de hyprshot`  [AMBIGUOUS]
  .github/workflows/check.yml · relation: conceptually_related_to
- `Lo que se detecta solo (monitores, bateria, navegador, ImageMagick, PATH)` → `pomobar (modulo custom de waybar)`  [AMBIGUOUS]
  packages/manual.md · relation: conceptually_related_to
- `Wlogout Lock Icon (lock.png)` → `Screen Lock Action (wlogout menu button)`  [AMBIGUOUS]
  wlogout/icons/lock.png · relation: shares_data_with
- `wlogout Logout Icon` → `Action: End User Session (Log Out)`  [AMBIGUOUS]
  wlogout/icons/logout.png · relation: semantically_similar_to
- `Monochrome thin-stroke outline glyph style` → `wlogout power menu icon set`  [AMBIGUOUS]
  wlogout/icons/reboot.png · relation: rationale_for
- `wlogout Power Menu Shutdown Button` → `Monochrome Thin-Outline Transparent-Background Icon Style`  [AMBIGUOUS]
  wlogout/icons/shutdown.png · relation: rationale_for
- `Suspend Icon (wlogout)` → `Suspend Power Action`  [AMBIGUOUS]
  wlogout/icons/suspend.png · relation: semantically_similar_to

## Knowledge Gaps
- **13 isolated node(s):** `now-playing.sh script`, `opacity.sh script`, `cache.sh script`, `commands.sh script`, `battery.sh script` (+8 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `job shellcheck` and `Tamano del closure (4.4 / 4.7 GiB) y exclusion de hyprshot`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Lo que se detecta solo (monitores, bateria, navegador, ImageMagick, PATH)` and `pomobar (modulo custom de waybar)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Wlogout Lock Icon (lock.png)` and `Screen Lock Action (wlogout menu button)`?**
  _Edge tagged AMBIGUOUS (relation: shares_data_with) - confidence is low._
- **What is the exact relationship between `wlogout Logout Icon` and `Action: End User Session (Log Out)`?**
  _Edge tagged AMBIGUOUS (relation: semantically_similar_to) - confidence is low._
- **What is the exact relationship between `Monochrome thin-stroke outline glyph style` and `wlogout power menu icon set`?**
  _Edge tagged AMBIGUOUS (relation: rationale_for) - confidence is low._
- **What is the exact relationship between `wlogout Power Menu Shutdown Button` and `Monochrome Thin-Outline Transparent-Background Icon Style`?**
  _Edge tagged AMBIGUOUS (relation: rationale_for) - confidence is low._
- **What is the exact relationship between `Suspend Icon (wlogout)` and `Suspend Power Action`?**
  _Edge tagged AMBIGUOUS (relation: semantically_similar_to) - confidence is low._