# ADR 0007 — Documentar cada proceso y decisión

**Estado:** aceptado (2026-11-16)

## Decisión

- Toda decisión de arquitectura, empaquetado, seguridad, marca o UX se registra
  en `docs/adr/` antes del cambio.
- Cada release incluye `CHANGELOG.md`, manifiesto de build y checksums.
- Los scripts destructivos documentan `--dry-run`, backup y `--rollback`.
- Los informes de análisis de subagentes se resumen en el plan, no se copian
  como verdad sin verificar.
- Las decisiones pendientes se marcan como `Propuesto`, no como hechos.

## Consecuencias

- Más documentación por cambio, pero menos decisiones invisibles.
- Un ADR aceptado se supersede, no se reescribe.
