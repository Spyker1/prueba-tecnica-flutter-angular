import 'dart:async';
import 'package:flutter_app/features/products/data/products_repository.dart';
import 'package:flutter_app/features/products/domain/paginated_products_response.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier con soporte de paginación infinita y reactividad ante filtros y búsqueda.
class PaginatedProductsNotifier
    extends AutoDisposeAsyncNotifier<List<Product>> {
  static const int _pageSize = 20;

  bool hasMore = true;
  bool isLoadingMore = false;
  int _total = 0;

  @override
  FutureOr<List<Product>> build() async {
    // Al reconstruirse por cambios en filtros o búsqueda, reinicia paginación a skip: 0
    hasMore = true;
    isLoadingMore = false;
    _total = 0;

    final query = ref.watch(searchQueryProvider).trim();
    final category = ref.watch(selectedCategoryProvider);
    final repository = ref.watch(productsRepositoryProvider);

    final PaginatedProductsResponse response;

    if (query.isNotEmpty) {
      // Mecanismo de debounce de 400 ms si es búsqueda textual
      var isDisposed = false;
      ref.onDispose(() => isDisposed = true);
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (isDisposed) {
        return Completer<List<Product>>().future;
      }
      response = await repository.searchProducts(
        query,
        limit: _pageSize,
        skip: 0,
      );
    } else if (category != null && category.isNotEmpty) {
      response = await repository.getProductsByCategory(
        category,
        limit: _pageSize,
        skip: 0,
      );
    } else {
      response = await repository.getProducts(limit: _pageSize, skip: 0);
    }

    _total = response.total;
    if (response.products.length < _pageSize ||
        response.products.length >= _total) {
      hasMore = false;
    }

    return response.products;
  }

  /// Carga la siguiente página de productos mediante scroll infinito.
  Future<void> fetchNextPage() async {
    if (!hasMore || isLoadingMore) return;
    final currentList = state.value;
    if (currentList == null) return;

    isLoadingMore = true;
    try {
      final repository = ref.read(productsRepositoryProvider);
      final query = ref.read(searchQueryProvider).trim();
      final category = ref.read(selectedCategoryProvider);

      final PaginatedProductsResponse response;
      if (query.isNotEmpty) {
        response = await repository.searchProducts(
          query,
          limit: _pageSize,
          skip: currentList.length,
        );
      } else if (category != null && category.isNotEmpty) {
        response = await repository.getProductsByCategory(
          category,
          limit: _pageSize,
          skip: currentList.length,
        );
      } else {
        response = await repository.getProducts(
          limit: _pageSize,
          skip: currentList.length,
        );
      }

      final nuevosProductos = response.products;
      if (nuevosProductos.isEmpty ||
          nuevosProductos.length < _pageSize ||
          (currentList.length + nuevosProductos.length) >= response.total) {
        hasMore = false;
      }

      state = AsyncData([...currentList, ...nuevosProductos]);
    } catch (_) {
      // Mantiene los elementos cargados en caso de fallo momentáneo de red
    } finally {
      isLoadingMore = false;
    }
  }
}

/// Provider paginado de productos gestionado por AsyncNotifier.
final paginatedProductsProvider =
    AsyncNotifierProvider.autoDispose<PaginatedProductsNotifier, List<Product>>(
  PaginatedProductsNotifier.new,
);

/// Aliases para compatibilidad con código existente
final productsProvider = paginatedProductsProvider;
final searchResultsProvider = paginatedProductsProvider;

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

/// Provider para consultar el detalle de un producto mediante su identificador.
/// Consume GET /products/{id}
final productDetailProvider =
    FutureProvider.autoDispose.family<Product, int>((ref, productId) async {
  final repository = ref.watch(productsRepositoryProvider);
  return repository.getProductById(productId);
});
