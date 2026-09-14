# Graph Report - .dotfiles  (2026-09-04)

## Corpus Check
- 32 files · ~18,235 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 167 nodes · 213 edges · 33 communities (28 shown, 5 thin omitted)
- Extraction: 82% EXTRACTED · 16% INFERRED · 2% AMBIGUOUS · INFERRED: 34 edges (avg confidence: 0.9)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `9efac393`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Dependencias que ninguna distro te instala
- CI workflow "check"
- utils.py
- check-config.py
- install.sh
- Atajos de teclado
- bootstrap.sh
- volume
- Wlogout Lock Icon (lock.png)
- wlogout Logout Icon
- Reboot Icon (circular arrow glyph)
- Suspend Icon (wlogout)
- wlogout Shutdown Icon
- now-playing.sh
- opacity.sh
- cache.sh
- commands.sh
- battery.sh
- Hyprland desde Nix, en una máquina de verdad
- Nix + home-manager

## God Nodes (most connected - your core abstractions)
1. `Nix + home-manager` - 10 edges
2. `Dependencias que ninguna distro te instala` - 10 edges
3. `Hyprland desde Nix, en una máquina de verdad` - 8 edges
4. `ubuntu.txt (Ubuntu 24.04 noble, verificado)` - 8 edges
5. `fail()` - 7 edges
6. `main()` - 7 edges
7. `dotfiles` - 7 edges
8. `Atajos de teclado` - 7 edges
9. `CI workflow "check"` - 6 edges
10. `install_ubuntu_ppas()` - 5 edges

## Surprising Connections (you probably didn't know these)
- `Fallo silencioso de los dotfiles` --semantically_similar_to--> `Comprobaciones`  [INFERRED] [semantically similar]
  .github/workflows/check.yml → README.md
- `debian.txt (trixie/sid, nombres verificados, instalacion no probada)` --semantically_similar_to--> `ubuntu.txt (Ubuntu 24.04 noble, verificado)`  [INFERRED] [semantically similar]
  packages/debian.txt → packages/ubuntu.txt
- `arch-aur.txt (AUR, solo se imprime)` --conceptually_related_to--> `quickshell`  [INFERRED]
  packages/arch-aur.txt → packages/manual.md
- `arch-aur.txt (AUR, solo se imprime)` --conceptually_related_to--> `hyprshot`  [INFERRED]
  packages/arch-aur.txt → packages/manual.md
- `ubuntu.txt (Ubuntu 24.04 noble, verificado)` --references--> `neovim`  [EXTRACTED]
  packages/ubuntu.txt → packages/manual.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Comprobaciones de CI contra los fallos silenciosos** — _github_workflows_check_silent_failure_rationale, _github_workflows_check_referencias, _github_workflows_check_shell, _github_workflows_check_lua, _github_workflows_check_python, _github_workflows_check_nix, readme_comprobaciones [EXTRACTED 1.00]

## Communities (33 total, 5 thin omitted)

### Community 0 - "Dependencias que ninguna distro te instala"
Cohesion: 0.21
Nodes (16): arch-aur.txt (AUR, solo se imprime), arch.txt (repos oficiales, sin verificar), debian.txt (trixie/sid, nombres verificados, instalacion no probada), Antes que nada: el `PATH` de la sesión, awww / awww-daemon, brave-browser, Dependencias que ninguna distro te instala, Fuentes (+8 more)

### Community 1 - "CI workflow "check""
Cohesion: 0.25
Nodes (8): job luacheck (hypr/), job nix flake check, job python (compileall), job referencias (tools/check-config.py), job shellcheck, Fallo silencioso de los dotfiles, CI workflow "check", Comprobaciones

### Community 2 - "utils.py"
Cohesion: 0.31
Nodes (11): Enum, Path, ccf(), _link(), _link_target(), Helpers to link this repo's configs into the places apps expect them. Every…, Where a symlink points, made absolute. os.readlink can return a relative path,…, _remove() (+3 more)

### Community 3 - "check-config.py"
Cohesion: 0.38
Nodes (12): check_referenced_scripts(), check_rofi_imports(), check_setup_sources(), check_shell_scripts(), check_waybar(), check_wlogout(), fail(), main() (+4 more)

### Community 4 - "install.sh"
Cohesion: 0.40
Nodes (10): as_root(), check_commands(), confirm(), do_install(), have(), have_any(), install_ubuntu_ppas(), read_list() (+2 more)

### Community 5 - "Atajos de teclado"
Cohesion: 0.13
Nodes (15): Ajustes por máquina, Aplicaciones, Atajos de teclado, Capturas de pantalla, Con Nix (versiones clavadas), Con paquetes de la distro, Dependencias, dotfiles (+7 more)

### Community 6 - "bootstrap.sh"
Cohesion: 0.67
Nodes (5): die(), install_git(), say(), bootstrap.sh script, warn()

