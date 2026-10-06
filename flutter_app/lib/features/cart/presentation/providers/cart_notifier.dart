import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier que gestiona de manera estrictamente inmutable el estado de los elementos del carrito.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  /// Agrega un producto al carrito o incrementa su cantidad si ya existe,
  /// validando estrictamente que nunca supere el stock disponible del producto.
  /// Retorna `true` si se agregó con éxito o `false` si se alcanzó el stock máximo.
  bool addItem(Product product) {
    if (product.stock <= 0) {
      return false;
    }

    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final currentQuantity = state[index].quantity;
      if (currentQuantity >= product.stock) {
        return false;
      }
      final updatedItem = state[index].copyWith(
        quantity: currentQuantity + 1,
      );
      final updatedList = List<CartItem>.from(state);
      updatedList[index] = updatedItem;
      state = List.unmodifiable(updatedList);
      return true;
    } else {
      state = List.unmodifiable(
        [...state, CartItem(product: product, quantity: 1)],
      );
      return true;
    }
  }

  /// Remueve completamente un producto del carrito según su identificador.
  void removeItem(int productId) {
    state = List.unmodifiable(
      state.where((item) => item.product.id != productId).toList(),
    );
  }

  /// Actualiza la cantidad de un ítem en el carrito validando que nunca
  /// supere `product.stock`. Si cantidad <= 0, lo elimina.
  /// Retorna `true` si la cantidad es válida o `false` si supera el stock disponible.
  bool updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return true;
    }

    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final maxStock = state[index].product.stock;
      if (quantity > maxStock) {
        if (state[index].quantity != maxStock) {
          final updatedItem = state[index].copyWith(quantity: maxStock);
          final updatedList = List<CartItem>.from(state);
          updatedList[index] = updatedItem;
          state = List.unmodifiable(updatedList);
        }
        return false;
      }

      final updatedItem = state[index].copyWith(quantity: quantity);
      final updatedList = List<CartItem>.from(state);
      updatedList[index] = updatedItem;
      state = List.unmodifiable(updatedList);
      return true;
    }
    return false;
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
