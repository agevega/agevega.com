# Roadmap: Ingeniería Agentiva con Claude Code

**Proyecto:** agevega.com (portfolio) | **Duración:** 5 semanas | **Actualizado:** 2026-04-07

> Cada semana depende estrictamente de la anterior. No saltar.
> Cada hito produce un cambio real en el repositorio. Si no hay commit, no hay aprendizaje.

---

## Estado actual del repositorio

| Artefacto | Estado | Notas |
|---|---|---|
| `CLAUDE.md` (raíz) | **Parcial** | Solo infraestructura. Faltan: convenciones de código, estructura frontend, "cómo trabajo", qué NO hacer |
| `~/.claude/CLAUDE.md` (global) | Completo | Reglas sólidas: no commits por Claude, idiomas, plan mode, estilo de código |
| `.claude/commands/audit.md` | Completo | Comando `/audit` funcional |
| `.claude/settings.local.json` | Completo | Permisos para Playwright MCP y npm audit |
| `.mcp.json` | **No existe** | Playwright funciona vía settings.local.json pero no hay config commiteada |
| `.claude/agents/` | **No existe** | Ningún subagente creado |
| `.claude/settings.json` (hooks) | **No existe** | Sin hooks configurados |
| `costes.md` | **No existe** | Tampoco está en `.gitignore` |
| `evals/` | **No existe** | |
| `~/.claude/skills/` | **No existe** | |

**Nota importante:** Este sitio es un **portfolio**, no un blog. No existe `src/content/blog/`. Las tareas referidas a posts MDX del plan original no aplican.

**Estructura frontend real:**
- `frontend/src/pages/` — 5 páginas: index, about, about-this-web, contact, laboratory
- `frontend/src/components/` — 10 componentes: Navigation, HeroSection, AboutSection, ExperienceSection, TechStackSection, ProjectsSection, ArchitectureSection, LaboratorioSection, ContactSection, Footer
- `frontend/src/layouts/` — 1 layout: Layout.astro

---

## Dependencias entre semanas

```
Semana 1: CLAUDE.md completo + commands + costes.md + plan mode
    ↓
Semana 2: subagentes + hooks (requiere CLAUDE.md para informar a los agentes)
    ↓
Semana 3: MCP + worktrees + Playwright (requiere subagentes para el flujo completo)
    ↓
Semana 4: evals + skills (requiere datos de semanas anteriores para medir)
    ↓
Semana 5: headless + CI (requiere todo lo anterior funcionando)
```

---

## Semana 1 — Cimientos productivos

**Objetivo:** Que Claude Code sea la interfaz principal para trabajar en agevega.com, con memoria de proyecto completa y coste registrado.

### Lo que YA está hecho

- [x] **1.1** Crear `CLAUDE.md` en la raíz del repositorio
  - *Verificado:* commiteado en `aea3a06`, actualizado en `ea1e780`.
- [x] **1.2** Crear un slash command personalizado
  - *Verificado:* `/audit` existe en `.claude/commands/audit.md`, commiteado en `1fc2e7d`.

### Lo que FALTA (en orden)

- [x] **1.3** Completar el `CLAUDE.md` con las secciones ausentes
  - **Dependencia:** 1.1 (ya cumplida)
  - **Qué hacer:** Añadir al `CLAUDE.md` existente:
    1. **Convenciones de código** — indentación 4 espacios, componentes Astro en PascalCase, clases Tailwind
    2. **Estructura del frontend** — `src/pages/`, `src/components/`, `src/layouts/`, un Layout único
    3. **Cómo me gusta trabajar** — plan mode para cambios > 20 líneas, refactor y feature en PRs separados
    4. **Cosas que NO hacer** — no instalar deps sin pedir, no reformatear archivos no relacionados, no tocar package-lock.json a mano
  - **Verificación:** Sesión limpia (`/clear`), pedir "analiza la estructura del frontend de agevega.com". Debe responder coherentemente sin que reexpliques nada.

