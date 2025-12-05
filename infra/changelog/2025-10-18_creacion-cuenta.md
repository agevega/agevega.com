# 🧩 2025-10-18 — Creación de la cuenta AWS

### 🗂️ Descripción

Creación y configuración inicial de la cuenta raíz de AWS destinada al proyecto **agevegacom**.  
Este paso establece la base de seguridad, control de costes y configuración regional para toda la infraestructura futura.

---

### ⚙️ Acciones realizadas

- Registro de una **nueva cuenta AWS** con el correo: `agevega.com@gmail.com`.
- Selección del **plan de pago estándar (sin limitación de uso)**.
- Activación de **autenticación multifactor (MFA)** para el usuario raíz, utilizando aplicación móvil TOTP.
- Configuración del **idioma de la consola en inglés (English - US)** para mantener consistencia con documentación técnica.
- Configuración de **la moneda de visualización y facturación en euros (EUR)** desde _Billing → Cost Management → Preferences_.
- Creación de un **presupuesto mensual (“My 10$ Budget”)** con importe total de **10 USD (~10 EUR)** y alertas escalonadas al 10 %, 50 %, 100 % y 200 %.
- Creación de un **presupuesto diario (“My Daily 1$ Budget”)** con importe total de **1 USD (~1 EUR)** y alertas escalonadas al 50 %, 100 %, 200 %, 500 % y 1000 %.
- Habilitación de la opción **“Enable IAM Access to Billing”**, permitiendo que los usuarios IAM puedan acceder a la información de facturación y costes.

---

### 🎯 Motivo

- Establecer una **base segura y controlada** desde el primer día.
- Garantizar visibilidad sobre los **costes, consumo y proyecciones**.
- Mantener coherencia en idioma (inglés técnico) y divisa (euro) para informes financieros.
- Cumplir buenas prácticas recomendadas por AWS (no usar el usuario raíz para operaciones diarias).

---

### 🧾 Evidencias / Comentarios

- Verificado funcionamiento del **MFA raíz** mediante autenticación TOTP.
- Configuración confirmada en **English (US)** y **display currency: EUR**.
- Presupuesto configurado desde _Billing → Budgets_ con notificaciones a `agevega@gmail.com`.
- Confirmado acceso IAM a la facturación desde _Account → IAM User and Role Access to Billing Information_.
- Correo de verificación de creación de cuenta recibido correctamente en Gmail.
