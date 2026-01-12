# 🧩 2026-01-12 — Optimización de Costes EC2 (Migración a ARM64)

### 🗂️ Descripción

Actualización del módulo `02-bastion-EC2` para migrar la instancia Bastion de arquitectura x86 a **ARM64 (Graviton2)**, seleccionando la instancia más económica disponible.

---

## ⚙️ Cambios realizados

### Infraestructura (Terraform)

- **Instancia**: Cambio de `t3.micro` (Intel) a **`t4g.nano`** (ARM64).
  - Reducción de memoria de 1GB a 0.5GB (suficiente para Nginx estático + Bastion).
- **AMI**: Actualización del _data source_ para buscar imágenes **Amazon Linux 2023 ARM64** (`al2023-ami-2023.*-arm64`).

### CI/CD (GitHub Actions)

- **Multi-Arch Build**: Actualización del workflow `00-generate-docker-image.yml` para soportar `linux/arm64`.
  - Integración de **QEMU** y **Docker Buildx** par compilar imágenes ARM desde runners x86.

---

## 🎯 Motivo

- **Reducción de Costes**: La familia `t4g` ofrece mejor relación precio/rendimiento. `t4g.nano` es la opción más barata absoluta en la región, reduciendo el coste mensual de ~6€ (t3/t4g micro fuera de free tier) a ~3€.
- **Eficiencia**: Aprovechar la eficiencia energética y de rendimiento de los procesadores Graviton.

---

## 💰 Impacto en Costes

| Recurso          | Coste Anterior (t3.micro) | Coste Nuevo (t4g.nano) | Ahorro Estimado |
| :--------------- | :------------------------ | :--------------------- | :-------------- |
| **EC2 Instance** | ~6.00 €/mes\*             | **~3.00 €/mes**        | \*\*~5          |
