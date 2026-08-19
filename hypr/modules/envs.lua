-- The login manager launches Hyprland without sourcing any shell profile, so
-- the session PATH is the bare system one: ~/.nix-profile/bin (home-manager)
-- and ~/.local/bin are missing from it. Every exec-once and keybind that calls
-- a program installed there silently does nothing - awww, quickshell, hyprshot
-- and the volume script have no copy in /usr/bin to fall back on.
--
-- Computed from the PATH Hyprland actually started with, so it stays portable:
-- on a machine installed with install.sh those directories simply do not exist
-- and prepending them changes nothing. The guard matters because the variable
-- is set on the compositor itself and survives `hyprctl reload`, which parses
-- this file again: without it every reload stacks another copy.
local home = os.getenv("HOME")
local extra = home .. "/.nix-profile/bin:" .. home .. "/.local/bin"
local path = os.getenv("PATH") or ""

if not path:find(extra, 1, true) then
    hl.env("PATH", extra .. ":" .. path)
end

hl.env("XCURSOR_SIZE", "14")
hl.env("HYPRCURSOR_SIZE", "14")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
