import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier que gestiona de manera inmutable el estado de los elementos del carrito.
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

  /// Reduce en 1 la cantidad del producto; si llega a 0, se elimina del carrito.
  void decreaseItem(int productId) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (state[index].quantity > 1) {
        final updatedItem = state[index].copyWith(
          quantity: state[index].quantity - 1,
        );
        final updatedList = List<CartItem>.from(state);
        updatedList[index] = updatedItem;
        state = List.unmodifiable(updatedList);
      } else {
        removeItem(productId);
      }
    }
  }

  /// Remueve completamente un producto del carrito.
  void removeItem(int productId) {
    state = List.unmodifiable(
      state.where((item) => item.product.id != productId).toList(),
    );
  }

  /// Vacía por completo el carrito de compras.
  void clearCart() {
    state = const [];
  }
}

/// Proveedor del carrito de compras.
final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

/// Proveedor derivado con la cantidad total de artículos en el carrito.
final cartTotalCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold<int>(0, (sum, item) => sum + item.quantity);
});

/// Proveedor derivado con el importe total acumulado en el carrito.
final cartTotalPriceProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
});