### Community 7 - "volume"
Cohesion: 0.67
Nodes (5): volume script, current_volume(), have(), is_muted(), set_relative()

### Community 8 - "Wlogout Lock Icon (lock.png)"
Cohesion: 0.60
Nodes (5): Wlogout Lock Icon (lock.png), Monochrome Line-Art Icon Set Style, Padlock Outline Glyph, Screen Lock Action (wlogout menu button), wlogout Power Menu

### Community 9 - "wlogout Logout Icon"
Cohesion: 0.70
Nodes (5): Action: End User Session (Log Out), Glyph: Rounded Door/Panel with Outward Arrow, wlogout Logout Icon, Style: White Thin-Stroke Line Art on Transparency, wlogout Power Menu Button Set

### Community 10 - "Reboot Icon (circular arrow glyph)"
Cohesion: 0.50
Nodes (5): Monochrome thin-stroke outline glyph style, Reboot Icon (circular arrow glyph), wlogout power menu icon set, wlogout reboot menu entry (systemctl reboot), #reboot button style rule

### Community 11 - "Suspend Icon (wlogout)"
Cohesion: 0.70
Nodes (5): Suspend Icon (wlogout), Monochrome Line-Art Icon Style, Pause Glyph (two vertical bars in circle), Suspend Power Action, wlogout Logout Menu

### Community 12 - "wlogout Shutdown Icon"
Cohesion: 0.67
Nodes (4): wlogout Shutdown Icon, Monochrome Thin-Outline Transparent-Background Icon Style, wlogout Power Menu Shutdown Button, IEC Power Symbol Glyph (circle with vertical bar)

### Community 31 - "Hyprland desde Nix, en una máquina de verdad"
Cohesion: 0.13
Nodes (13): Coste, Dónde se registra la sesión, y por qué se detecta, Hyprland desde Nix, en una máquina de verdad, La GPU manda más que la distro, Las dos variantes, Poner en marcha, Si no arranca, Si vienes de probarlo en VirtualBox (+5 more)

### Community 32 - "Nix + home-manager"
Cohesion: 0.17
Nodes (12): Comprobado, Cómo se reparten los paquetes, El `PATH` de la sesión, En otra máquina, `install.sh` dice que faltan quickshell, awww o awww-daemon, Las configs se siguen editando en su sitio, Nix + home-manager, Por qué el compositor no está en esa lista (+4 more)

## Ambiguous Edges - Review These
- `Monochrome thin-stroke outline glyph style` → `wlogout power menu icon set`  [AMBIGUOUS]
  wlogout/icons/reboot.png · relation: rationale_for
- `Suspend Power Action` → `Suspend Icon (wlogout)`  [AMBIGUOUS]
  wlogout/icons/suspend.png · relation: semantically_similar_to
- `wlogout Power Menu Shutdown Button` → `Monochrome Thin-Outline Transparent-Background Icon Style`  [AMBIGUOUS]
  wlogout/icons/shutdown.png · relation: rationale_for
- `Screen Lock Action (wlogout menu button)` → `Wlogout Lock Icon (lock.png)`  [AMBIGUOUS]
  wlogout/icons/lock.png · relation: shares_data_with
- `Action: End User Session (Log Out)` → `wlogout Logout Icon`  [AMBIGUOUS]
  wlogout/icons/logout.png · relation: semantically_similar_to

## Knowledge Gaps
- **49 isolated node(s):** `now-playing.sh script`, `opacity.sh script`, `cache.sh script`, `commands.sh script`, `battery.sh script` (+44 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `Monochrome thin-stroke outline glyph style` and `wlogout power menu icon set`?**
  _Edge tagged AMBIGUOUS (relation: rationale_for) - confidence is low._
- **What is the exact relationship between `Suspend Power Action` and `Suspend Icon (wlogout)`?**
  _Edge tagged AMBIGUOUS (relation: semantically_similar_to) - confidence is low._
- **What is the exact relationship between `wlogout Power Menu Shutdown Button` and `Monochrome Thin-Outline Transparent-Background Icon Style`?**
  _Edge tagged AMBIGUOUS (relation: rationale_for) - confidence is low._
- **What is the exact relationship between `Screen Lock Action (wlogout menu button)` and `Wlogout Lock Icon (lock.png)`?**
  _Edge tagged AMBIGUOUS (relation: shares_data_with) - confidence is low._
- **What is the exact relationship between `Action: End User Session (Log Out)` and `wlogout Logout Icon`?**
  _Edge tagged AMBIGUOUS (relation: semantically_similar_to) - confidence is low._
- **Why does `dotfiles` connect `Atajos de teclado` to `CI workflow "check"`, `Hyprland desde Nix, en una máquina de verdad`?**
  _High betweenness centrality (0.087) - this node is a cross-community bridge._
- **Why does `Dependencias que ninguna distro te instala` connect `Dependencias que ninguna distro te instala` to `Hyprland desde Nix, en una máquina de verdad`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._