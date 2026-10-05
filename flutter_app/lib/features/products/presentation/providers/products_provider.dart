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

/// Provider asíncrono con DEBOUNCE de 400 ms para consultar la búsqueda sin saturar la API.
///
/// - Si la búsqueda está vacía, retorna los productos base de [productsProvider].
/// - Si el usuario sigue escribiendo antes de transcurrir 400 ms, Riverpod cancela
///   la ejecución previa y reinicia el temporizador automáticamente.
final searchResultsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();

  // Si no hay consulta, expone el catálogo base
  if (query.isEmpty) {
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

  final repository = ref.watch(productsRepositoryProvider);
  return repository.searchProducts(query);
});

/// Provider para consultar el detalle de un producto mediante su identificador.
/// Consume GET /products/{id}
final productDetailProvider =
    FutureProvider.autoDispose.family<Product, int>((ref, productId) async {
  final repository = ref.watch(productsRepositoryProvider);
  return repository.getProductById(productId);
});
