import 'package:flutter/material.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_notifier.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/presentation/providers/products_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de detalle para un producto específico seleccionado.
class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final totalCartCount = ref.watch(cartTotalCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        actions: [
          IconButton(
            tooltip: 'Ver Carrito de Compras',
            icon: Badge.count(
              count: totalCartCount,
              isLabelVisible: totalCartCount > 0,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            onPressed: () => context.push('/cart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productAsync.when(
        data: (product) => _ProductDetailContent(product: product),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar el producto:\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.invalidate(productDetailProvider(productId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductDetailContent extends ConsumerWidget {
  final Product product;

  const _ProductDetailContent({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de cabecera
                Container(
                  width: double.infinity,
                  height: 280,
                  color: Colors.white,
                  child: Image.network(
                    product.thumbnail,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 64,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (product.category.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4F46E5),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF59E0B),
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (product.brand.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Marca: ${product.brand}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (product.discountPercentage > 0) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${product.discountPercentage.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(
                                  color: Color(0xFF166534),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569),
                          height: 1.6,
                        ),
                      ),
                      if (product.stock > 0) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 18,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Disponibles en stock: ${product.stock}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(cartProvider.notifier).addItem(product);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.title} agregado al carrito'),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Ver carrito',
                        onPressed: () => context.push('/cart'),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text(
                  'Agregar al Carrito',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
