// Excepciones internas de la capa de datos.
// Las excepciones solo existen en la capa de datos (data/).
// Los repositorios las capturan y las convierten en Failure
// antes de llegar al dominio o la UI.

class ServidorException implements Exception {
  const ServidorException([this.mensaje = 'Error en el servidor']);
  final String mensaje;
}

class SinConexionException implements Exception {
  const SinConexionException();
}

class NoEncontradoException implements Exception {
  const NoEncontradoException([this.mensaje = 'No encontrado']);
  final String mensaje;
}

class CacheException implements Exception {
  const CacheException([this.mensaje = 'Error en base de datos local']);
  final String mensaje;
}

class AuthException implements Exception {
  const AuthException([this.mensaje = 'Error de autenticación']);
  final String mensaje;
}
