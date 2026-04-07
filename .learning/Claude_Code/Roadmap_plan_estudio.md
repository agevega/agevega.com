# Roadmap: Ingeniería Agentiva con Claude Code

**Proyecto:** agevega.com (portfolio) | **Estructura:** 6 módulos | **Actualizado:** 2026-04-07

> Basado en [Plan de Estudio Optimizado v2](Plan_estudio_optimizado_v2.md) y fundamentado en [claudepedia.dev](https://claudepedia.dev/).
> Módulos, no semanas — el ritmo lo decides tú.
> Sin commit, no hay aprendizaje.

---

## Estado actual del repositorio

| Artefacto | Estado | Notas |
|---|---|---|
| `CLAUDE.md` (raíz) | **Completo** | Convenciones, estructura, design system, workflow, Do NOT |
| `~/.claude/CLAUDE.md` (global) | **Completo** | Idiomas, git rules, seguridad, plan mode |
| `.claude/commands/audit.md` | **Completo** | `/audit` funcional |
| `.claude/commands/nuevo-componente.md` | **Completo** | `/nuevo-componente` funcional con design system |
| `.claude/settings.local.json` | **Completo** | Permisos Playwright MCP + npm audit |
| `costes.md` | **No existe** | Tampoco está en `.gitignore` |
| `.claude/settings.json` (hooks) | **No existe** | Sin hooks configurados |
| `.mcp.json` | **No existe** | Playwright funciona vía settings.local.json pero no hay config committeable |
| `.claude/agents/` | **No existe** | Ningún subagente creado |
| `evals/` | **No existe** | Sin sistema de evaluación |
| `scripts/changelog.sh` | **No existe** | Sin headless scripts |

**Tareas completadas previamente (Semana 1 del plan v1):**
- CLAUDE.md creado y completado (`aea3a06`, `ea1e780`)
- `/audit` y `/nuevo-componente` funcionales (`1fc2e7d`)
- Plan mode usado para accesibilidad global (documentado en `done/Plan_1.5`)
- 3 tareas reales: accesibilidad (`a2b665d`), SEO descriptions (`d0004d7`), image attrs + perf (`0cfbe11`)

---

## Dependencias entre módulos

```
Mod 0: Baseline + costes.md
  ├──→ Mod 1: Hooks y safety net
  └──→ Mod 2: MCP formal (Playwright + GitHub)
         ↘ ↙
       Mod 3: Subagentes (delegación)
           ↓
       Mod 4: Evals y calidad medible
           ↓
       Mod 5: Headless + CI + retrospectiva
```

---

## Módulo 0 — Baseline y Cost Tracking

**Objetivo:** Establecer la infraestructura de observación de costes que todo módulo posterior necesita.

**Ref claudepedia:** [Observability and Debugging](https://claudepedia.dev/patterns/observability) — 3 capas: event logging, cost tracking, session tracing. Aquí implementas la capa de cost tracking a nivel humano.

### Tareas

- [ ] **0.1** Añadir `costes.md` a `.gitignore`
  - **Verificación:** `git check-ignore costes.md` retorna exit code 0.

- [ ] **0.2** Crear `costes.md` con estructura de seguimiento
  - **Qué hacer:** Columnas: Fecha, Módulo, Tarea, Modelo, `/cost` resultado, Tiempo humano ahorrado, Notas.
  - **Backfill** las 3 tareas completadas (accesibilidad, SEO, image attrs) con costes aproximados.
  - **Verificación:** Archivo tiene al menos 4 entradas (3 backfill + 1 de este módulo).

### Criterio de cierre
- [ ] `.gitignore` incluye `costes.md`
- [ ] Archivo con 4+ entradas
- [ ] Sabes ejecutar `/cost` y localizar datos de sesión

---

## Módulo 1 — Hooks y Safety Net

**Objetivo:** Convertir las reglas pasivas de `CLAUDE.md` en guardrails activos que bloquean operaciones peligrosas.

**Por qué antes de subagentes:** Los subagentes amplifican capacidad Y riesgo. Un hook que bloquea `package-lock.json` protege contra un subagente desbocado desde el día uno.

**Refs claudepedia:**
- [Hooks and Extension Points](https://claudepedia.dev/patterns/hooks) — 4 modos (command, prompt, agent, http), 27+ eventos de ciclo de vida, condiciones con pattern-matching. Exit 0 = advisory, Exit 2 = bloqueo.
- [Safety and Permissions](https://claudepedia.dev/patterns/safety) — Cascada de 6 fuentes (policy > project > local > user > cli > session). Regla fail-closed: sin coincidencia = DENY.

### Tareas

- [ ] **1.1** Crear hook de bloqueo de archivos protegidos
  - **Qué hacer:** `.claude/settings.json` con hook `PreToolUse` en `Write|Edit` que bloquee escrituras a `package-lock.json`, `*.tfstate`, `*.lock`. Exit code 2 con mensaje descriptivo.
  - **Verificación:** Pedir editar `package-lock.json` → el hook lo bloquea con mensaje claro.

- [ ] **1.2** Crear hook advisory para Terraform
  - **Qué hacer:** Hook `PreToolUse` en `Read|Grep|Glob` que emita advertencia (exit 0 + stdout) al acceder a `infra/terraform/`.
  - **Verificación:** Explorar `infra/terraform/` → mensaje advisory aparece en contexto sin bloquear.

- [ ] **1.3** Verificar cascada de permisos
  - **Qué hacer:** Confirmar que `.claude/settings.json` (project) coexiste con `.claude/settings.local.json` (local) sin conflictos. Documentar el orden de resolución.
  - **Verificación:** Ambos ficheros activos, hooks funcionan, permisos de Playwright se mantienen.

### Criterio de cierre
- [ ] 2+ hooks activos en `.claude/settings.json`
- [ ] Al menos uno demuestra bloqueo (exit 2)
- [ ] Al menos uno demuestra advisory (exit 0 con mensaje)
- [ ] Entrada en `costes.md`

---

## Módulo 2 — MCP formal

**Objetivo:** Formalizar Playwright MCP en un `.mcp.json` committeable y añadir GitHub MCP para workflows con issues/PRs.

**Por qué este orden:** Ya tienes Playwright implícito. Este módulo lo formaliza y añade GitHub. Ambos son necesarios para el Módulo 3: subagentes que interactúan con GitHub y verifican visualmente son mucho más útiles que revisores read-only.

**Refs claudepedia:**
- [MCP Integration](https://claudepedia.dev/patterns/mcp) — Patrón Bridge: descubrimiento → construcción → namespacing (`mcp__server__tool`) → anotaciones. 5 transportes (stdio para local). 5 estados de conexión.
- [Tool System Design](https://claudepedia.dev/patterns/tools) — Las herramientas MCP, una vez bridgeadas, siguen el mismo schema que las nativas (concurrencia, flags, dispatcher idéntico).

### Tareas

- [ ] **2.1** Crear `.mcp.json` con Playwright + GitHub
  - **Qué hacer:** `.mcp.json` en raíz con ambos servidores via stdio/npx. `GITHUB_TOKEN` desde variable de entorno.
  - **Verificación:** `/mcp` muestra ambos servidores conectados.

- [ ] **2.2** Test GitHub MCP
  - **Dependencia:** 2.1
  - **Qué hacer:** Pedir a Claude que liste issues abiertos del repo.
  - **Verificación:** Retorna datos reales de GitHub.

- [ ] **2.3** Test Playwright MCP
  - **Dependencia:** 2.1
  - **Qué hacer:** Con `npm run dev` corriendo, pedir snapshot de `localhost:4321` y reporte de problemas visuales.
  - **Verificación:** Playwright navega y captura. Si falla en WSL2, documentar workaround.

### Criterio de cierre
- [ ] `.mcp.json` con 2 servidores configurados y verificados
- [ ] Entrada en `costes.md`

---

## Módulo 3 — Subagentes: Arquitectura de Delegación

**Objetivo:** Crear subagentes especializados siguiendo el patrón de claudepedia: el coordinador decide QUÉ, los workers deciden CÓMO.

**Por qué después de hooks + MCP:** Los hooks (Mod 1) protegen contra operaciones peligrosas — los subagentes heredan esa red de seguridad. MCP (Mod 2) les da capacidades reales (GitHub, Playwright).

**Refs claudepedia:**
- [Multi-Agent Coordination](https://claudepedia.dev/patterns/multi-agent) — Delegación, no distribución. 4 fases: planificar → delegar → recopilar → sintetizar. Aislamiento de contexto. Particionamiento de herramientas.
- [Agent Loop Architecture](https://claudepedia.dev/patterns/agent-loop) — Máquina de dos estados. Terminación natural cuando no hay `tool_calls`. `max_turns` como safety guard.
- [Tool System Design](https://claudepedia.dev/patterns/tools) — Clases de concurrencia: READ_ONLY (paralelo seguro), WRITE_EXCLUSIVE (serial), UNSAFE (aislamiento total). Algoritmo Partition-Then-Gather.

### Tareas

- [ ] **3.1** Crear subagente `code-reviewer`
  - **Qué hacer:** `.claude/agents/code-reviewer.md` — solo lectura (`Read`, `Grep`, `Glob`). Produce informe estructurado: Blockers / Suggestions / Nitpicks. Foco en accesibilidad, security smells, imports muertos.
  - **Verificación:** Pedir revisión de código y que produzca informe sin modificar archivos.

- [ ] **3.2** Crear subagente `component-builder`
  - **Qué hacer:** `.claude/agents/component-builder.md` — `Read`, `Glob`, `Write`, `Edit`. Crea componentes Astro siguiendo design system. Debe verificar existencia antes de crear.
  - **Verificación:** Delegar "crea un componente SkillsGrid" y que genere `.astro` coherente sin que le dictes el design system.

- [ ] **3.3** Crear subagente `infra-auditor`
  - **Qué hacer:** `.claude/agents/infra-auditor.md` — solo lectura (`Read`, `Grep`, `Glob`). Audita módulos Terraform: seguridad, coste, best practices AWS. Adaptado a la infra real (7 módulos, eu-south-2, Zero Trust).
  - **Verificación:** Analiza un módulo Terraform y señala issues reales.

- [ ] **3.4** Flujo completo de delegación
  - **Dependencia:** 3.1 + 3.2
  - **Qué hacer:** Ciclo real de las 4 fases de claudepedia:
    1. Declaras intención (ej: "crea componente SkillsGrid")
    2. Claude delega a `component-builder` → crea componente
    3. Pides revisión → Claude delega a `code-reviewer` → produce informe
    4. Revisas, apruebas, commiteas
  - **Verificación:** Un commit generado con este flujo. Entrada comparativa en `costes.md` (delegado vs. directo).

### Criterio de cierre
- [ ] 3 subagentes en `.claude/agents/`
- [ ] Un ciclo completo (crear + revisar) documentado
- [ ] Entrada en `costes.md` con comparativa de coste

---

## Módulo 4 — Evals y calidad medible

**Objetivo:** Reemplazar "parece que funciona" por "puedo medir si funciona".

**Por qué después de subagentes:** Necesitas subagentes activos para tener algo que evaluar. Los evals miden si siguen instrucciones, si CLAUDE.md es efectivo, y si la calidad se mantiene en sesiones limpias.

**Refs claudepedia:**
- [Prompt Architecture](https://claudepedia.dev/patterns/prompts) — Zona estática (el `.md` del subagente) vs zona dinámica (la tarea delegada). Los evals testean si la zona estática produce resultados correctos ante diferentes zonas dinámicas.
- [Memory and Context Management](https://claudepedia.dev/patterns/memory) — Jerarquía del olvido: in-context > summary > long-term > forgotten. Los subagentes viven solo en nivel 1 (in-context). Los evals verifican que funcionen con solo su zona estática + la tarea.
- Failure signatures: infinite loops, context overflow, wrong tool selection, **silent wrong answers** — este último solo lo atrapan los evals.

### Tareas

- [ ] **4.1** Definir 10+ evals en JSONL
  - **Qué hacer:** `evals/component-creation.jsonl` (5+ casos) y `evals/code-review.jsonl` (5+ casos). Criterios: `must_contain`, `must_not_contain`.
  - **Verificación:** `ls evals/*.jsonl` muestra al menos 2 archivos con 5+ casos cada uno.

- [ ] **4.2** Script runner para evals
  - **Dependencia:** 4.1
  - **Qué hacer:** `scripts/run-evals.sh` — itera JSONL, ejecuta contra `claude -p --model haiku`, verifica criterios, produce resumen pass/fail.
  - **Verificación:** Produce resumen en < 5 minutos.

- [ ] **4.3** Medir impacto
  - **Dependencia:** 4.2
  - **Qué hacer:** Ejecutar evals. Documentar resultados. Opcional: crear Skill en `~/.claude/skills/agevega-portfolio/SKILL.md` y comparar con/sin Skill.
  - **Verificación:** Tabla de resultados en `costes.md`.

### Criterio de cierre
- [ ] 10+ eval cases en 2+ archivos
- [ ] Runner funcional
- [ ] Resultados documentados
- [ ] Entrada en `costes.md`

---

## Módulo 5 — Headless + CI

**Objetivo:** Sacar Claude Code del terminal interactivo y llevarlo a workflows automatizados.

**Por qué al final:** Necesitas todo lo anterior para que la automatización tenga sentido. Un GitHub Action sin hooks, MCP ni evals es una caja negra costosa.

**Refs claudepedia:**
- [Streaming and Events](https://claudepedia.dev/patterns/streaming) — En headless (`-p`), eventos van a stdout: TextDelta, ToolDispatch, ToolResult, Complete.
- [Command and Plugin Systems](https://claudepedia.dev/patterns/commands) — 3 tipos de comandos (local, interactive, prompt). El flag `-p` usa el tipo prompt.
- [Agent Loop Architecture](https://claudepedia.dev/patterns/agent-loop) — En CI, `max_turns` bajo (5-10) para prevenir costes desbocados.

### Tareas

- [ ] **5.1** Script headless local
  - **Qué hacer:** `scripts/changelog.sh` — genera changelog en español desde los últimos N commits via `claude -p`.
  - **Verificación:** `bash scripts/changelog.sh` produce output legible.

- [ ] **5.2** GitHub Action de triage
  - **Dependencia:** 5.1
  - **Qué hacer:** `.github/workflows/03-claude-triage.yml` — trigger: issue con label `triage`. Claude comenta con tipo, archivos afectados, prioridad. Permisos: solo `issues: write`. `max_turns: 5`.
  - **Verificación:** Issue de prueba recibe comentario automático coherente.

- [ ] **5.3** Retrospectiva final de costes
  - **Qué hacer:** Comparar todas las entradas de `costes.md`. Calcular: coste total, modelo más rentable por tipo, tarea con peor ratio coste/valor, siguiente paso más valioso.
  - **Verificación:** Sección "Retrospectiva" completada en `costes.md`.

### Criterio de cierre
- [ ] 1 script headless funcional
- [ ] 1 GitHub Action desplegada y testeada
- [ ] Retrospectiva completada
- [ ] El repo contiene: `CLAUDE.md`, `.claude/agents/` (3), `.claude/commands/` (2), `.claude/settings.json` (hooks), `.mcp.json`, `evals/`, `scripts/changelog.sh`, y workflow CI

---

## Routing de modelos (referencia rápida)

| Tarea | Modelo | Por qué |
|---|---|---|
| Ediciones mecánicas, lint, renaming | Haiku 4.5 | Barato y rápido, suficiente para tareas deterministas |
| Componentes, reviews, docs | Sonnet 4.6 | Mejor ratio coste/calidad para trabajo creativo acotado |
| Plan mode, arquitectura, refactor multi-archivo | Opus 4.6 | Rentable cuando el espacio de decisión es grande |
| Subagentes (code-reviewer, component-builder, infra-auditor) | Sonnet | Trabajo acotado dentro de constraints claros |
| Evals runner | Haiku | Cada eval es un prompt corto y acotado |
| CI triage | Sonnet | Necesita razonamiento suficiente para clasificar issues |

Default: Haiku (configurado en `~/.claude/settings.json`). Cambiar explícitamente cuando necesites más capacidad.

---

## Checklist final (completar tras todos los módulos)

### Entregables en el repo
- [ ] `costes.md` con retrospectiva (en .gitignore)
- [ ] `.claude/settings.json` con hooks activos
- [ ] `.mcp.json` con Playwright + GitHub
- [ ] `.claude/agents/code-reviewer.md`
- [ ] `.claude/agents/component-builder.md`
- [ ] `.claude/agents/infra-auditor.md`
- [ ] `evals/` con 10+ casos
- [ ] `scripts/run-evals.sh`
- [ ] `scripts/changelog.sh`
- [ ] `.github/workflows/03-claude-triage.yml`

### Comprensión verificable
- [ ] Puedes explicar el Agent Loop (two-state machine) sin notas
- [ ] Puedes describir la cascada de permisos de 6 fuentes en orden
- [ ] Puedes articular por qué delegación > distribución para tu caso
- [ ] Puedes identificar las 4 failure signatures en una sesión real

---

## Notas finales

1. **Verificar siempre la sintaxis actual.** Hooks, `.mcp.json`, y comandos evolucionan. Validar con `/help` antes de copiar snippets.
2. **Regla de oro:** sin commit, no hay aprendizaje.
3. **Para detalle completo** de cada módulo (conceptos claudepedia, snippets de código, apéndices WSL2): ver [Plan_estudio_optimizado_v2.md](Plan_estudio_optimizado_v2.md).
4. **Default model:** Haiku. Cambiar según la tabla de routing.
