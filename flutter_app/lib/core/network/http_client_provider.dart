import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Proveedor del cliente HTTP base para toda la aplicación.
///
/// Gestiona el ciclo de vida del cliente http, cerrando la conexión al destruirse.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(() {
    client.close();
  });
  return client;
});
