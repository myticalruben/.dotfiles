# ADR 0004 — Nix estable 26.05

**Estado:** aceptado (2026-11-16)

## Contexto

`flake.nix` usa `nixos-unstable` y Home Manager `master`. Es cómodo para
desarrollo, pero una distro necesita una base estable, reproducible y con
ventana de soporte.

## Decisión

- `nixpkgs` se fija a `nixos-26.05`.
- Home Manager se fija a `release-26.05`.
- `flake.lock` registra ambos commits.
- La Preview puede usar una rama de desarrollo solo con un flag explícito.
- Las actualizaciones de escritorio se prueban antes de publicarse.

## Consecuencias

- Hay que actualizar inputs y reconstruir el perfil.
- Los paquetes nuevos pueden no estar en 26.05; se evalúan caso por caso.
- Nix deja de ser una fuente de sorpresas semanales.
