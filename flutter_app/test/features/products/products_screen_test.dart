import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/features/products/data/products_repository.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/presentation/products_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_app/features/products/domain/paginated_products_response.dart';

/// Repositorio simulado (Fake) para pruebas de widgets sin acceso a red.
class FakeProductsRepository extends ProductsRepository {
  final List<Product> fakeProducts;
  final Completer<PaginatedProductsResponse>? loadingCompleter;

  FakeProductsRepository({
    this.fakeProducts = const [],
    this.loadingCompleter,
  }) : super(client: http.Client());

  @override
  Future<PaginatedProductsResponse> getProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    if (loadingCompleter != null) {
      return loadingCompleter!.future;
    }
    final paged = fakeProducts.skip(skip).take(limit).toList();
    return PaginatedProductsResponse(
      products: paged,
      total: fakeProducts.length,
      skip: skip,
      limit: limit,
    );
  }

  @override
  Future<PaginatedProductsResponse> searchProducts(
    String query, {
    int limit = 20,
    int skip = 0,
  }) async {
    final filtered = fakeProducts
        .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final paged = filtered.skip(skip).take(limit).toList();
    return PaginatedProductsResponse(
      products: paged,
      total: filtered.length,
      skip: skip,
      limit: limit,
    );
  }

  @override
  Future<Product> getProductById(int id) async {
    return fakeProducts.firstWhere((p) => p.id == id);
  }

  @override
  Future<List<String>> getCategories() async {
    return fakeProducts.map((p) => p.category).toSet().toList();
  }

  @override
  Future<PaginatedProductsResponse> getProductsByCategory(
    String category, {
    int limit = 20,
    int skip = 0,
  }) async {
    final filtered = fakeProducts
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
    final paged = filtered.skip(skip).take(limit).toList();
    return PaginatedProductsResponse(
      products: paged,
      total: filtered.length,
      skip: skip,
      limit: limit,
    );
  }
}

/// Byte array de imagen PNG 1x1 transparente para resolver Image.network en tests
const List<int> _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_kTransparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  const testProducts = [
    Product(
      id: 101,
      title: 'Laptop Ultradelgada',
      description: 'Potente procesador y pantalla 4K',
      price: 999.99,
      rating: 4.85,
      thumbnail: 'https://example.com/laptop.jpg',
      category: 'laptops',
      stock: 12,
    ),
    Product(
      id: 102,
      title: 'Teclado Mecánico RGB',
      description: 'Switches táctiles y retroiluminación',
      price: 89.50,
      rating: 4.60,
      thumbnail: 'https://example.com/keyboard.jpg',
      category: 'accessories',
      stock: 30,
    ),
  ];

  Widget buildTestableWidget(ProductsRepository repository) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ProductsScreen(),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        productsRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }

  testWidgets(
    'ProductsScreen muestra CircularProgressIndicator mientras carga y lista los productos al resolver',
    (WidgetTester tester) async {
      final completer = Completer<PaginatedProductsResponse>();
      final fakeRepository = FakeProductsRepository(
        loadingCompleter: completer,
        fakeProducts: testProducts,
      );

      // Renderiza la pantalla inicialmente con la petición pendiente
      await tester.pumpWidget(buildTestableWidget(fakeRepository));

      // 1. Comprueba que se renderiza el estado de carga
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Laptop Ultradelgada'), findsNothing);

      // 2. Resuelve la petición asíncrona de datos
      completer.complete(
        PaginatedProductsResponse(
          products: testProducts,
          total: testProducts.length,
        ),
      );
      await tester.pumpAndSettle();

      // 3. Comprueba que el indicador de carga desaparece y se muestran los productos en la lista
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Laptop Ultradelgada'), findsOneWidget);
      expect(find.text('\$999.99'), findsOneWidget);
      expect(find.text('Teclado Mecánico RGB'), findsOneWidget);
      expect(find.text('\$89.50'), findsOneWidget);
    },
  );

  testWidgets(
    'ProductsScreen muestra botón de alternar tema y chips de categorías',
    (WidgetTester tester) async {
      final fakeRepository = FakeProductsRepository(fakeProducts: testProducts);
      await tester.pumpWidget(buildTestableWidget(fakeRepository));
      await tester.pumpAndSettle();

      // Verifica botón de modo oscuro en el AppBar
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

      // Verifica presencia del chip "Todas" y categorías disponibles
      expect(find.widgetWithText(FilterChip, 'Todas'), findsOneWidget);
      expect(find.text('Laptops'), findsOneWidget);
      expect(find.text('Accessories'), findsOneWidget);

      // Toca el botón de tema para alternar
      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pumpAndSettle();

      // Debe haber cambiado al icono de modo claro
      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    },
  );

  testWidgets(
    'ProductsScreen filtra reactivamente al pulsar un FilterChip de categoría',
    (WidgetTester tester) async {
      final fakeRepository = FakeProductsRepository(fakeProducts: testProducts);
      await tester.pumpWidget(buildTestableWidget(fakeRepository));
      await tester.pumpAndSettle();

      // Inicialmente se muestran ambos productos
      expect(find.text('Laptop Ultradelgada'), findsOneWidget);
      expect(find.text('Teclado Mecánico RGB'), findsOneWidget);

      // Pulsa el chip de categoría 'Laptops'
      await tester.tap(find.text('Laptops'));
      await tester.pumpAndSettle();

      // Ahora solo debe mostrar la laptop
      expect(find.text('Laptop Ultradelgada'), findsOneWidget);
      expect(find.text('Teclado Mecánico RGB'), findsNothing);

      // Pulsa el chip 'Todas' para restablecer
      await tester.tap(find.text('Todas'));
      await tester.pumpAndSettle();

      expect(find.text('Laptop Ultradelgada'), findsOneWidget);
      expect(find.text('Teclado Mecánico RGB'), findsOneWidget);
    },
  );

  testWidgets(
    'ProductsScreen carga la siguiente página al hacer scroll hacia el final',
    (WidgetTester tester) async {
      final manyProducts = List.generate(
        25,
        (i) => Product(
          id: i + 1,
          title: 'Producto $i',
          description: 'Desc $i',
          price: 10.0 + i,
          rating: 4.5,
          thumbnail: 'https://example.com/p$i.jpg',
          category: 'general',
          stock: 10,
        ),
      );

      final fakeRepository = FakeProductsRepository(fakeProducts: manyProducts);
      await tester.pumpWidget(buildTestableWidget(fakeRepository));
      await tester.pumpAndSettle();

      // Verifica que se cargaron los primeros 20 productos y hasMore está activo
      expect(find.text('Producto 0'), findsOneWidget);
      expect(find.text('Producto 19'), findsNothing); // Aún no en viewport

      // Realiza scroll hacia abajo para activar el listener de scroll
      final verticalListFinder = find.byWidgetPredicate(
        (w) => w is ListView && w.scrollDirection == Axis.vertical,
      );
      await tester.scrollUntilVisible(
        find.text('Producto 24'),
        500,
        scrollable: find.descendant(
          of: verticalListFinder,
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();

      // Tras el scroll y la carga de la página 2, Producto 24 es renderizado
      expect(find.text('Producto 24'), findsOneWidget);
    },
  );
}
