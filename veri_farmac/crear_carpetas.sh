#!/bin/bash
# Ejecutar desde la RAÍZ del proyecto (donde está pubspec.yaml)
# Mac/Linux: bash crear_carpetas.sh
# Windows Git Bash: bash crear_carpetas.sh

echo "Creando estructura de features..."

# ── scanner ───────────────────────────────────────────────────
mkdir -p lib/features/scanner/data/datasources
mkdir -p lib/features/scanner/data/models
mkdir -p lib/features/scanner/data/repositories
mkdir -p lib/features/scanner/domain/entities
mkdir -p lib/features/scanner/domain/repositories
mkdir -p lib/features/scanner/domain/usecases
mkdir -p lib/features/scanner/presentation/pages
mkdir -p lib/features/scanner/presentation/providers
mkdir -p lib/features/scanner/presentation/widgets

# ── medicine_detail ───────────────────────────────────────────
mkdir -p lib/features/medicine_detail/data/datasources
mkdir -p lib/features/medicine_detail/data/models
mkdir -p lib/features/medicine_detail/data/repositories
mkdir -p lib/features/medicine_detail/domain/entities
mkdir -p lib/features/medicine_detail/domain/repositories
mkdir -p lib/features/medicine_detail/domain/usecases
mkdir -p lib/features/medicine_detail/presentation/pages
mkdir -p lib/features/medicine_detail/presentation/providers
mkdir -p lib/features/medicine_detail/presentation/widgets

# ── history ───────────────────────────────────────────────────
mkdir -p lib/features/history/data/datasources
mkdir -p lib/features/history/data/models
mkdir -p lib/features/history/data/repositories
mkdir -p lib/features/history/domain/entities
mkdir -p lib/features/history/domain/repositories
mkdir -p lib/features/history/domain/usecases
mkdir -p lib/features/history/presentation/pages
mkdir -p lib/features/history/presentation/providers
mkdir -p lib/features/history/presentation/widgets

# ── dashboard ─────────────────────────────────────────────────
mkdir -p lib/features/dashboard/data/datasources
mkdir -p lib/features/dashboard/data/repositories
mkdir -p lib/features/dashboard/domain/usecases
mkdir -p lib/features/dashboard/presentation/pages
mkdir -p lib/features/dashboard/presentation/providers
mkdir -p lib/features/dashboard/presentation/widgets

# ── map ───────────────────────────────────────────────────────
mkdir -p lib/features/map/data/datasources
mkdir -p lib/features/map/data/repositories
mkdir -p lib/features/map/domain/usecases
mkdir -p lib/features/map/presentation/pages
mkdir -p lib/features/map/presentation/providers
mkdir -p lib/features/map/presentation/widgets

# ── settings (solo presentation, sin data ni domain) ──────────
mkdir -p lib/features/settings/presentation/pages
mkdir -p lib/features/settings/presentation/providers
mkdir -p lib/features/settings/presentation/widgets

# ── shared ────────────────────────────────────────────────────
mkdir -p lib/shared/widgets
mkdir -p lib/shared/extensions

echo ""
echo "✓ Estructura creada. Verificando..."
echo ""
find lib/features -type d | sort
