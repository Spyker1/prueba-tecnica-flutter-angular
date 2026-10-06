# Prueba Técnica — Desarrollador Jr Flutter (Riverpod) + Angular

Repositorio monorepo que contiene las soluciones prácticas y teóricas para la evaluación técnica de **Desarrollador Jr Flutter (Riverpod) + Angular**, consumiendo la API pública de [DummyJSON](https://dummyjson.com).

---

## Estructura del Repositorio

```text
prueba-tecnica-flutter-angular/
├── flutter_app/                 # Aplicación móvil/web desarrollada en Flutter con Riverpod
├── angular_app/                 # Panel de administración web desarrollado en Angular 17+
├── RESPUESTAS.md                # Respuestas teóricas (Parte 1) y Code Review (Parte 4)
└── README.md                    # Documentación global y decisiones de arquitectura

1. Cómo Ejecutar Cada Proyecto
Requisitos Previos
Flutter SDK: versión 3.19+ (canal stable).

Node.js: versión 18.x o 20.x y npm versión 9+.

Navegador Web: Google Chrome (recomendado para previsualización rápida).

A. Proyecto Flutter (flutter_app/)

Ingresar a la carpeta del proyecto:

cd flutter_app

Instalar dependencias:

flutter pub get

Ejecutar la aplicación:

En Google Chrome (Web):

flutter run -d chrome

Ejecutar pruebas automatizadas:

flutter test

Verificar análisis estático:

flutter analyze

B. Proyecto Angular (angular_app/)

Ingresar a la carpeta del proyecto:

cd angular_app

Instalar dependencias:

npm install

Iniciar el servidor de desarrollo:

npm start

Abre tu navegador en: http://localhost:4200.

Ejecutar pruebas unitarias:

npm test -- --watch=false

Verificar compilación estricta de TypeScript:

npm run build

----------------------------------------------------------------------------------------------------------------------

2. Decisiones de Arquitectura

Flutter (flutter_app/)

1. Arquitectura por Capas (Feature-First):

Capa de Dominio (domain): Entidades inmutables (Product, CartItem) libres de dependencias de frameworks y contratos de repositorio.

Capa de Datos (data): Implementación concreta del repositorio (ProductsRepository), serialización y consumo de la API REST mediante cliente HTTP desacoplado.

Capa de Presentación (presentation): Widgets modulares organizados por pantalla (ProductsScreen, ProductDetailScreen, CartScreen) y Notifiers/Providers de Riverpod.

2. Gestión de Estado Exclusiva con Riverpod (2.x):

productsProvider: FutureProvider.autoDispose para carga asíncrona desacoplada del ciclo de vida de los widgets.

searchQueryProvider + searchResultsProvider: Búsqueda reactiva con debounce de 400 ms para optimizar el tráfico de red y evitar llamadas por cada pulsación de tecla.

productDetailProvider: Provider .family parametrizado por el ID del producto.

cartProvider: NotifierProvider<CartNotifier, List<CartItem>> con mutaciones puramente inmutables (state = [...]).

Separación de accesos: ref.watch estrictamente dentro de métodos build y ref.read únicamente dentro de callbacks de eventos (onPressed, onTap).

3. Justificación de Modelos Inmutables (fromJson manual):

Se optó por serialización manual inmutable con constructores factory fromJson y métodos copyWith.

Motivo: Mantiene el proyecto ligero y legible sin sobrecargar el flujo de trabajo con generación de código externa (build_runner / freezed), permitiendo a su vez validaciones de dominio personalizadas (como el control estricto del límite de stock por producto).

4. Validaciones de Negocio y Persistencia:

Control de stock estricto: El carrito impide agregar más unidades de las existentes en product.stock.

Persistencia local con shared_preferences para conservar el carrito tras recargar la aplicación.

Navegación declarativa mediante go_router.

Angular (angular_app/)

1. Angular 17+ Moderno y Standalone:

Arquitectura sin módulos (standalone: true) que reduce boilerplate y optimiza el tree-shaking.

TypeScript en modo estricto ("strict": true) sin uso de any.

2. Reactividad con Signals y RxJS:

Uso de signal() para el estado local del componente (orders, loading, errorMessage, minTotalFilter).

Uso de computed() para filtros derivados reactivos en tiempo real.

Uso de operadores RxJS (timer, switchMap, catchError) combinados con takeUntilDestroyed() para evitar fugas de memoria (memory leaks).

3. Patrón Contenedor / Presentacional:

Contenedor (OrdersPageComponent): Conecta con OrdersService, orquesta los Signals y gestiona los filtros.

Presentacional (OrderCardComponent): Componente puro con estrategia ChangeDetectionStrategy.OnPush, recibe datos mediante input() y emite eventos mediante output().

4. Diseño y Deseables:

Control Flow nativo moderno (@if, @for con track).

Pipe personalizado DiscountPipe para formateo visual de descuentos y ahorros.

Ruta /orders/:id con Lazy Loading (loadComponent).

3. Paralelos Arquitectónicos: Flutter vs Angular

En ambos proyectos se aplicaron los mismos patrones de diseño y separación de responsabilidades:
