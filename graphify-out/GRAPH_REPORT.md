# Graph Report - dotfiles  (2026-11-10)

## Corpus Check
- Corpus is ~17,689 words - fits in a single context window. You may not need a graph.

## Summary
- 273 nodes · 391 edges · 29 communities (14 shown, 15 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 57 edges (avg confidence: 0.84)
- Token cost: 27,980 input · 11,790 output

## Community Hubs (Navigation)
- Nix Config & Activation
- CI Validation Pipeline
- Session PATH & nixGL
- Setup Script Internals
- Config Validation Tools
- Bootstrap Installer
- Distro Installer
- Lock Icon Design
- Waybar Palette Extraction
- Reboot Icon Design
- Shutdown Icon Design
- GTK Theme Generator
- Suspend Icon Design
- Logout Icon Design
- Waybar Theme Script
- GTK Theme Script
- Now Playing Script
- Opacity Script
- Neovim External Flake
- Quickshell Cache Script
- Quickshell Commands
- Battery Script
- Network Script

## God Nodes (most connected - your core abstractions)
1. `home-manager Configuration` - 9 edges
2. `Shutdown Icon (wlogout)` - 9 edges
3. `main()` - 8 edges
4. `main()` - 7 edges
5. `fail()` - 7 edges
6. `main()` - 7 edges
7. `jobs` - 6 edges
8. `check_waybar()` - 6 edges
9. `_link_target()` - 6 edges
10. `envs.lua PATH Fix` - 6 edges

## Surprising Connections (you probably didn't know these)
- `Session PATH Gap` --semantically_similar_to--> `Session PATH Gap (Manual)`  [INFERRED] [semantically similar]
  nix/README.md → packages/manual.md
- `rofi Wayland Fork` --references--> `envs.lua PATH Fix`  [EXTRACTED]
  packages/manual.md → nix/README.md
- `Side-by-Side Nix Session` --conceptually_related_to--> `Two Exclusive Installation Paths`  [INFERRED]
  nix/setup/README.md → README.md
- `home-manager Configuration` --conceptually_related_to--> `setup.py Symlink Linker`  [EXTRACTED]
  nix/README.md → README.md
- `rofi Wayland Fork` --conceptually_related_to--> `Keyboard Shortcuts`  [INFERRED]
  packages/manual.md → README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Per-Distro Dependency Manifest Set** — packages_required_commands_txt_format, packages_ubuntu_txt_manifest, packages_ubuntu_ppa_txt_manifest, packages_debian_txt_manifest, packages_arch_txt_manifest, packages_arch_aur_txt_manifest [EXTRACTED 0.95]
- **Session PATH Diagnosis and Fix Chain** — nix_readme_session_path_gap, nix_readme_envs_lua, nix_readme_path_guard, nix_readme_path_verification, packages_manual_path_gap [EXTRACTED 0.90]
- **nixGL-Wrapped GUI Stack** — nix_readme_nixgl, nix_readme_wrapgl, nix_readme_nvidia_caveat, nix_setup_readme_gpu_emulation, packages_manual_quickshell, packages_manual_rofi_wayland [EXTRACTED 0.85]
- **Padlock Anatomy (Shackle + Body)** — wlogout_icons_lock_padlock_glyph, wlogout_icons_lock_shackle, wlogout_icons_lock_lock_body [EXTRACTED 1.00]
- **wlogout Icon Asset Conventions** — wlogout_icons_lock_lock_icon, wlogout_icons_lock_filled_white_silhouette, wlogout_icons_lock_transparent_background, wlogout_icons_lock_square_canvas_padding, wlogout_icons_lock_rounded_corner_geometry [INFERRED 0.85]
- **Lock Action Tile Flow** — wlogout_icons_lock_lock_icon, wlogout_icons_lock_screen_lock_action, wlogout_icons_lock_wlogout_power_menu [INFERRED 0.85]
- **Logout Icon Composition (Door + Exit Arrow)** — wlogout_icons_logout, wlogout_icons_logout_door_frame, wlogout_icons_logout_exit_arrow, wlogout_icons_logout_line_icon_style [EXTRACTED 1.00]
- **Circular-Arrow Anatomy** — wlogout_icons_reboot_circular_arrow, wlogout_icons_reboot_tapered_stroke, wlogout_icons_reboot_arrowhead, wlogout_icons_reboot_white_fill_outline [INFERRED 0.85]
- **Reboot Icon Semantics** — wlogout_icons_reboot_icon, wlogout_icons_reboot_restart_concept, wlogout_icons_reboot_cycle_metaphor, wlogout_icons_reboot_circular_arrow [INFERRED 0.85]
- **Power Glyph Composition (Ring Arc + Vertical Bar + Top Gap)** — wlogout_icons_shutdown_power_glyph, wlogout_icons_shutdown_ring_arc, wlogout_icons_shutdown_vertical_bar, wlogout_icons_shutdown_top_gap [EXTRACTED 1.00]
- **wlogout Shutdown Affordance (Icon + Action + Theme)** — wlogout_icons_shutdown_shutdown_icon, wlogout_icons_shutdown_wlogout_button, wlogout_icons_shutdown_themeable_icon_set, wlogout_icons_shutdown_transparent_background [INFERRED 0.75]
- **Composition of the Suspend Icon** — wlogout_icons_suspend, wlogout_icons_suspend_pause_glyph, wlogout_icons_suspend_circle_ring, wlogout_icons_suspend_transparent_canvas [EXTRACTED 1.00]
- **Theme-Adaptive Icon Rendering** — wlogout_icons_suspend_monochrome_stroke_style, wlogout_icons_suspend_transparent_canvas, wlogout_icons_suspend_theme_recolor [INFERRED 0.75]
- **Pause Semantics Reuse** — wlogout_icons_suspend_pause_glyph, wlogout_icons_suspend_media_pause_convention, wlogout_icons_suspend_suspend_action [INFERRED 0.75]

## Communities (29 total, 15 thin omitted)

### Community 0 - "Nix Config & Activation"
Cohesion: 0.07
Nodes (34): ~/.config Ownership Conflict, flake.lock Pinned Revisions, home-manager Configuration, hyprland-session Launcher, Impure Activation (--impure), mkOutOfStoreSymlink, home.stateVersion 24.11, Side-by-Side Nix Session (+26 more)

### Community 1 - "CI Validation Pipeline"
Cohesion: 0.09
Nodes (29): jobs, lua, nix, python, referencias, shell, name, runs-on (+21 more)

### Community 2 - "Session PATH & nixGL"
Cohesion: 0.11
Nodes (18): Closure Size 3.8 GiB, envs.lua PATH Fix, nixGL Wrapping, NVIDIA Driver Caveat, Idempotent PATH Guard, Child Process PATH Verification, Session PATH Gap, wrapGL Shim (+10 more)

### Community 3 - "Setup Script Internals"
Cohesion: 0.22
Nodes (7): ccf(), _link(), _link_target(), _remove(), _say(), summary(), Type

### Community 4 - "Config Validation Tools"
Cohesion: 0.32
Nodes (11): check_referenced_scripts(), check_rofi_imports(), check_setup_sources(), check_shell_scripts(), check_waybar(), check_wlogout(), fail(), main() (+3 more)

### Community 6 - "Bootstrap Installer"
Cohesion: 0.24
Nodes (11): Determinate Nix Installer, Experimental flakes Feature, install-hyprland-session, die(), install_git(), say(), bootstrap.sh script, warn() (+3 more)

### Community 8 - "Distro Installer"
Cohesion: 0.40
Nodes (10): as_root(), check_commands(), confirm(), do_install(), have(), have_any(), install_ubuntu_ppas(), read_list() (+2 more)

### Community 9 - "Lock Icon Design"
Cohesion: 0.27
Nodes (6): Rounded Lock Body, Lock Icon (lock.png), Padlock Glyph, Screen Lock Action, U-Shaped Shackle, wlogout Power Menu

### Community 10 - "Waybar Palette Extraction"
Cohesion: 0.38
Nodes (7): hexc(), hls(), hue_distance(), main(), mix(), rgb(), rgba()

### Community 11 - "Reboot Icon Design"
Cohesion: 0.29
Nodes (10): Outlined Arrowhead at Lower Left, Circular Arrow Glyph, Cyclic Renewal Metaphor, Reboot Icon, Power-Action Icon Family, Restart / Reboot Action, Tapered Brush-Style Band, 512x512 Transparent Canvas (+2 more)

### Community 12 - "Shutdown Icon Design"
Cohesion: 0.36
Nodes (8): Power Glyph (IEC 5009 Power Symbol), Interrupted Circular Arc Ring, Shutdown Icon (wlogout), 512x512 Square Canvas, Themeable wlogout Icon Set, Top Opening / Arc Gap, Vertical Center Bar, wlogout Shutdown Button Action

### Community 13 - "GTK Theme Generator"
Cohesion: 0.39
Nodes (7): hexc(), main(), rgba(), mix(), parse_palette(), render(), rgb()

### Community 14 - "Suspend Icon Design"
Cohesion: 0.36
Nodes (8): wlogout Suspend Icon, Enclosing Circular Ring, Media-Player Pause Convention, Pause Glyph (Two Vertical Bars), wlogout Power-Menu Icon Family, System Suspend Action, Theme-Neutral Recolorable Rendering, Transparent Square Canvas

### Community 17 - "Logout Icon Design"
Cohesion: 0.67
Nodes (6): Logout Icon (logout.png), Rounded Door Frame Outline, Rightward Exit Arrow, Monochrome Outline Icon Style, Log Out Action, Transparent Background Asset

## Knowledge Gaps
- **25 isolated node(s):** `wlogout Session Menu`, `CI Workflow Checks`, `graphify-out Knowledge Graph`, `Experimental flakes Feature`, `Idempotent PATH Guard` (+20 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 83 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `home-manager Configuration` connect `Nix Config & Activation` to `Session PATH & nixGL`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `Shutdown Icon (wlogout)` (e.g. with `wlogout Shutdown Button Action` and `Stroke-Only Line Art Style`) actually correct?**
  _`Shutdown Icon (wlogout)` has 4 INFERRED edges - model-reasoned connections that need verification._
- **What connects `wlogout Session Menu`, `CI Workflow Checks`, `graphify-out Knowledge Graph` to the rest of the system?**
  _25 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Nix Config & Activation` be split into smaller, more focused modules?**
  _Cohesion score 0.06756756756756757 - nodes in this community are weakly interconnected._
- **Why does `Nix Installation Path` connect `Nix Config & Activation` to `Bootstrap Installer`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **Should `CI Validation Pipeline` be split into smaller, more focused modules?**
  _Cohesion score 0.08505747126436781 - nodes in this community are weakly interconnected._
- **Should `Session PATH & nixGL` be split into smaller, more focused modules?**
  _Cohesion score 0.11428571428571428 - nodes in this community are weakly interconnected._