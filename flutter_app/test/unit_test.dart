import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_notifier.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product Model Tests', () {
    test('Product.fromJson parses valid JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'iPhone 9',
        'description': 'An apple mobile which is nothing like apple',
        'price': 549,
        'rating': 4.69,
        'thumbnail': 'https://i.dummyjson.com/data/products/1/thumbnail.jpg',
        'category': 'smartphones',
        'stock': 94,
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'iPhone 9');
      expect(product.price, 549.0);
      expect(product.rating, 4.69);
      expect(product.stock, 94);
      expect(product.category, 'smartphones');
    });

    test('Product.toJson converts model back to map', () {
      const product = Product(
        id: 2,
        title: 'Laptop',
        description: 'High performance laptop',
        price: 1200.0,
        rating: 4.8,
        thumbnail: 'https://example.com/laptop.jpg',
        category: 'laptops',
        stock: 15,
      );

      final json = product.toJson();

      expect(json['id'], 2);
      expect(json['title'], 'Laptop');
      expect(json['price'], 1200.0);
    });
  });

  group('CartItem & CartNotifier Tests', () {
    const testProduct1 = Product(
      id: 10,
      title: 'Mouse inalámbrico',
      description: 'Mouse ergonómico',
      price: 25.50,
      rating: 4.5,
      thumbnail: 'https://example.com/mouse.jpg',
      category: 'accessories',
      stock: 50,
    );

    const testProduct2 = Product(
      id: 20,
      title: 'Teclado mecánico',
      description: 'Teclado RGB',
      price: 100.0,
      rating: 4.9,
      thumbnail: 'https://example.com/keyboard.jpg',
      category: 'accessories',
      stock: 20,
    );

    test('CartItem calculates subtotal accurately', () {
      const item = CartItem(product: testProduct1, quantity: 3);
      expect(item.subtotal, 76.50);
    });

    test('CartNotifier adds, updates, and removes items immutably', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartProvider.notifier);

      // Initially empty
      expect(container.read(cartProvider), isEmpty);
      expect(container.read(cartCountProvider), 0);
      expect(container.read(cartTotalProvider), 0.0);

      // Add item 1
      notifier.addItem(testProduct1);
      expect(container.read(cartProvider).length, 1);
      expect(container.read(cartCountProvider), 1);
      expect(container.read(cartTotalProvider), 25.50);

      // Add item 1 again (should increment quantity)
      notifier.addItem(testProduct1);
      expect(container.read(cartProvider).length, 1);
      expect(container.read(cartCountProvider), 2);
      expect(container.read(cartTotalProvider), 51.0);

      // Add item 2
      notifier.addItem(testProduct2);
      expect(container.read(cartProvider).length, 2);
      expect(container.read(cartCountProvider), 3);
      expect(container.read(cartTotalProvider), 151.0);

      // Update quantity of item 1
      notifier.updateQuantity(testProduct1.id, 5);
      expect(container.read(cartCountProvider), 6);
      expect(container.read(cartTotalProvider), 227.50);

      // Update quantity to 0 removes the item
      notifier.updateQuantity(testProduct1.id, 0);
      expect(container.read(cartProvider).length, 1);
      expect(container.read(cartCountProvider), 1);
      expect(container.read(cartTotalProvider), 100.0);

      // Remove item 2
      notifier.removeItem(testProduct2.id);
      expect(container.read(cartProvider), isEmpty);
      expect(container.read(cartCountProvider), 0);
      expect(container.read(cartTotalProvider), 0.0);
    });
  });
}
