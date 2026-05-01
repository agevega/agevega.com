---
title: Introducción a DevOps y DevSecOps
description: Aprende los fundamentos de DevOps y cómo integrar la seguridad desde el inicio del ciclo de desarrollo. Pipelines CI/CD, principios de shift-left security y primeras automatizaciones.
youtubeId: dQw4w9WgXcQ
category: devops
tags: [devops, devsecops, cicd, fundamentos, automatizacion]
order: 1
publishedAt: 2024-01-15
difficulty: beginner
resources:
  - label: Código del curso en GitHub
    url: https://github.com/agevega/academy-devops-intro
  - label: Roadmap DevOps (roadmap.sh)
    url: https://roadmap.sh/devops
  - label: Documentación de GitHub Actions
    url: https://docs.github.com/es/actions
---

## ¿Qué es DevOps?

DevOps es una cultura y conjunto de prácticas que une el desarrollo de software (Dev) con las operaciones de infraestructura (Ops) para acortar el ciclo de vida del desarrollo y entregar software de mayor calidad de forma continua.

Los tres pilares de DevOps son:

- **Cultura**: equipos de Dev y Ops comparten responsabilidad del ciclo completo
- **Automatización**: todo lo que se pueda automatizar, se automatiza
- **Medición**: métricas de rendimiento del sistema y del equipo

## DevSecOps: la seguridad desde el principio

DevSecOps añade la seguridad (Sec) al modelo DevOps. El principio clave es **shift-left security**: no tratar la seguridad como un paso final, sino integrarla en cada fase del pipeline.

```bash
# Ejemplo: análisis estático de seguridad en el pipeline
name: Security Scan
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          severity: 'CRITICAL,HIGH'
```

## Tu primer pipeline CI/CD

Un pipeline básico tiene tres etapas: **Build → Test → Deploy**.

```yaml
# .github/workflows/ci.yml
name: CI Pipeline
on: [push]

jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: docker build -t myapp .
      - name: Test
        run: docker run myapp npm test
```

## Conceptos clave de este curso

1. **Pipeline CI/CD**: automatiza el proceso de integrar código y desplegarlo
2. **Infraestructura como Código (IaC)**: gestionar infraestructura con código versionado
3. **Contenedores**: Docker encapsula aplicaciones con sus dependencias
4. **Monitorización**: métricas, logs y alertas en producción

En los siguientes cursos veremos cada uno de estos temas en profundidad.
