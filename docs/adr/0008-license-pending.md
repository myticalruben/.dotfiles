# ADR 0008 — Licencia raíz pendiente

**Estado:** propuesto (2026-11-17)

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

Pendiente de aprobación del owner. Hasta entonces:

- no se publica una ISO;
- no se elimina la obligación de incluir `LICENSE` y `THIRD_PARTY_NOTICES`;
- los assets propios se identifican como CC0 en `distro/branding/LICENSES.md`.

## Consecuencias

La V1.0 puede probarse localmente, pero la distribución pública queda bloqueada
hasta que se acepte una de las opciones 1 o 2.
