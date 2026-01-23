# Refactorización del Módulo Bastion (02-bastion-EC2)

**Fecha:** 23/01/2026  
**Autor:** Terraform  
**Módulos afectados:** `02-bastion-EC2`

---

## 📝 Descripción del cambio

Se ha refactorizado el módulo `02-bastion-EC2` para mejorar la granularidad y el control sobre los recursos. El diseño anterior de 2 pasos (`00-security`, `01-instance`) mezclaba la creación de recursos persistentes (EIP, Key Pair) con grupos de seguridad.

La nueva arquitectura divide el despliegue en 4 submódulos atómicos:

1.  **`00-security`**: Gestión exclusiva de **Security Groups**.
2.  **`01-ssh-key`**: Gestión del recurso **AWS Key Pair**.
3.  **`02-eip`**: Gestión de la **Elastic IP**.
4.  **`03-instance`**: Despliegue de la instancia EC2 y asociación de recursos.

## 🏗️ Cambios en Infraestructura

### Nuevo Árbol de Directorios

```plaintext
02-bastion-EC2/
├── 00-security/      # Security Groups
├── 01-ssh-key/       # AWS Key Pair
├── 02-eip/           # Elastic IP
└── 03-instance/      # EC2 Instance
```

### Justificación

- **Separación de responsabilidades:** Cada módulo gestiona un único tipo de recurso lógico.
- **Gestión de estado:** Evita destruir la IP elástica o la clave SSH si se necesitan cambios solo en reglas de firewall.
- **Seguridad:** Se restringe el acceso SSH únicamente a la IP del administrador (`79.117.246.12/32`) por defecto.