- [x] **1.4** Crear un segundo slash command útil para el portfolio
  - **Dependencia:** 1.3
  - **Qué hacer:** Crear `.claude/commands/nuevo-componente.md` — genera el esqueleto de un componente Astro con la estructura y convenciones del proyecto.
  - **Verificación:** Ejecutar `/nuevo-componente TestimonialCard` y que genere un `.astro` correcto.

- [x] **1.5** Usar plan mode para una tarea real no trivial
  - **Dependencia:** 1.3
  - **Qué hacer:** Elegir una tarea real del portfolio:
    - Refactorizar un componente existente para mejorar accesibilidad
    - Crear una nueva página (ej. `/uses` o `/til`)
    - Optimizar el `Layout.astro` para mejorar Core Web Vitals
  - Activar plan mode (`Shift+Tab`), revisar el plan, aprobar.
  - **Verificación:** El plan se genera sin preguntas de contexto. El resultado pasa `npm run build`.

- [x] **1.6** Crear `costes.md` y añadirlo a `.gitignore`
  - **Dependencia:** ninguna
  - **Qué hacer:**
    1. Añadir `costes.md` a `.gitignore`
    2. Crear el archivo: `| Fecha | Tarea | Modelo | Coste (/cost) | Tiempo ahorrado |`
    3. Registrar el coste de las tareas 1.3, 1.4 y 1.5
  - **Verificación:** `git check-ignore costes.md` devuelve exit code 0. El archivo tiene al menos 3 entradas.

- [ ] **1.7** Completar 5 tareas reales fusionadas
  - **Dependencia:** 1.3 + 1.5
  - **Qué hacer:** Las tareas 1.3, 1.4 y 1.5 suman tres. Necesitas dos más:
    - Mejorar la página `/contact` con validación del formulario
    - Añadir metadatos SEO (Open Graph, Twitter Cards) al `Layout.astro`
    - Optimizar imágenes existentes a WebP
    - Mejorar el componente `Navigation.astro`
  - Cada tarea registrada en `costes.md`.
  - **Verificación:** `git log --oneline` muestra al menos 5 commits nuevos.

### Criterio de cierre
- `CLAUDE.md` con convenciones, estructura y flujo de trabajo
- 2+ slash commands funcionales (`/audit` + uno nuevo)
- `costes.md` con 5+ entradas, gitignored
- 5 tareas reales commiteadas
- Sesión limpia entiende el proyecto sin reexplicaciones

---

## Semana 2 — Subagentes Markdown + hooks de seguridad

**Objetivo:** Delegar tareas repetitivas a subagentes con herramientas restringidas y bloquear operaciones peligrosas con hooks.

**Requisito previo:** Semana 1 completa (CLAUDE.md, commands, costes.md).

### Tareas (en orden)

- [ ] **2.1** Crear subagente `code-reviewer`
  - **Qué hacer:** `.claude/agents/code-reviewer.md` — solo lectura (`Read`, `Grep`, `Glob`). Busca bugs, problemas de accesibilidad, imports muertos.
  - **Verificación:** `/agents` lo muestra. Pedir "revisa los cambios" y que produzca informe sin modificar archivos.

- [ ] **2.2** Crear subagente `component-builder`
  - **Qué hacer:** `.claude/agents/component-builder.md` — herramientas `Read`, `Glob`, `Write`, `Edit`. Crea componentes Astro + TailwindCSS respetando convenciones.
  - **Verificación:** Delegar "crea un componente SkillCard" y que genere un `.astro` coherente.

- [ ] **2.3** Crear subagente `test-writer`
  - **Qué hacer:** `.claude/agents/test-writer.md` — herramientas `Read`, `Grep`, `Glob`, `Write`. Escribe tests, no toca código de producción.
  - **Verificación:** `/agents` muestra los tres subagentes.

