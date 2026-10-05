import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/error/failures.dart';
import '../../../core/network/http_client_provider.dart';
import '../domain/product.dart';
import 'product_dto.dart';

/// Repositorio de productos encargado de la comunicación con la API externa.
class ProductsRepository {
  final http.Client _client;
  static const String _baseUrl = 'https://dummyjson.com';

  ProductsRepository({required http.Client client}) : _client = client;

  /// Obtiene la lista completa de productos desde el endpoint remoto.
  Future<List<Product>> getProducts() async {
    try {
      final uri = Uri.parse('$_baseUrl/products');
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> productsList = data['products'] as List<dynamic>;
        return productsList
            .map((item) =>
                ProductDto.fromJson(item as Map<String, dynamic>).toDomain())
            .toList();
      } else {
        throw ServerFailure(
          'Error al cargar productos desde el servidor',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ParseFailure('Error inesperado al obtener productos: $e');
    }
  }

  /// Obtiene los detalles de un producto específico mediante su ID.
  Future<Product> getProductById(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/products/$id');
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return ProductDto.fromJson(data).toDomain();
      } else if (response.statusCode == 404) {
        throw ServerFailure(
          'Producto no encontrado (ID: $id)',
          statusCode: 404,
        );
      } else {
        throw ServerFailure(
          'Error al consultar el producto',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ParseFailure('Error inesperado al consultar el producto: $e');
    }
  }
}

/// Proveedor del repositorio de productos inyectando el cliente HTTP.
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final client = ref.watch(httpClientProvider);
  return ProductsRepository(client: client);
});
