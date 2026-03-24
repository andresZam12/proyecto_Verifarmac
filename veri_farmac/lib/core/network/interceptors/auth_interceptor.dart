// Agrega el token de Supabase a cada request.
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Interceptor que agrega automáticamente el token de sesión
// de Supabase a cada request HTTP que haga la app.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Obtiene el token de la sesión activa
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    // Si hay sesión, agrega el header de autorización
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options); // continúa con el request
  }
}