- [ ] **2.4** Configurar un hook de seguridad
  - **Dependencia:** 2.1–2.3
  - **Qué hacer:** Crear `.claude/settings.json` con hook `PreToolUse` que bloquee escrituras en `package-lock.json` y archivos `.tfstate`. Exit code 2 con mensaje descriptivo.
  - **Verificación:** Pedir editar `package-lock.json` y que el hook lo bloquee.

- [ ] **2.5** Flujo completo con subagentes
  - **Dependencia:** 2.1–2.4
  - **Qué hacer:** Flujo real: `component-builder` genera → tú revisas → `code-reviewer` audita → tú commiteas.
  - **Verificación:** Un commit generado con este flujo. Entrada en `costes.md`.

### Criterio de cierre
- 3 subagentes funcionales en `.claude/agents/`
- 1+ hook activo que bloquea una operación prohibida
- Un commit generado con flujo de subagentes
- `costes.md` actualizado

---

## Semana 3 — MCP configurado + git worktrees + observabilidad visual

**Objetivo:** Formalizar conexión con herramientas externas, trabajar en múltiples ramas en paralelo, detectar regresiones visuales con Playwright.

**Requisito previo:** Semana 2 completa (subagentes, hooks).

### Tareas (en orden)

- [ ] **3.1** Crear `.mcp.json` a nivel de proyecto
  - **Qué hacer:** `.mcp.json` en la raíz con Playwright + GitHub MCP. Token de GitHub en variable de entorno (nunca commiteado).
  - **Verificación:** `/mcp` muestra ambos servidores conectados. Pedir "lista los issues abiertos" y que responda vía GitHub MCP.

- [ ] **3.2** Inspección visual con Playwright
  - **Dependencia:** 3.1
  - **Qué hacer:** Con `npm run dev` corriendo, pedir que Playwright abra `localhost:4321`, capture la home y reporte elementos desbordados, contraste insuficiente o links rotos.
  - **Verificación:** Playwright navega y reporta hallazgos reales.

- [ ] **3.3** Adoptar git worktrees
  - **Qué hacer:** Crear dos worktrees, abrir dos sesiones de Claude Code en paralelo, completar ambas tareas.
  - **Verificación:** `git worktree list` muestra worktrees activos. Dos commits independientes sin conflictos.

- [ ] **3.4** Detectar y corregir una regresión visual
  - **Dependencia:** 3.1, 3.2, 3.3
  - **Qué hacer:** En un worktree, introducir un cambio visual roto. Playwright lo detecta, generas el parche, Playwright verifica, `code-reviewer` audita.
  - **Verificación:** Commit que corrige regresión visual detectada por Playwright.

- [ ] **3.5** Revisar consumo con ccusage
  - **Qué hacer:** Instalar `ccusage`, comparar con `costes.md`.
  - **Verificación:** Datos coherentes, diferencia < 10%.

### Criterio de cierre
- `.mcp.json` commiteado con Playwright + GitHub
- Regresión visual detectada y corregida semi-automáticamente
- Uso real de git worktrees con sesiones paralelas
- `ccusage` funcional

---

## Semana 4 — Evals propios + primera Skill

**Objetivo:** Medir el rendimiento de Claude objetivamente y empaquetar conocimiento reutilizable.

**Requisito previo:** Semana 3 completa (MCP, datos suficientes de tareas reales).

### Tareas (en orden)

- [ ] **4.1** Definir 10–20 evals para tareas frecuentes
  - **Qué hacer:** Directorio `evals/` con archivos JSONL. Casos adaptados al portfolio:
    - "Crea un componente ContactForm con validación" → debe contener `<form`, atributos `aria-`
    - "Refactoriza HeroSection para mejorar accesibilidad" → debe contener `role=`, `alt=`
  - **Verificación:** `ls evals/*.jsonl` muestra al menos 2 archivos con 5+ casos cada uno.

