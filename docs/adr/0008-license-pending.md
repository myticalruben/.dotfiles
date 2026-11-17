# ADR 0008 — Licencia raíz pendiente

**Estado:** aceptado (2026-11-17) — GPL-3.0-or-later

## Contexto

El código propio, los scripts de empaquetado y los assets generados no tienen
una licencia raíz declarada. El tema SDDM es GPL-3.0-or-later y Audiowide es
OFL; la combinación se puede distribuir, pero hace falta una decisión explícita
para el código de Mytical.

## Opciones

1. **GPL-3.0-or-later** para el código propio: compatible con el tema SDDM y
   con la obligación de compartir fuente.
2. **MIT** para scripts propios + GPL/OFL para assets: más simple, pero hay que
   separar los avisos por directorio.
3. **CC0** solo para assets generados, dejando el código sin licencia: **no
   publicable**; no se acepta como opción de release.

## Decisión

El código propio se distribuye bajo **GPL-3.0-or-later**. Los assets de terceros
mantienen sus licencias: el tema SDDM sigue en GPL-3.0-or-later, Audiowide en
OFL-1.1 y los assets generados por el proyecto se dedican a CC0-1.0.

## Consecuencias

- `LICENSE` y `COPYRIGHT` están en la raíz.
- `THIRD_PARTY_NOTICES` y `distro/branding/LICENSES.md` conservan la autoría.
- La licencia ya no bloquea la publicación; quedan la clave APT de producción y
  la verificación final de assets.
