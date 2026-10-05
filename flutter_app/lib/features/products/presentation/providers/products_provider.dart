import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/products_repository.dart';
import '../../domain/product.dart';

/// Proveedor asíncrono para listar todos los productos con autoDispose.
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productsRepositoryProvider);
  return repository.getProducts();
});

/// Proveedor para obtener el detalle de un producto por ID con autoDispose y family.
final productDetailProvider =
    FutureProvider.autoDispose.family<Product, int>((ref, productId) async {
  final repository = ref.watch(productsRepositoryProvider);
  return repository.getProductById(productId);
});

/// Proveedor para filtrar u ordenar productos en la pantalla principal.
final productSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Proveedor derivado que filtra la lista de productos según el query de búsqueda.
final filteredProductsProvider =
    Provider.autoDispose<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final query = ref.watch(productSearchQueryProvider).trim().toLowerCase();

  return productsAsync.whenData((products) {
    if (query.isEmpty) return products;
    return products.where((product) {
      final matchesTitle = product.title.toLowerCase().contains(query);
      final matchesBrand = product.brand.toLowerCase().contains(query);
      final matchesCategory = product.category.toLowerCase().contains(query);
      return matchesTitle || matchesBrand || matchesCategory;
    }).toList();
  });
});
