// Clases de fallo que retorna el dominio.
// Los Failure son los errores que el dominio le comunica a la UI.
// En vez de lanzar excepciones, los use cases retornan un Failure.

abstract class Failure {
  const Failure(this.mensaje);
  final String mensaje;
}

// Sin conexión a internet
class SinConexionFailure extends Failure {
  const SinConexionFailure() : super('Sin conexión a internet');
}

// Error del servidor o API
class ServidorFailure extends Failure {
  const ServidorFailure([String mensaje = 'Error en el servidor'])
      : super(mensaje);
}

// Medicamento no encontrado en la base de datos
class NoEncontradoFailure extends Failure {
  const NoEncontradoFailure() : super('Medicamento no encontrado');
}

// Error al leer o escribir en la base de datos local
class CacheFailure extends Failure {
  const CacheFailure() : super('Error al acceder al historial local');
}

// Permiso de cámara o ubicación denegado
class PermisoFailure extends Failure {
  const PermisoFailure() : super('Permiso denegado');
}

// No se pudo leer el código del medicamento
class EscaneoFailure extends Failure {
  const EscaneoFailure() : super('No se pudo leer el código');
}

// Error de autenticación
class AuthFailure extends Failure {
  const AuthFailure([String mensaje = 'Error de autenticación'])
      : super(mensaje);
}

// Error genérico para casos no contemplados
class ErrorDesconocidoFailure extends Failure {
  const ErrorDesconocidoFailure() : super('Ocurrió un error inesperado');
}
