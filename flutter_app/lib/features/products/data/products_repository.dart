import 'dart:convert';
import 'dart:io';
import 'package:flutter_app/core/error/failures.dart';
import 'package:flutter_app/core/network/http_client_provider.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Repositorio de productos encargado de consumir la API pública de DummyJSON.
class ProductsRepository {
  final http.Client _client;
  static const String _baseUrl = 'https://dummyjson.com';

  ProductsRepository({required http.Client client}) : _client = client;

  /// Obtiene un listado paginado de productos.
  /// Endpoint: GET /products?limit={limit}&skip={skip}
  Future<List<Product>> getProducts({int limit = 20, int skip = 0}) async {
    try {
      final uri = Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip');
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> productsList = data['products'] as List<dynamic>;
        return productsList
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
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

  /// Busca productos por texto de consulta.
  /// Endpoint: GET /products/search?q={query}
  Future<List<Product>> searchProducts(String query) async {
    try {
      final uri =
          Uri.parse('$_baseUrl/products/search?q=${Uri.encodeComponent(query)}');
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> productsList = data['products'] as List<dynamic>;
        return productsList
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerFailure(
          'Error al buscar productos',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ParseFailure('Error inesperado al buscar productos: $e');
    }
  }

  /// Obtiene un producto específico mediante su identificador numérico.
  /// Endpoint: GET /products/{id}
  Future<Product> getProductById(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/products/$id');
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Product.fromJson(data);
      } else if (response.statusCode == 404) {
        throw ServerFailure(
          'Producto no encontrado (ID: $id)',
          statusCode: 404,
        );
      } else {
        throw ServerFailure(
          'Error al consultar el detalle del producto',
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

  /// Obtiene la lista de categorías disponibles en el catálogo.
  /// Endpoint: GET /products/categories
  Future<List<String>> getCategories() async {
    try {
      final uri = Uri.parse('$_baseUrl/products/categories');
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) {
                if (item is String) return item;
                if (item is Map) {
                  return (item['slug'] ?? item['name'] ?? '').toString();
                }
                return item.toString();
              })
              .where((cat) => cat.isNotEmpty)
              .toList();
        }
        return const [];
      } else {
        throw ServerFailure(
          'Error al obtener categorías de productos',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ParseFailure('Error inesperado al obtener categorías: $e');
    }
  }

  /// Obtiene productos pertenecientes a una categoría específica.
  /// Endpoint: GET /products/category/{category}
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/products/category/${Uri.encodeComponent(category)}',
      );
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> productsList = data['products'] as List<dynamic>;
        return productsList
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerFailure(
          'Error al obtener productos por categoría',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ParseFailure(
        'Error inesperado al obtener productos por categoría: $e',
      );
    }
  }
}

/// Proveedor del repositorio de productos inyectando el cliente HTTP.
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final client = ref.watch(httpClientProvider);
  return ProductsRepository(client: client);
});
