# Plan de Estudio Optimizado v2
## Dominar Claude Code y sub-agentes IA con `agevega.com` como banco de pruebas

> **Versión:** 2.0 — Abril 2026
> **Audiencia:** DevSecOps senior, Windows + WSL2, Claude Code instalado y funcional.
> **Fuente principal:** [claudepedia.dev](https://claudepedia.dev/) — enciclopedia de arquitectura de Claude Code.
> **Sustituye a:** `Plan_estudio_optimizado.txt` y `Roadmap_plan_estudio.md` (no los modifica).

---

## Principios rectores

1. **Workflows > agentes.** Si la tarea tiene una ruta correcta clara, usa un workflow determinista. Solo escala a agente autónomo cuando el espacio de soluciones sea grande. ([claudepedia: Agent Loop Architecture](https://claudepedia.dev/patterns/agent-loop))
2. **Hooks antes que agentes.** Los hooks protegen el repo. Los subagentes amplifican capacidad Y riesgo. Configura la red de seguridad antes de soltar a los agentes.
3. **Hacer > leer.** Cada módulo termina con un entregable verificable en el repo. Sin commit, sin aprendizaje.
4. **Coste como variable de diseño.** Revisa `/cost` en cada módulo. Si una tarea cuesta más que tu tiempo ahorrado, está mal diseñada. ([claudepedia: Observability — Cost Tracking](https://claudepedia.dev/patterns/observability))
5. **Lo nativo primero.** `CLAUDE.md`, slash commands y subagentes Markdown resuelven el 80%. Orquestadores externos son la última opción, no la primera.

---

## Mapa de módulos

| Mod | Nombre | Prerrequisito | Entregable | Horas est. | Refs claudepedia |
|-----|--------|--------------|-----------|-----------|-----------------|
| 0 | Baseline y Cost Tracking | Ninguno | `costes.md` + entrada en `.gitignore` | 1–2 h | [Observability](https://claudepedia.dev/patterns/observability) |
| 1 | Hooks y Safety Net | Mod 0 | `.claude/settings.json` con 2+ hooks | 3–4 h | [Hooks](https://claudepedia.dev/patterns/hooks), [Safety](https://claudepedia.dev/patterns/safety) |
| 2 | MCP formal | Mod 0 | `.mcp.json` con Playwright + GitHub | 3–4 h | [MCP Integration](https://claudepedia.dev/patterns/mcp), [Tool System](https://claudepedia.dev/patterns/tools) |
| 3 | Subagentes: Delegación | Mod 1 + 2 | 3 agentes en `.claude/agents/` | 5–7 h | [Multi-Agent](https://claudepedia.dev/patterns/multi-agent), [Agent Loop](https://claudepedia.dev/patterns/agent-loop) |
| 4 | Evals y calidad medible | Mod 3 | `evals/` con 10+ casos + runner | 5–7 h | [Prompt Architecture](https://claudepedia.dev/patterns/prompts), [Memory](https://claudepedia.dev/patterns/memory) |
| 5 | Headless + CI | Mod 4 | Script + GitHub Action + retrospectiva | 4–6 h | [Streaming](https://claudepedia.dev/patterns/streaming), [Commands](https://claudepedia.dev/patterns/commands) |

**Total estimado:** 21–30 horas. Ritmo libre — módulos, no semanas.

```
Mod 0 ──→ Mod 1 (hooks) ──→ Mod 3 (subagentes) ──→ Mod 4 (evals) ──→ Mod 5 (CI)
   └────→ Mod 2 (MCP) ────↗
```

---

## Estado actual del repo (punto de partida)

### Ya funciona
- `CLAUDE.md` en raíz — convenciones, estructura, workflow, prohibiciones
- `~/.claude/CLAUDE.md` global — idioma, git rules, seguridad, orquestación
- `.claude/commands/audit.md` — `/audit` funcional
- `.claude/commands/nuevo-componente.md` — `/nuevo-componente` funcional
- `.claude/settings.local.json` — permisos para Playwright MCP y npm audit
- Playwright MCP operativo (vía settings.local.json)
- 3 tareas reales completadas con plan mode (accesibilidad, SEO, performance)

### Falta (lo que cubre este plan)
- `costes.md` y su entrada en `.gitignore`
- `.claude/settings.json` (hooks de proyecto)
- `.mcp.json` (MCP formal y committeable)
- `.claude/agents/` (subagentes)
- `evals/` (sistema de evaluación)
- Scripts headless y CI workflows

---

## Módulo 0 — Baseline y Cost Tracking

**Objetivo:** Establecer la infraestructura de observación de costes que todo módulo posterior necesita.

**Por qué primero:** Sin datos de coste, no puedes evaluar si un módulo merece su gasto en tokens. El plan v1 lo ponía como tarea 1.6 dentro de una semana cargada — nunca se completó.

### Conceptos clave (claudepedia)

**Observability and Debugging** describe 3 capas independientes para diagnosticar sistemas de agentes:
1. **Structured Event Logging** — *"¿Qué sucedió?"*
2. **Cost Tracking** — *"¿Qué costó?"* — Rastrea por sesión y cross-sesión. Distingue tokens input/output de tokens de caché.
3. **Session Tracing** — *"¿Cuánto tiempo tomó?"*

En este módulo implementas la capa 2 a nivel humano (registro manual en `costes.md`). Las capas 1 y 3 son automáticas en Claude Code (`/cost`, logs internos).

### Práctica en agevega.com

1. Añadir `costes.md` a `.gitignore`
2. Crear `costes.md` con esta estructura:

```markdown
# Registro de costes — Claude Code en agevega.com

| Fecha | Módulo | Tarea | Modelo | /cost resultado | Tiempo humano ahorrado | Notas |
|-------|--------|-------|--------|----------------|----------------------|-------|
| 2026-0X-XX | Pre-plan | Accesibilidad global | Opus | $X.XX | ~2h | Plan_1.5 |
| 2026-0X-XX | Pre-plan | SEO descriptions | Sonnet | $X.XX | ~1h | d0004d7 |
| 2026-0X-XX | Pre-plan | Image attrs + perf | Sonnet | $X.XX | ~30min | 0cfbe11 |
| | | | | | | |

## Retrospectiva (completar en Módulo 5)
```

3. Backfill las 3 tareas ya completadas con costes aproximados
4. Registrar el coste de este propio módulo como primera entrada real

### Criterio de cierre
- [ ] `git check-ignore costes.md` retorna exit code 0
- [ ] El archivo tiene al menos 4 entradas (3 backfill + 1 nueva)
- [ ] Sabes ejecutar `/cost` y localizar datos de sesión

---

## Módulo 1 — Hooks y Safety Net

**Objetivo:** Convertir las reglas pasivas de `CLAUDE.md` en guardrails activos que bloquean operaciones peligrosas.

**Por qué antes de subagentes:** Los subagentes amplifican tanto la capacidad como el riesgo. Un subagente con permisos de escritura que modifica `package-lock.json` viola tus reglas. Mejor que un hook lo bloquee automáticamente.

### Conceptos clave (claudepedia)

**Hooks and Extension Points** — Claude Code expone 27+ eventos de ciclo de vida donde puedes inyectar lógica:

| Modo | Caso de uso | Coste |
|------|-----------|-------|
| `command` | Scripts, validadores, linters | Bajo |
| `prompt` | Clasificación, moderación | Medio |
| `agent` | Verificación multi-paso | Alto |
| `http` | Webhooks, auditoría | Bajo-Medio |

Eventos relevantes para este módulo:
- `PreToolUse` — se ejecuta ANTES de que una herramienta actúe. Ideal para bloquear.
- `PostToolUse` — se ejecuta DESPUÉS. Ideal para logging/notificación.

Protocolo de respuesta de hooks:
- **Exit 0** = continuar (advisory: el mensaje stdout va al contexto)
- **Exit 2** = bloquear (el mensaje stderr explica por qué)

**Safety and Permissions** — Cascada de 6 fuentes de permisos (orden de prioridad):
1. `policySettings` (empresa)
2. `projectSettings` (`.claude/settings.json` — lo que vamos a crear)
3. `localSettings` (`.claude/settings.local.json` — ya existe)
4. `userSettings` (`~/.claude/settings.json`)
5. `cliArg` (flags `--allow`/`--deny`)
6. `session` (permisos interactivos)

Regla de oro: **fail-closed** — sin coincidencia en la cascada = DENY.

### Práctica en agevega.com

Crear `.claude/settings.json` con al menos 2 hooks:

**Hook 1 — Bloqueo de archivos protegidos** (`PreToolUse`):
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'FILE=\"$CLAUDE_FILE_PATH\"; if [[ \"$FILE\" == *package-lock.json* ]] || [[ \"$FILE\" == *.tfstate* ]] || [[ \"$FILE\" == *.lock ]]; then echo \"BLOCKED: $FILE is a protected file\" >&2; exit 2; fi'"
          }
        ]
      }
    ]
  }
}
```
Esto hace cumplir activamente lo que `~/.claude/CLAUDE.md` Sección 5 ya declara como política.

**Hook 2 — Advisory en directorio Terraform** (`PreToolUse`):
```json
{
  "matcher": "Read|Grep|Glob",
  "hooks": [
    {
      "type": "command",
      "command": "bash -c 'if [[ \"$CLAUDE_FILE_PATH\" == *infra/terraform* ]]; then echo \"[advisory] Accessing Terraform module — changes here require terraform plan verification\"; fi'"
    }
  ]
}
```
Exit 0 = no bloquea, pero el mensaje entra al contexto como recordatorio.

### Verificación
- Pedir a Claude que edite `package-lock.json` → el hook lo bloquea con mensaje claro
- Pedir a Claude que explore `infra/terraform/` → el hook emite advisory sin bloquear
- `.claude/settings.json` listo para commit

### Criterio de cierre
- [ ] 2+ hooks activos en `.claude/settings.json`
- [ ] Al menos uno demuestra bloqueo (exit 2)
- [ ] Al menos uno demuestra advisory (exit 0 con mensaje)
- [ ] Entrada en `costes.md`

---

## Módulo 2 — MCP formal

**Objetivo:** Formalizar la configuración MCP en un `.mcp.json` committeable y añadir GitHub MCP para workflows con issues/PRs.

**Por qué este orden:** Ya tienes Playwright funcionando implícitamente vía `settings.local.json`. Este módulo lo formaliza y añade GitHub MCP. Ambos son necesarios para el Módulo 3: subagentes que interactúan con GitHub y verifican visualmente son mucho más útiles que revisores read-only.

### Conceptos clave (claudepedia)

**MCP Integration** — El Model Context Protocol convierte servicios externos en herramientas nativas:

**Patrón Bridge (puente de herramientas):**
1. Descubrimiento: consulta `tools/list` al servidor
2. Construcción: crea objetos Tool estándar
3. Namespacing: formato `mcp__servidor__herramienta`
4. Anotaciones: transmite hints (`read_only_hint`, `destructive_hint`) al sistema de permisos

**5 transportes disponibles:**
| Transporte | Uso |
|-----------|-----|
| **stdio** | Procesos locales (el más común) |
| **HTTP** | Servidores remotos (bidireccional) |
| **WebSocket** | Baja latencia |
| **SSE** | Remotos legados (unidireccional) |
| **SDK** | Integración en proceso |

Para agevega.com usamos **stdio** en ambos (Playwright y GitHub son procesos locales via npx).

**5 estados de conexión:** `connected`, `failed`, `needs-auth`, `pending`, `disabled`. Regla: todos los estados no-connected retornan listas de herramientas vacías (consistencia sin exponer errores).

**Tool System Design** — Las herramientas MCP, una vez bridgeadas, siguen el mismo esquema que las nativas:
- Schema (nombre + descripción + parámetros tipados)
- Clase de concurrencia (READ_ONLY, WRITE_EXCLUSIVE, UNSAFE)
- Behavioral flags (permisos, destructividad, timeout)
- El dispatcher las trata idénticamente a las herramientas built-in

### Práctica en agevega.com

1. Crear `.mcp.json` en raíz del proyecto:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

2. Verificar que `GITHUB_TOKEN` está exportado en `~/.zshrc` (nunca commitear)

3. **Test GitHub MCP:** Pedir a Claude que liste issues abiertos del repo → debe devolver datos reales

4. **Test Playwright MCP:** Con `npm run dev` corriendo, pedir a Claude que navegue a `localhost:4321`, tome un snapshot y reporte problemas visuales

5. **Check WSL2:** Verificar que Playwright puede lanzar browser dentro de WSL2. Si falla (es un problema conocido), documentar el workaround en notas de `costes.md`.

### Verificación
- `/mcp` muestra ambos servidores conectados
- "Lista issues abiertos" retorna datos reales de GitHub
- Playwright navega y captura snapshot del dev server
- `.mcp.json` listo para commit

### Criterio de cierre
- [ ] `.mcp.json` con 2 servidores configurados
- [ ] Ambos servidores verificados funcionando
- [ ] Entrada en `costes.md`

---

## Módulo 3 — Subagentes: Arquitectura de Delegación

**Objetivo:** Crear subagentes especializados que siguen el patrón de coordinación de claudepedia: el coordinador decide QUÉ, los workers deciden CÓMO.

**Por qué después de hooks + MCP:** Los hooks (Mod 1) protegen el repo de operaciones peligrosas — los subagentes heredan esa protección. MCP (Mod 2) les da capacidades reales (GitHub, Playwright) que hacen la delegación útil de verdad.

### Conceptos clave (claudepedia)

**Multi-Agent Coordination** — El patrón fundamental es **delegación, no distribución**:

**4 fases del coordinador:**
1. **Planificación:** Descompone la petición en subtareas
2. **Delegación:** Lanza workers (potencialmente en paralelo)
3. **Recopilación:** Espera completación
4. **Síntesis:** Llamada LLM adicional para integrar resultados (no retransmite crudo)

**Aislamiento de contexto:** Cada worker inicia con historial fresco e independiente. Esto:
- Previene cascadas de error
- Habilita ejecución paralela
- Facilita debugging (artefactos autocontenidos)
- Aísla contra prompt injection

**Particionamiento de herramientas:** El coordinador solo tiene herramientas de coordinación (spawn, send, stop), NO acceso a archivos/APIs. Previene que eluda la delegación. Los workers tienen las herramientas específicas de su dominio.

**Agent Loop Architecture** — Cada subagente ejecuta la misma máquina de dos estados:
1. Esperar respuesta del modelo
2. Si hay `tool_calls` → ejecutar → añadir resultados → volver a 1
3. Si no hay `tool_calls` → terminación natural

`max_turns` (típico: 20) como safety guard contra bucles infinitos.

**Tool System Design** — Las clases de concurrencia determinan qué puede hacer cada agente:
- `READ_ONLY`: Paralelo seguro (queries, lectura de archivos)
- `WRITE_EXCLUSIVE`: Ejecución serial (mutaciones de archivos)
- `UNSAFE`: Aislamiento total (shell execution)

El algoritmo **Partition-Then-Gather** agrupa herramientas READ_ONLY para ejecución paralela y serializa las WRITE_EXCLUSIVE. Esto es lo que hace que un `code-reviewer` (solo READ_ONLY) sea inherentemente seguro para ejecutar en paralelo.

### Práctica en agevega.com

Crear 3 subagentes en `.claude/agents/`:

#### Subagente 1: `code-reviewer.md`

```markdown
---
description: Reviews code changes for bugs, accessibility, dead imports, and security smells
model: sonnet
tools: Read, Grep, Glob
---

You are a code reviewer for the agevega.com portfolio site (Astro 5 + TailwindCSS).

## Your task
Analyze the code or files provided and produce a structured review report.

## Output format
### Blockers (must fix before merge)
- [file:line] Description

### Suggestions (should fix, not blocking)
- [file:line] Description

### Nitpicks (optional improvements)
- [file:line] Description

### Summary
One paragraph assessment.

## Rules
- NEVER modify files. You are read-only.
- Focus on: accessibility (WCAG), dead imports, security smells, Astro/Tailwind anti-patterns.
- Reference the project's CLAUDE.md for conventions.
- If there are no issues, say so clearly — don't invent problems.
```

#### Subagente 2: `component-builder.md`

```markdown
---
description: Creates Astro components following the project design system
model: sonnet
tools: Read, Glob, Write, Edit
---

You are a frontend builder for agevega.com (Astro 5 + TailwindCSS).

## Your task
Create or modify Astro components following the project's design system.

## Before creating anything
1. Read CLAUDE.md for conventions and design tokens
2. Check if a similar component already exists (Glob for *.astro)
3. If it exists, suggest modification instead of duplication

## Design system (verify against CLAUDE.md)
- Background: brand-dark (#0B1426), brand-surface (#0F172A)
- Font: Inter 300-700
- Accents: Slate (borders), Emerald (CTAs), Blue (glows)
- Animations: fade-in, fade-in-up, slide-up
- Container: max-w-7xl mx-auto px-4

## Component structure
1. Frontmatter (Props interface if needed)
2. Markup (semantic HTML + Tailwind utilities)
3. Scoped style (only if Tailwind cannot achieve the effect)

## Rules
- Filename: PascalCase.astro in src/components/
- Indentation: 2 spaces in markup
- No external CSS files, no inline styles
- No npm dependencies without explicit approval
```

#### Subagente 3: `infra-auditor.md`

```markdown
---
description: Reviews Terraform modules for security, cost, and AWS best practices
model: sonnet
tools: Read, Grep, Glob
---

You are an infrastructure security auditor for agevega.com's AWS setup.

## Context
- 7 numbered Terraform modules (00-setup through 99-domain)
- Region: eu-south-2 (Madrid)
- Architecture: Zero Trust (WAF -> CloudFront -> ALB -> EC2)
- Config values from AWS SSM Parameter Store, never hardcoded

## Your task
Analyze Terraform modules and produce a security/cost audit report.

## Output format
### Critical (security risk or compliance issue)
- [module/file:line] Description + remediation

### Cost optimization
- [module/file] Description + estimated monthly savings

### Best practices
- [module/file] Description + recommendation

### Summary
One paragraph assessment.

## Rules
- NEVER modify files. You are read-only.
- Flag: hardcoded secrets, overly permissive IAM/SG, missing encryption, public exposure
- Flag: resources without tags, oversized instances, missing lifecycle policies
- Respect the existing module order and naming conventions
```

### Ejercicio completo: ciclo de delegación

1. Pide a Claude principal crear un componente nuevo (ej: `SkillsGrid`)
2. Claude delega a `component-builder` → crea el componente
3. Pide a Claude principal revisar el resultado
4. Claude delega a `code-reviewer` → produce informe de auditoría
5. Revisa el informe, aprueba, commiteas

Esto demuestra las 4 fases de claudepedia: planificar (declaras intención), delegar (Claude enruta a especialista), recopilar (especialista retorna), sintetizar (Claude presenta hallazgos).

### Verificación
- `/agents` muestra los 3 subagentes
- `component-builder` crea un `.astro` válido sin que le dictes el design system (lee CLAUDE.md)
- `code-reviewer` produce informe estructurado sin modificar archivos
- `infra-auditor` analiza un módulo Terraform y señala issues reales

### Criterio de cierre
- [ ] 3 subagentes en `.claude/agents/`
- [ ] Un ciclo completo (crear + revisar) documentado
- [ ] Entrada en `costes.md` comparando coste delegado vs. directo

---

## Módulo 4 — Evals y calidad medible

**Objetivo:** Reemplazar "parece que funciona" por "puedo medir si funciona".

**Por qué después de subagentes:** Necesitas los subagentes creados para tener algo que evaluar. Los evals miden si los subagentes siguen las instrucciones, si CLAUDE.md es efectivo, y si la calidad se mantiene en sesiones limpias.

### Conceptos clave (claudepedia)

**Prompt Architecture** — La arquitectura de prompts tiene dos zonas:
- **Zona estática** (idéntica en todas las sesiones): identidad del agente, reglas, instrucciones de herramientas. Cacheable vía Prompt Caching.
- **Zona dinámica** (varía por sesión): contexto, memoria del usuario, herramientas activas.

El `.md` de un subagente ES su zona estática. La tarea delegada es su zona dinámica. Los evals testean si la zona estática produce resultados correctos ante diferentes zonas dinámicas.

**Memory and Context Management** — Jerarquía del olvido:
1. **In-context** (message list) — fidelidad perfecta, máximo coste
2. **Summary** (LLM-condensado) — pierde detalle
3. **Long-term storage** (fact files) — sobrevive sesión
4. **Forgotten** — descartado

Los subagentes operan solo a nivel 1 (in-context). No tienen memoria a largo plazo — son especialistas desechables. Los evals verifican que funcionen correctamente con solo su zona estática + la tarea.

**Failure signatures** (patrones de fallo observables):
- **Infinite tool loops**: Misma herramienta con argumentos idénticos, repetidamente
- **Context overflow**: Alto message count, tokens cerca del límite, calidad degradada
- **Wrong tool selection**: Descripciones vagas impiden distinguir opciones
- **Silent wrong answers**: Sin señales de error — requiere validación post-completación

Los evals detectan el último caso (silent wrong answers) que ningún otro mecanismo atrapa.

### Práctica en agevega.com

1. Crear directorio `evals/` en raíz del proyecto

2. Escribir casos de evaluación en JSONL:

**`evals/component-creation.jsonl`** (5+ casos):
```jsonl
{"input": "Create a TestimonialCard component", "must_contain": ["PascalCase", "brand-dark", "max-w-7xl"], "must_not_contain": ["style=", "import.*css"]}
{"input": "Create a component called Footer", "must_contain": ["already exists", "Footer.astro"], "must_not_contain": []}
{"input": "Create a StatsGrid showing project metrics", "must_contain": ["<section", "grid", "emerald"], "must_not_contain": ["inline"]}
```

**`evals/code-review.jsonl`** (5+ casos):
```jsonl
{"input": "Review this component: <img src='test.jpg'>", "must_contain": ["alt", "accessibility"], "must_not_contain": []}
{"input": "Review this component: <section class='max-w-7xl mx-auto px-4'><h2 class='text-white'>Title</h2></section>", "must_contain": ["no issues", "clean"], "must_not_contain": ["bug", "critical"]}
```

3. Crear `scripts/run-evals.sh`:
```bash
#!/bin/bash
# Runner básico de evals para Claude Code
# Uso: bash scripts/run-evals.sh evals/component-creation.jsonl

FILE="${1:?Uso: run-evals.sh <archivo.jsonl>}"
PASS=0; FAIL=0; TOTAL=0

while IFS= read -r line; do
  TOTAL=$((TOTAL + 1))
  INPUT=$(echo "$line" | jq -r '.input')

  echo "--- Eval #$TOTAL: $INPUT"
  RESULT=$(echo "$INPUT" | claude -p --model haiku 2>/dev/null)

  # Check must_contain
  OK=true
  for term in $(echo "$line" | jq -r '.must_contain[]'); do
    if ! echo "$RESULT" | grep -qi "$term"; then
      echo "  FAIL: missing '$term'"
      OK=false
    fi
  done

  # Check must_not_contain
  for term in $(echo "$line" | jq -r '.must_not_contain[]'); do
    if echo "$RESULT" | grep -qi "$term"; then
      echo "  FAIL: found unwanted '$term'"
      OK=false
    fi
  done

  if $OK; then
    PASS=$((PASS + 1))
    echo "  PASS"
  else
    FAIL=$((FAIL + 1))
  fi
done < "$FILE"

echo ""
echo "=== Results: $PASS/$TOTAL passed, $FAIL failed ==="
```

4. Ejecutar evals y registrar resultados en `costes.md`

5. **Skill opcional** — Si quieres ir más allá, crea tu primera Skill:

```
~/.claude/skills/agevega-portfolio/
└── SKILL.md
```

Contenido de `SKILL.md`: instrucciones empaquetadas para crear componentes del portfolio. Test: en sesión limpia (`/clear`), "create a component for agevega.com" debe producir resultados correctos sin contexto adicional. Ejecuta evals con y sin Skill activa, compara.

### Criterio de cierre
- [ ] 2+ archivos JSONL en `evals/` con 5+ casos cada uno
- [ ] `scripts/run-evals.sh` funcional
- [ ] Resultados muestran pass rate por categoría
- [ ] Tabla comparativa (aunque sea simple) con/sin CLAUDE.md
- [ ] Entrada en `costes.md`

---

## Módulo 5 — Headless + CI

**Objetivo:** Sacar Claude Code del terminal interactivo y llevarlo a workflows automatizados.

**Por qué al final:** Necesitas todo lo anterior funcionando para que la automatización tenga sentido. Un GitHub Action sin hooks, MCP ni evals es una caja negra costosa.

### Conceptos clave (claudepedia)

**Streaming and Events** — En modo headless (`-p`), los eventos van a stdout. Tipos principales:
- `TextDelta`: Fragmentos de texto generados
- `ToolDispatch`: Herramientas invocadas
- `ToolResult`: Completación de herramientas
- `Complete`: Respuesta finalizada

**Command and Plugin Systems** — Tres tipos de comandos:
- `local`: Funciones sincrónicas retornando texto/data
- `interactive`: Componentes UI con callbacks
- `prompt`: Bloques inyectados en conversaciones — el flag `-p` (headless) usa este tipo

**Agent Loop Architecture** — En CI, `max_turns` es crítico. El agente terminará cuando:
- No haya más `tool_calls` (terminación natural)
- Se exceda `max_turns` (safety guard)
- Se active abort signal

En CI, quieres `max_turns` bajo (5-10) para prevenir costes desbocados.

### Práctica en agevega.com

#### 1. Script headless local: `scripts/changelog.sh`

```bash
#!/bin/bash
# Genera changelog en español a partir de commits recientes
# Uso: bash scripts/changelog.sh [desde-ref]

DESDE=${1:-"HEAD~10"}

git log --oneline "${DESDE}..HEAD" | \
  claude -p "Genera un changelog en español a partir de estos commits.
Agrupa por tipo: Features, Fixes, Refactors, Docs.
Formato Markdown. Sé conciso."
```

#### 2. GitHub Action: triage automático de issues

Crear `.github/workflows/03-claude-triage.yml`:

```yaml
name: Claude Issue Triage
on:
  issues:
    types: [labeled]

jobs:
  triage:
    if: contains(github.event.label.name, 'triage')
    runs-on: ubuntu-latest
    permissions:
      issues: write
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            Analyze this GitHub issue and provide:
            1. Issue type (bug / feature / question / improvement)
            2. Likely affected files or modules
            3. Suggested priority (low / medium / high)
            4. Brief quality assessment of the issue description

            Be concise. Respond in Spanish.
          max_turns: 5
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

Permisos mínimos: `issues: write` solamente. Sin acceso a código para escritura.

#### 3. Retrospectiva final

Completar la sección "Retrospectiva" en `costes.md`:

```markdown
## Retrospectiva

| Módulo | Coste total | Modelo principal | Insight |
|--------|------------|-----------------|---------|
| 0 | $X.XX | — | — |
| 1 | $X.XX | Opus | — |
| 2 | $X.XX | Sonnet | — |
| 3 | $X.XX | Sonnet | — |
| 4 | $X.XX | Haiku (evals) | — |
| 5 | $X.XX | Sonnet | — |
| **Total** | **$XX.XX** | | |

### Lecciones aprendidas
- Modelo más rentable por tipo de tarea: ...
- Tarea con peor ratio coste/valor: ...
- Siguiente paso más valioso: ...
```

### Verificación
- `bash scripts/changelog.sh` produce output legible
- Issue con label `triage` recibe comentario automático
- Retrospectiva completada en `costes.md`

### Criterio de cierre
- [ ] 1 script headless funcional
- [ ] 1 GitHub Action desplegada y testeada
- [ ] Retrospectiva completada
- [ ] El repo ahora contiene: `CLAUDE.md`, `.claude/agents/` (3), `.claude/commands/` (2), `.claude/settings.json` (hooks), `.mcp.json`, `evals/`, `scripts/changelog.sh`, y un workflow CI

---

## Apéndice A — Routing de modelos

| Tipo de tarea | Modelo | Razonamiento |
|--------------|--------|-------------|
| Ediciones mecánicas, lint, renaming | Haiku 4.5 | Barato y rápido, suficiente para tareas deterministas |
| Componentes, reviews, docs | Sonnet 4.6 | Mejor ratio coste/calidad para trabajo creativo acotado |
| Plan mode, arquitectura, refactors multi-archivo | Opus 4.6 | Rentable cuando el espacio de decisión es grande |
| Subagente: code-reviewer | Sonnet | Análisis read-only no necesita Opus |
| Subagente: component-builder | Sonnet | Trabajo creativo dentro de constraints claros |
| Subagente: infra-auditor | Sonnet | Análisis de dominio con constraints claros |
| Evals runner | Haiku | Cada eval es un prompt corto y acotado |
| CI triage | Sonnet | Necesita razonamiento suficiente para clasificar issues |

El default en `~/.claude/settings.json` ya es Haiku. Cambia explícitamente cuando lo necesites.

---

## Apéndice B — Trampas WSL2

1. **Rutas cross-filesystem:** Editar archivos WSL desde Windows (`\\wsl.localhost\Ubuntu\...`) es lento y confunde file watchers. Mantén todo el trabajo de Claude Code dentro de WSL (`~/repositorios/`). Ya lo haces correctamente.

2. **Playwright en WSL2:** Chromium puede fallar al lanzar sin display server. Workarounds: (a) `--headed=false`, (b) Playwright del lado Windows con forwarding, (c) `@playwright/mcp` que lo maneja internamente. Ya tienes Playwright MCP funcionando — probablemente resuelto.

3. **Variables de entorno:** Variables en `~/.zshrc` no son visibles para procesos lanzados desde Windows. Si un MCP server falla porque falta `GITHUB_TOKEN`, verifica que Claude Code se lanzó desde zsh de WSL.

4. **Permisos de archivos:** Hooks que escriben desde un lado (Windows/WSL) y leen desde el otro pueden ver mismatches de permisos. Mantén todo el ciclo en WSL.

5. **Docker Desktop:** Asegura que el backend WSL2 de Docker Desktop esté habilitado y que `docker` funcione desde zsh de WSL, no solo PowerShell.

---

## Apéndice C — Glosario de patrones clave (claudepedia)

| Patrón | Descripción |
|--------|------------|
| **Agent Loop (Two-State Machine)** | Ciclo fundamental: esperar respuesta → despachar herramientas → repetir |
| **Partition-Then-Gather** | Algoritmo de ejecución paralela: agrupa por concurrencia, paraleliza READ_ONLY, serializa WRITE_EXCLUSIVE |
| **Hierarchy of Forgetting** | In-context > summary > long-term > forgotten. Los subagentes viven solo en nivel 1 |
| **Compaction Pipeline** | trim > drop > compress > summarize. Qué sucede cuando el contexto se llena |
| **Fail-Closed** | Si la resolución de permisos falla, deniega. El default de seguridad |
| **Append-Tail** | Cómo se añade contenido dinámico al final de la zona estática del prompt |
| **Delegation, Not Distribution** | El coordinador decide QUÉ, los workers deciden CÓMO |
| **File-Based Mailbox** | Cómo se comunican los agentes — mediante archivos, no mensajes directos |
| **Escalation Ladder** | retry > fallback > degrade > fail. Cómo se escalan errores |
| **Bridge Pattern (MCP)** | Herramientas MCP aparecen como nativas vía namespacing (`mcp__server__tool`) |
| **Metadata-First** | Los comandos se registran por metadata, no por implementación. Lazy loading |
| **Circuit Breaker** | Tras N fallos consecutivos, detener reintentos. Evita desperdiciar tokens |

---

## Apéndice D — Exclusiones intencionadas

| Excluido | Por qué |
|----------|--------|
| **Agent teams / swarms** | Para un portfolio de un solo mantenedor, el overhead de coordinar equipos paralelos supera el beneficio. `git worktree` + dos sesiones logra el 90% del paralelismo |
| **NotebookLM como infraestructura** | No tiene API. Útil para estudio personal (audio overviews), no como backend de agentes |
| **Claude Agent SDK (Python/TypeScript)** | Para aplicaciones de producción. Para workflow personal, los subagentes Markdown son la abstracción correcta |
| **MCP server propio** | Valioso cuando tienes una fuente de datos única. Para agevega.com, Playwright + GitHub cubren las necesidades |
| **Equipos paralelos con bus de mensajes** | Lo nativo primero (principio 5). ROI negativo para web personal |

---

## Checklist final (completa al terminar todos los módulos)

### Entregables en el repo
- [ ] `costes.md` con retrospectiva completa (en .gitignore)
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
- [ ] Puedes justificar qué modelo usar para cada tipo de tarea
