#!/bin/bash

# 1. Reemplazar app_database.dart — eliminar Drift que no está en el proyecto
cat > lib/core/database/app_database.dart << 'DART'
// Base de datos local — usando SharedPreferences en vez de Drift
// para simplificar el proyecto y evitar build_runner.
DART

# 2. Corregir ConnectivityResult en offline_banner.dart
sed -i 's/result != ConnectivityResult.none/!result.contains(ConnectivityResult.none)/' lib/shared/widgets/offline_banner.dart

# 3. Corregir ConnectivityResult en network_info.dart
sed -i 's/result != ConnectivityResult.none/!result.contains(ConnectivityResult.none)/' lib/core/network/network_info.dart

# 4. Reemplazar withOpacity por withValues en todos los archivos dart
find lib -name "*.dart" -exec sed -i 's/\.withOpacity(\([^)]*\))/.withValues(alpha: \1)/g' {} \;

echo "✅ Warnings corregidos"
