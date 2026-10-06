import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/cart/presentation/cart_screen.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_notifier.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCartNotifier extends CartNotifier {
  final List<CartItem> initialItems;

  _FakeCartNotifier(this.initialItems);

  @override
  List<CartItem> build() => initialItems;
}

void main() {
  const testProduct = Product(
    id: 1,
    title: 'Producto de Prueba',
    description: 'Descripción de prueba',
    price: 50.0,
    rating: 4.5,
    thumbnail: 'https://example.com/test.jpg',
    category: 'demo',
    stock: 2, // Stock limitado a 2 unidades
  );

  testWidgets(
    'CartScreen desactiva botón + cuando item.quantity >= product.stock y muestra resumen estilizado',
    (WidgetTester tester) async {
      // Carrito inicial con 2 unidades (máximo stock alcanzado)
      final initialCart = [
        const CartItem(product: testProduct, quantity: 2),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartProvider.overrideWith(() => _FakeCartNotifier(initialCart)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CartScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verifica renderizado del item y total
      expect(find.text('Producto de Prueba'), findsOneWidget);
      expect(find.text('\$50.00 c/u'), findsOneWidget);
      expect(find.text('Subtotal: \$100.00'), findsOneWidget);
      expect(find.text('Máx stock'), findsOneWidget);

      // 2. Verifica desglose claro del total a pagar
      expect(find.text('Total a Pagar'), findsOneWidget);
      expect(find.text('\$100.00'), findsNWidgets(2)); // Subtotal e Importe Total
      expect(find.text('Gratis'), findsOneWidget);
      expect(find.text('Proceder al Pago'), findsOneWidget);

      // 3. Verifica que el botón + está deshabilitado porque quantity == stock (2 == 2)
      final addButtonFinder = find.byWidgetPredicate(
        (widget) =>
            widget is IconButton &&
            widget.tooltip?.contains('Stock máximo alcanzado') == true,
      );
      expect(addButtonFinder, findsOneWidget);

      final iconButton = tester.widget<IconButton>(addButtonFinder);
      expect(iconButton.onPressed, isNull); // Deshabilitado
    },
  );
}
