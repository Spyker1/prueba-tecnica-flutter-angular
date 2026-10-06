import 'package:flutter_app/features/cart/presentation/providers/cart_notifier.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const productA = Product(
    id: 1,
    title: 'Auriculares Bluetooth',
    description: 'Auriculares con cancelación activa de ruido',
    price: 80.0,
    rating: 4.7,
    thumbnail: 'https://example.com/headphones.jpg',
    category: 'audio',
    stock: 25,
  );

  const productB = Product(
    id: 2,
    title: 'Mouse Gamer',
    description: 'Mouse óptico con sensor de alta precisión',
    price: 45.0,
    rating: 4.4,
    thumbnail: 'https://example.com/mouse.jpg',
    category: 'gaming',
    stock: 15,
  );

  group('CartNotifier Unit Tests', () {
    test(
      'Test 1: Agregar un producto nuevo crea un CartItem con cantidad 1 y recalcula el total',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(cartProvider.notifier);

        // Estado inicial vacío
        expect(container.read(cartProvider), isEmpty);
        expect(container.read(cartCountProvider), 0);
        expect(container.read(cartTotalProvider), 0.0);

        // Acción: agregar nuevo producto
        notifier.addItem(productA);

        final cart = container.read(cartProvider);
        expect(cart.length, 1);
        expect(cart.first.product.id, productA.id);
        expect(cart.first.quantity, 1);
        expect(cart.first.subtotal, 80.0);
        expect(container.read(cartCountProvider), 1);
        expect(container.read(cartTotalProvider), 80.0);
      },
    );

    test(
      'Test 2: Agregar el mismo producto incrementa la cantidad sin duplicar el item',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(cartProvider.notifier);

        // Agregar producto por primera vez
        notifier.addItem(productA);
        expect(container.read(cartProvider).length, 1);
        expect(container.read(cartProvider).first.quantity, 1);
        expect(container.read(cartTotalProvider), 80.0);

        // Agregar el mismo producto por segunda vez
        notifier.addItem(productA);

        final cart = container.read(cartProvider);
        expect(
          cart.length,
          1,
          reason: 'No debe duplicar el elemento en la lista, sino incrementar cantidad',
        );
        expect(cart.first.quantity, 2);
        expect(cart.first.subtotal, 160.0);
        expect(container.read(cartCountProvider), 2);
        expect(container.read(cartTotalProvider), 160.0);
      },
    );

    test(
      'Test 3: Modificar cantidad o quitar un producto actualiza el total e inmutabilidad de la lista',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(cartProvider.notifier);

        notifier.addItem(productA); // $80 x 1
        notifier.addItem(productB); // $45 x 1

        final stateBeforeUpdate = container.read(cartProvider);
        expect(stateBeforeUpdate.length, 2);
        expect(container.read(cartCountProvider), 2);
        expect(container.read(cartTotalProvider), 125.0); // 80 + 45

        // Modificar cantidad del producto A a 3 unidades
        notifier.updateQuantity(productA.id, 3);

        final stateAfterUpdate = container.read(cartProvider);

        // Verificar inmutabilidad: no debe ser la misma instancia en memoria
        expect(
          identical(stateBeforeUpdate, stateAfterUpdate),
          isFalse,
          reason: 'La lista de estado debe ser inmutable y emitir una nueva referencia',
        );

        final itemA = stateAfterUpdate.firstWhere(
          (item) => item.product.id == productA.id,
        );
        expect(itemA.quantity, 3);
        expect(itemA.subtotal, 240.0); // 80 * 3
        expect(container.read(cartCountProvider), 4); // 3 de A + 1 de B
        expect(container.read(cartTotalProvider), 285.0); // 240 + 45

        // Quitar producto A del carrito
        notifier.removeItem(productA.id);

        final stateAfterRemove = container.read(cartProvider);
        expect(
          identical(stateAfterUpdate, stateAfterRemove),
          isFalse,
          reason: 'La remoción debe producir una nueva lista inmutable',
        );
        expect(stateAfterRemove.length, 1);
        expect(
          stateAfterRemove.any((item) => item.product.id == productA.id),
          isFalse,
        );
        expect(container.read(cartCountProvider), 1);
        expect(container.read(cartTotalProvider), 45.0);
      },
    );

    test(
      'Test 4: addItem respeta el stock máximo y rechaza agregar más unidades cuando se alcanza',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(cartProvider.notifier);
        const limitedProduct = Product(
          id: 99,
          title: 'Producto Limitado',
          description: 'Solo 2 disponibles',
          price: 50.0,
          rating: 4.0,
          thumbnail: 'https://example.com/item.jpg',
          category: 'demo',
          stock: 2,
        );

        // 1. Primer agregado -> permitido
        final addedFirst = notifier.addItem(limitedProduct);
        expect(addedFirst, isTrue);
        expect(container.read(cartProvider).first.quantity, 1);

        // 2. Segundo agregado -> permitido (alcanza el límite de 2)
        final addedSecond = notifier.addItem(limitedProduct);
        expect(addedSecond, isTrue);
        expect(container.read(cartProvider).first.quantity, 2);

        // 3. Tercer agregado -> bloqueado porque quantity >= stock
        final addedThird = notifier.addItem(limitedProduct);
        expect(addedThird, isFalse);
        expect(container.read(cartProvider).first.quantity, 2);
        expect(container.read(cartTotalProvider), 100.0);
      },
    );

    test(
      'Test 5: updateQuantity no permite superar product.stock y producto con stock 0 no se agrega',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(cartProvider.notifier);

        const outOfStockProduct = Product(
          id: 100,
          title: 'Producto Agotado',
          description: 'Sin inventario',
          price: 20.0,
          rating: 3.5,
          thumbnail: 'https://example.com/zero.jpg',
          category: 'demo',
          stock: 0,
        );

        // Intento de agregar producto sin stock
        final addedOutOfStock = notifier.addItem(outOfStockProduct);
        expect(addedOutOfStock, isFalse);
        expect(container.read(cartProvider), isEmpty);

        // Con producto B (stock: 15)
        notifier.addItem(productB);
        expect(container.read(cartProvider).first.quantity, 1);

        // Intentar actualizar cantidad a 20 (supera stock de 15)
        final updateExceeded = notifier.updateQuantity(productB.id, 20);
        expect(updateExceeded, isFalse);
        // Debe acotar la cantidad al stock máximo disponible (15) y no 20
        expect(container.read(cartProvider).first.quantity, 15);
        expect(container.read(cartTotalProvider), 15 * 45.0);
      },
    );
  });
}
