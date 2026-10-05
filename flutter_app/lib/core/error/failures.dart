/// Clase base inmutable para el manejo de fallos y errores en la aplicación.
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

/// Fallo producido por una respuesta de error del servidor remoto (códigos HTTP 4xx, 5xx).
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  String toString() =>
      statusCode != null ? '$message (Código: $statusCode)' : message;
}

/// Fallo derivado de problemas de conectividad o red no disponible.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Sin conexión a internet. Verifica tu red.',
  ]);
}

/// Fallo producido durante la deserialización o análisis de datos JSON.
class ParseFailure extends Failure {
  const ParseFailure([
    super.message = 'Error al procesar la información recibida.',
  ]);
}

/// Fallo para capturar excepciones inesperadas no catalogadas.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Ocurrió un error inesperado.']);
}
