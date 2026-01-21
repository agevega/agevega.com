# 00-setup/02-budgets

Este módulo configura los presupuestos de AWS (AWS Budgets) para monitorizar los costes de la cuenta, replicando la configuración establecida manualmente.

## Recursos

1.  **Budget Mensual**: Límite de $10 USD.
2.  **Budget Diario**: Límite de $1 USD.

## Variables

| Nombre                  | Descripción           | Default             |
| ----------------------- | --------------------- | ------------------- |
| `monthly_budget_amount` | Límite mensual en USD | `10`                |
| `daily_budget_amount`   | Límite diario en USD  | `1`                 |
| `notification_email`    | Email para alertas    | `agevega@gmail.com` |

## Alertas

### Mensual ($10)

- **10% (Actual)**: > $1.00
- **50% (Actual)**: > $5.00
- **100% (Actual)**: > $10.00
- **200% (Forecasted)**: > $20.00

### Diario ($1)

- **50% (Actual)**: > $0.50
- **100% (Actual)**: > $1.00
- **200% (Actual)**: > $2.00
- **500% (Actual)**: > $5.00
- **1000% (Actual)**: > $10.00
