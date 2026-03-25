#!/bin/bash

# Fix 1: Agregar flutter_localizations al pubspec.yaml
sed -i '/  cupertino_icons:/i\  flutter_localizations:\n    sdk: flutter' pubspec.yaml

# Fix 2: app_theme.dart - CardTheme -> CardThemeData
sed -i 's/cardTheme: CardTheme(/cardTheme: CardThemeData(/g' lib/core/theme/app_theme.dart

# Fix 3: main.dart - agregar import de injection_container
sed -i "s|import 'package:flutter/material.dart';|import 'package:flutter/material.dart';\nimport 'injection_container.dart';|" lib/main.dart

# Fix 4: medicine_provider.dart - agregar import faltante
sed -i "s|import '..\/..\/domain\/usecases\/get_medicine_usecase.dart';|import '../../data/repositories/medicine_repository_impl.dart';\nimport '../../domain/usecases/get_medicine_usecase.dart';|" lib/features/medicine_detail/presentation/providers/medicine_provider.dart

echo "✅ Correcciones aplicadas"
