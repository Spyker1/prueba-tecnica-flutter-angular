import 'package:flutter_app/features/products/domain/product.dart';

/// Modelo inmutable que representa la respuesta paginada devuelta por DummyJSON.
class PaginatedProductsResponse {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const PaginatedProductsResponse({
    required this.products,
    required this.total,
    this.skip = 0,
    this.limit = 20,
  });

  factory PaginatedProductsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['products'] as List<dynamic>? ?? [])
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();

    return PaginatedProductsResponse(
      products: list,
      total: (json['total'] as num?)?.toInt() ?? list.length,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );
  }
}
