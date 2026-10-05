import 'package:flutter_app/features/products/domain/product.dart';

/// Modelo inmutable de Dominio que representa un elemento en el carrito de compras.
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Getter para calcular el subtotal del artículo según su cantidad.
  double get subtotal => product.price * quantity;

  /// Alias de conveniencia para total por ítem.
  double get totalPrice => subtotal;

  /// Retorna una nueva instancia inmutable con campos modificados.
  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          product == other.product &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(product, quantity);
}
