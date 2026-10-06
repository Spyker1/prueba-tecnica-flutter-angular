import 'dart:async';
import 'package:flutter_app/features/products/data/products_repository.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider asíncrono para listar el catálogo principal de productos.
/// Consume GET /products?limit=20&skip=0
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productsRepositoryProvider);
  return repository.getProducts(limit: 20, skip: 0);
});

/// Provider para el término de búsqueda introducido en la interfaz.
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Provider que lista las categorías disponibles desde el repositorio.
/// Consume GET /products/categories
final categoriesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final repository = ref.watch(productsRepositoryProvider);
  return repository.getCategories();
});

/// Provider para la categoría actualmente seleccionada por el usuario (null = todas).
final selectedCategoryProvider =
    StateProvider.autoDispose<String?>((ref) => null);

/// Provider asíncrono con DEBOUNCE de 400 ms para consultar la búsqueda y categoría sin saturar la API.
///
/// - Si no hay búsqueda por texto, expone la categoría seleccionada o el catálogo base.
/// - Si el usuario busca texto, aplica debounce de 400 ms y filtra dentro de la categoría activa si aplica.
final searchResultsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final repository = ref.watch(productsRepositoryProvider);

  // Si no hay búsqueda de texto
  if (query.isEmpty) {
    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      return repository.getProductsByCategory(selectedCategory);
    }
    return ref.watch(productsProvider.future);
  }

  // Mecanismo de cancelación para Riverpod
  var isDisposed = false;
  ref.onDispose(() {
    isDisposed = true;
  });

  // Espera de debounce de 400 ms
  await Future<void>.delayed(const Duration(milliseconds: 400));

  // Si el provider fue descartado durante la espera, no emite resultado obsoleto
  if (isDisposed) {
    return Completer<List<Product>>().future;
  }

  final results = await repository.searchProducts(query);
  if (selectedCategory != null && selectedCategory.isNotEmpty) {
    return results
        .where(
          (p) => p.category.toLowerCase() == selectedCategory.toLowerCase(),
        )
        .toList();
  }
  return results;
});

/// Provider para consultar el detalle de un producto mediante su identificador.
/// Consume GET /products/{id}
final productDetailProvider =
    FutureProvider.autoDispose.family<Product, int>((ref, productId) async {
  final repository = ref.watch(productsRepositoryProvider);
  return repository.getProductById(productId);
});
