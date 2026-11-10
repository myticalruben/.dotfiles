# Graph Report - dotfiles  (2026-11-10)

## Corpus Check
- 33 files · ~14,679 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 16 file(s) not represented in the graph (top: (none) 5, .conf 2, .nix 2)

## Summary
- 200 nodes · 256 edges · 35 communities (15 shown, 20 thin omitted)
- Extraction: 85% EXTRACTED · 13% INFERRED · 2% AMBIGUOUS · INFERRED: 33 edges (avg confidence: 0.9)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3558370a`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Dependencias que ninguna distro te instala
- jobs
- utils.py
- check-config.py
- install.sh
- Atajos de teclado
- bootstrap.sh
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
- on

## God Nodes (most connected - your core abstractions)
1. `Nix + home-manager` - 11 edges
2. `Dependencias que ninguna distro te instala` - 9 edges
3. `dotfiles` - 8 edges
4. `Hyprland desde Nix, en una máquina de verdad` - 8 edges
5. `ubuntu.txt (Ubuntu 24.04 noble, verificado)` - 8 edges
6. `Atajos de teclado` - 7 edges
7. `fail()` - 7 edges
8. `main()` - 7 edges
9. `jobs` - 6 edges
10. `bootstrap.sh script` - 5 edges

## Surprising Connections (you probably didn't know these)
- `debian.txt (trixie/sid, nombres verificados, instalacion no probada)` --semantically_similar_to--> `ubuntu.txt (Ubuntu 24.04 noble, verificado)`  [INFERRED] [semantically similar]
  packages/debian.txt → packages/ubuntu.txt
- `arch-aur.txt (AUR, solo se imprime)` --conceptually_related_to--> `quickshell`  [INFERRED]
  packages/arch-aur.txt → packages/manual.md
- `arch-aur.txt (AUR, solo se imprime)` --conceptually_related_to--> `hyprshot`  [INFERRED]
  packages/arch-aur.txt → packages/manual.md
- `ubuntu.txt (Ubuntu 24.04 noble, verificado)` --references--> `neovim`  [EXTRACTED]
  packages/ubuntu.txt → packages/manual.md
- `arch-aur.txt (AUR, solo se imprime)` --conceptually_related_to--> `brave-browser`  [INFERRED]
  packages/arch-aur.txt → packages/manual.md

## Import Cycles
- None detected.

## Communities (35 total, 20 thin omitted)

### Community 0 - "Dependencias que ninguna distro te instala"
Cohesion: 0.23
Nodes (15): arch-aur.txt (AUR, solo se imprime), arch.txt (repos oficiales, sin verificar), debian.txt (trixie/sid, nombres verificados, instalacion no probada), Antes que nada: el `PATH` de la sesión, awww / awww-daemon, brave-browser, Dependencias que ninguna distro te instala, Fuentes (+7 more)

### Community 1 - "jobs"
Cohesion: 0.11
Nodes (24): jobs, lua, nix, python, referencias, shell, name, runs-on (+16 more)

### Community 2 - "utils.py"
Cohesion: 0.25
Nodes (7): ccf(), _link(), _link_target(), _remove(), _say(), summary(), Type

### Community 3 - "check-config.py"
Cohesion: 0.38
Nodes (11): check_referenced_scripts(), check_rofi_imports(), check_setup_sources(), check_shell_scripts(), check_waybar(), check_wlogout(), fail(), main() (+3 more)

### Community 4 - "install.sh"
Cohesion: 0.40
Nodes (10): as_root(), check_commands(), confirm(), do_install(), have(), have_any(), install_ubuntu_ppas(), read_list() (+2 more)

### Community 5 - "Atajos de teclado"
Cohesion: 0.12
Nodes (17): Ajustes por máquina, Aplicaciones, Atajos de teclado, Capturas de pantalla, Comprobaciones, Con Nix (versiones clavadas), Con paquetes de la distro, Dependencias (+9 more)

### Community 6 - "bootstrap.sh"
Cohesion: 0.67
Nodes (5): die(), install_git(), say(), bootstrap.sh script, warn()

### Community 8 - "Wlogout Lock Icon (lock.png)"
Cohesion: 0.60
Nodes (4): Wlogout Lock Icon (lock.png), Padlock Outline Glyph, Screen Lock Action (wlogout menu button), wlogout Power Menu

### Community 9 - "wlogout Logout Icon"
Cohesion: 0.70
Nodes (5): Action: End User Session (Log Out), Glyph: Rounded Door/Panel with Outward Arrow, wlogout Logout Icon, Style: White Thin-Stroke Line Art on Transparency, wlogout Power Menu Button Set

### Community 10 - "Reboot Icon (circular arrow glyph)"
Cohesion: 0.50
Nodes (5): Monochrome thin-stroke outline glyph style, Reboot Icon (circular arrow glyph), wlogout power menu icon set, wlogout reboot menu entry (systemctl reboot), #reboot button style rule

### Community 11 - "Suspend Icon (wlogout)"
Cohesion: 0.70
Nodes (4): Suspend Icon (wlogout), Pause Glyph (two vertical bars in circle), Suspend Power Action, wlogout Logout Menu

### Community 12 - "wlogout Shutdown Icon"
Cohesion: 0.67
Nodes (3): wlogout Shutdown Icon, wlogout Power Menu Shutdown Button, IEC Power Symbol Glyph (circle with vertical bar)

### Community 31 - "Hyprland desde Nix, en una máquina de verdad"
Cohesion: 0.12
Nodes (14): Coste, Dónde se registra la sesión, y por qué se detecta, GPU emulada, Hyprland desde Nix, en una máquina de verdad, La GPU manda más que la distro, Poner en marcha, Si no arranca, Si vienes de probarlo en VirtualBox (+6 more)

### Community 32 - "Nix + home-manager"
Cohesion: 0.15
Nodes (13): Comprobado, Cómo se reparten los paquetes, El `PATH` de la sesión, En otra máquina, `install.sh` dice que faltan quickshell, awww o awww-daemon, Las configs se siguen editando en su sitio, Nix + home-manager, Por qué el compositor sí está (+5 more)

### Community 34 - "on"
Cohesion: 0.40
Nodes (5): on, pull_request, push, workflow_dispatch, branches

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
- **4 isolated node(s):** `ubuntu-ppa.txt (PPAs cppiber y aslatter)`, `wlogout reboot menu entry (systemctl reboot)`, `#reboot button style rule`, `IEC Power Symbol Glyph (circle with vertical bar)`
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 86 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **20 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `dotfiles` connect `Atajos de teclado` to `Hyprland desde Nix, en una máquina de verdad`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `ubuntu.txt (Ubuntu 24.04 noble, verificado)` (e.g. with `debian.txt (trixie/sid, nombres verificados, instalacion no probada)` and `required-commands.txt (fuente de verdad de dependencias)`) actually correct?**
  _`ubuntu.txt (Ubuntu 24.04 noble, verificado)` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `ubuntu-ppa.txt (PPAs cppiber y aslatter)`, `wlogout reboot menu entry (systemctl reboot)`, `#reboot button style rule` to the rest of the system?**
  _4 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `jobs` be split into smaller, more focused modules?**
  _Cohesion score 0.10666666666666667 - nodes in this community are weakly interconnected._
- **Why does `Dependencias que ninguna distro te instala` connect `Dependencias que ninguna distro te instala` to `Hyprland desde Nix, en una máquina de verdad`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `Monochrome thin-stroke outline glyph style` and `wlogout power menu icon set`?**
  _Edge tagged AMBIGUOUS (relation: rationale_for) - confidence is low._
- **What is the exact relationship between `Suspend Power Action` and `Suspend Icon (wlogout)`?**
  _Edge tagged AMBIGUOUS (relation: semantically_similar_to) - confidence is low._