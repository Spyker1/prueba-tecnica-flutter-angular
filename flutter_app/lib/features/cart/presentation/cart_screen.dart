import 'package:flutter/material.dart';
import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla que muestra el carrito de compras, controles de cantidad y checkout simulado.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito de Compras'),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              tooltip: 'Vaciar Carrito',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                _showClearConfirmationDialog(context, ref);
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cartItems.isEmpty
          ? const _EmptyCartView()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _CartItemTile(item: item);
                    },
                  ),
                ),
                _CartSummarySection(
                  totalPrice: totalPrice,
                  onCheckout: () {
                    ref.read(cartProvider.notifier).clearCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Compra simulada procesada con éxito!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    context.go('/');
                  },
                ),
              ],
            ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Vaciar carrito?'),
        content: const Text(
          'Se eliminarán todos los artículos agregados a tu lista de compra.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.of(ctx).pop();
            },
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 70,
                height: 70,
                color: const Color(0xFFF1F5F9),
                child: Image.network(
                  item.product.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)} c/u',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Disminuir cantidad',
                  icon: const Icon(Icons.remove_circle_outline, size: 22),
                  color: const Color(0xFF64748B),
                  onPressed: () {
                    ref.read(cartProvider.notifier).updateQuantity(
                          item.product.id,
                          item.quantity - 1,
                        );
                  },
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  tooltip: 'Aumentar cantidad',
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  color: const Color(0xFF4F46E5),
                  onPressed: () {
                    ref.read(cartProvider.notifier).updateQuantity(
                          item.product.id,
                          item.quantity + 1,
                        );
                  },
                ),
                IconButton(
                  tooltip: 'Eliminar del carrito',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: const Color(0xFFEF4444),
                  onPressed: () {
                    ref.read(cartProvider.notifier).removeItem(item.product.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.remove_shopping_cart_outlined,
              size: 72,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tu carrito está vacío',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explora nuestro catálogo y agrega tus productos favoritos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Ver Catálogo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummarySection extends StatelessWidget {
  final double totalPrice;
  final VoidCallback onCheckout;

  const _CartSummarySection({
    required this.totalPrice,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a Pagar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: totalPrice > 0 ? onCheckout : null,
                icon: const Icon(Icons.payment_rounded),
                label: const Text(
                  'Proceder al Pago',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
