import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier que gestiona de manera estrictamente inmutable el estado de los elementos del carrito.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  /// Agrega un producto al carrito o incrementa su cantidad si ya existe.
  void addItem(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final updatedItem = state[index].copyWith(
        quantity: state[index].quantity + 1,
      );
      final updatedList = List<CartItem>.from(state);
      updatedList[index] = updatedItem;
      state = List.unmodifiable(updatedList);
    } else {
      state = List.unmodifiable(
        [...state, CartItem(product: product, quantity: 1)],
      );
    }
  }

  /// Remueve completamente un producto del carrito según su identificador.
  void removeItem(int productId) {
    state = List.unmodifiable(
      state.where((item) => item.product.id != productId).toList(),
    );
  }

  /// Actualiza la cantidad de un ítem en el carrito. Si cantidad <= 0, lo elimina.
  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final updatedItem = state[index].copyWith(quantity: quantity);
      final updatedList = List<CartItem>.from(state);
      updatedList[index] = updatedItem;
      state = List.unmodifiable(updatedList);
    }
  }

  /// Vacía por completo el carrito de compras.
  void clearCart() {
    state = const [];
  }
}

/// Provider del carrito de compras.
final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

/// Provider reactivo derivado: cantidad total de items acumulados.
final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold<int>(0, (sum, item) => sum + item.quantity);
});

/// Provider reactivo derivado: suma total monetaria de los productos.
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold<double>(0.0, (sum, item) => sum + item.subtotal);
});

/// Alias de compatibilidad
final cartTotalCountProvider = cartCountProvider;
final cartTotalPriceProvider = cartTotalProvider;
