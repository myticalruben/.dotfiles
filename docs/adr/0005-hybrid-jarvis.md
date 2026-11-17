# ADR 0005 — Jarvis híbrido, local primero

**Estado:** aceptado para diseño; implementación post-V1

## Contexto

El asistente debe funcionar como Jarvis, pero no puede exigir una GPU grande ni
enviar datos privados a la nube por defecto.

## Decisión

- Modelo local por defecto cuando el hardware pueda (llama.cpp/Ollama,
  cuantizado, descarga explícita).
- Si el modelo local no puede ejecutar la tarea, se ofrece un proveedor cloud
  **por petición y con consentimiento explícito**, nunca silencioso.
- Servicio de usuario `org.mytical.Jarvis1` por D-Bus, sin root.
- Acciones declaradas, `dry_run`, confirmación para lo destructivo y auditoría
  JSONL local.
- Micrófono/pantalla solo por portales PipeWire/ScreenCast con indicador visible.
- Sin telemetría ni entrenamiento con datos del usuario.
- Secretos en keyring; política de retención configurable.

## Consecuencias

- V1 solo reserva interfaz, icono, ajustes y ADRs; no implementa voz ni modelos.
- Hay que definir proveedores, costes y consentimiento antes de código.
- El modo offline debe degradar con un mensaje claro.