- [ ] **4.2** Script runner para evals
  - **Dependencia:** 4.1
  - **Qué hacer:** Script (bash o Python) que ejecute cada eval contra `claude -p` y compare output con criterios.
  - **Verificación:** Produce resumen con porcentaje de aciertos en < 5 minutos.

- [ ] **4.3** Empaquetar la primera Skill
  - **Dependencia:** 4.1, 4.2
  - **Qué hacer:** `~/.claude/skills/agevega-portfolio/SKILL.md` — para crear y optimizar componentes del portfolio. Anti-patrones incluidos.
  - **Verificación:** En sesión limpia (`/clear`), "crea un componente TestimonialCard para agevega.com" produce resultado coherente sin más contexto.

- [ ] **4.4** Medir impacto con evals
  - **Dependencia:** 4.2, 4.3
  - **Qué hacer:** Ejecutar evals con y sin Skill. Comparar resultados.
  - **Verificación:** Tabla comparativa antes/después.

### Criterio de cierre
- `evals/` con 10+ casos ejecutables
- Skill `agevega-portfolio` funcional en sesión limpia
- Tabla comparativa documentada
- `costes.md` actualizado

---

## Semana 5 — Headless mode + CI ligero

**Objetivo:** Ejecutar Claude Code fuera del terminal interactivo y automatizar tareas vía GitHub Actions.

**Requisito previo:** Semana 4 completa (skill, evals, todo el ecosistema).

### Tareas (en orden)

- [ ] **5.1** Script local en headless mode
  - **Qué hacer:** `scripts/changelog.sh` — usa `claude -p` para generar changelog en español desde los últimos N commits.
  - **Verificación:** `bash scripts/changelog.sh` produce changelog legible.

- [ ] **5.2** GitHub Action de bajo riesgo
  - **Dependencia:** 5.1
  - **Qué hacer:** Workflow que se activa con etiqueta `triage` en un issue. Claude deja comentario con tipo, archivos afectados, calidad de redacción. Sin permisos de escritura sobre código.
  - **Verificación:** Issue de prueba con etiqueta `triage` recibe comentario automático coherente.

- [ ] **5.3** Revisión final de costes
  - **Qué hacer:** Comparar `costes.md` con `ccusage`. Calcular coste total, tiempo ahorrado, modelo más rentable por tipo de tarea.
  - **Verificación:** Sección "Retrospectiva" al final de `costes.md`.

- [ ] **5.4** PR automatizado (hito final)
  - **Dependencia:** 5.1, 5.2
  - **Qué hacer:** Workflow que genera un PR con cambios de Claude en headless mode. Se revisa localmente con `code-reviewer` antes de mergear.
  - **Verificación:** PR en GitHub cuyo contenido fue generado por una GitHub Action.

### Criterio de cierre
- Script headless funcional
- 1+ GitHub Action con Claude operativa
- PR generado automáticamente y revisado
- Retrospectiva de costes documentada
- El repo tiene: `CLAUDE.md` completo, `.claude/agents/`, `.claude/commands/`, `.mcp.json`, hooks, evals, y un workflow CI

---

## Routing de modelos (referencia rápida)

| Tarea | Modelo | Por qué |
|---|---|---|
| Ediciones mecánicas, lint, renombrar | Haiku 4.5 | Barato y rápido |
| Componentes, reviews, redacción | Sonnet 4.6 | Caballo de batalla |
| Plan mode, arquitectura, refactor complejo | Opus 4.6 | Vale lo que cuesta |

---

## Notas finales

1. **Verificar siempre la sintaxis actual.** Hooks, `.mcp.json`, y comandos de Claude Code evolucionan. Validar con `/help` antes de copiar snippets.
2. **Regla de oro:** si no hay commit, no hay aprendizaje.
3. **`costes.md` debe ir en `.gitignore`.** Añadirlo es parte de la tarea 1.6.
4. **Modelo por defecto:** Haiku (configurado en `~/.claude/settings.json`). Cambiar según la tabla de routing.
