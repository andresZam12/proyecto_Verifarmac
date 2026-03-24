// Cliente HTTP central con Dio.
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

// Cliente HTTP central de la app.
// Todas las llamadas a APIs externas pasan por aquí.
@lazySingleton
class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        // Tiempo máximo de espera para conectar y recibir respuesta
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Agregamos los interceptors en orden
    dio.interceptors.addAll([
      AuthInterceptor(),      // agrega el token de sesión
      RetryInterceptor(dio),  // reintenta si falla la conexión
    ]);
  }
}
