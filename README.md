# Prueba Técnica — Desarrollador Jr Flutter (Riverpod) + Angular

Repositorio monorepo que contiene la solución integral para la prueba técnica de **Desarrollador Jr Flutter (Riverpod) + Angular**, consumiendo la API pública de [DummyJSON](https://dummyjson.com).

---

## Estructura del Repositorio

```text
prueba-tecnica-flutter-angular/
├── flutter_app/                 # Aplicación Flutter con Riverpod (Catálogo, Búsqueda, Carrito)
├── angular_app/                 # Dashboard web en Angular 17+ (Gestión y Detalle de Pedidos)
├── RESPUESTAS.md                # Respuestas teóricas (Parte 1) y Code Review (Parte 4)
└── README.md                    # Documentación global, arquitectura y guía de ejecución
```

---

## 1. Guía de Ejecución

### Requisitos del Sistema
* **Flutter SDK:** versión 3.19+ (canal stable).
* **Node.js:** versión 18.x o 20.x y **npm** 9+.
* **Navegador Web:** Google Chrome (recomendado para previsualización inmediata).

---

### A. Proyecto Flutter (`flutter_app/`)

1. **Navegar a la carpeta:**
   ```bash
   cd flutter_app
   ```

2. **Descargar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación:**
   * En **Google Chrome (Web):**
     ```bash
     flutter run -d chrome
     ```
   * En **Windows Desktop:**
     ```bash
     flutter run -d windows
     ```
   * En emulador Android o dispositivo físico:
     ```bash
     flutter run
     ```

4. **Correr pruebas automáticas:**
   ```bash
   flutter test
   ```

5. **Comprobar análisis estático:**
   ```bash
   flutter analyze
   ```

---

### B. Proyecto Angular (`angular_app/`)

1. **Navegar a la carpeta:**
   ```bash
   cd angular_app
   ```

2. **Instalar dependencias:**
   ```bash
   npm install
   ```

3. **Iniciar el servidor local:**
   ```bash
   npm start
   ```
   Abrir en el navegador: [http://localhost:4200](http://localhost:4200).

4. **Correr pruebas unitarias:**
   ```bash
   npm test -- --watch=false
   ```

5. **Validar compilación en modo estricto:**
   ```bash
   npm run build
   ```

---

## 2. Decisiones de Arquitectura y Buenas Prácticas

### Flutter (`flutter_app/`)

1. **Arquitectura por Capas Limpia (Feature-Driven):**
   * **Capa de Dominio (`domain`):** Entidades inmutables (`Product`, `CartItem`) completamente desacopladas de frameworks y librerías externas.
   * **Capa de Datos (`data`):** Repositorio `ProductsRepository` que aísla las peticiones HTTP (`http.Client`), maneja la deserialización y controla la paginación de la API.
   * **Capa de Presentación (`presentation`):** Widgets modulares organizados por pantalla (`ProductsScreen`, `ProductDetailScreen`, `CartScreen`), orquestados por Notifiers y Providers de Riverpod.

2. **Gestión de Estado Reactiva con Riverpod (2.x):**
   * **Listado con Paginación Infinita:** Implementado con `AsyncNotifierProvider` (`PaginatedProductsNotifier`), controlando carga por lotes (`skip` y `limit`), estados de carga inicial, error con reintento (`ref.invalidate`) y spinner de scroll al pie.
   * **Búsqueda Reactiva con Debounce:** Provista con un retardo de 400 ms para optimizar el consumo de red y evitar llamadas por pulsación de tecla.
   * **Filtro por Categorías:** Consumo dinámico de `GET /products/categories` con chips horizontales interactivos.
   * **Detalle con `.family`:** `productDetailProvider` parametrizado por el ID del producto.
   * **Carrito Inmutable y Reactivo:** `NotifierProvider<CartNotifier, List<CartItem>>` con mutaciones puras (`state = [...]`), cálculo dinámico de total y contador global en `AppBar`.
   * **Tema Dinámico Claro/Oscuro:** `themeModeProvider` que conmuta entre `ThemeMode.light` y `ThemeMode.dark` con contraste verificado en `ColorScheme`.

3. **Validaciones de Negocio:**
   * **Control de Stock Estricto:** Validación en el Notifier y deshabilitación de controles `+` cuando `item.quantity >= product.stock`.
   * **Persistencia Local:** Carrito persistido con `shared_preferences` para conservar la compra tras recargas.

4. **Justificación de Modelos Inmutables (`fromJson` manual):**
   * Se eligió serialización manual inmutable con constructores factory `fromJson` y métodos `copyWith`.
   * **Justificación:** Mantiene el proyecto ligero y sin dependencias pesadas de generación de código (`build_runner` / `freezed`), permitiendo a la vez validaciones de datos personalizadas en tiempo de parseo.

---

### Angular (`angular_app/`)

1. **Angular 17+ Moderno y Standalone:**
   * Arquitectura moderna basada en componentes standalone (`standalone: true`), eliminando la sobrecarga de `NgModule`.
   * TypeScript configurado en modo estricto (`"strict": true`) sin uso de `any`.

2. **Reactividad con Signals:**
   * Estado del componente gestionado con `signal()` (`orders`, `loading`, `errorMessage`, `minTotalFilter`).
   * Filtrado derivado síncrono y de alto rendimiento mediante `computed()`.
   * Prevención estricta de fugas de memoria (*memory leaks*) mediante `takeUntilDestroyed()`.

3. **Patrón Contenedor y Presentacional:**
   * **Contenedor (`OrdersPageComponent`):** Conecta con `OrdersService`, gestiona Signals y orquesta los eventos.
   * **Presentacional (`OrderCardComponent`):** Componente puro con estrategia `ChangeDetectionStrategy.OnPush`, entrada tipada con `input()` y salida de eventos con `output()`.

4. **Deseables Implementados:**
   * Nuevo Control Flow nativo (`@if`, `@for (order of filteredOrders(); track order.id)`).
   * Pipe personalizado `DiscountPipe` (`discount`) para formato de descuentos y montos ahorrados.
   * Ruta `/orders/:id` con *Lazy Loading* (`loadComponent`).

---

## 3. Paralelos Arquitectónicos: Flutter vs Angular

En ambos proyectos se aplicaron conceptos arquitectónicos equivalentes:

| Concepto Arquitectónico | Implementación en Flutter (Dart) | Implementación en Angular (TypeScript) |
| :--- | :--- | :--- |
| **Abstracción de Datos** | `ProductsRepository` inyectado vía Riverpod | `OrdersService` con `@Injectable({ providedIn: 'root' })` |
| **Cliente de Red** | `http.Client` desacoplado | `HttpClient` provisto mediante `provideHttpClient()` |
| **Estado Reactivo** | Providers de Riverpod (`Notifier`, `AsyncNotifier`) | Signals (`signal()`, `computed()`) |
| **Componentes Puros** | `StatelessWidget` con propiedades `final` | Componente Standalone con `input()` y `OnPush` |
| **Comunicación Hijo-Padre** | Callbacks tipados (`VoidCallback`, `Function(T)`) | Salidas tipadas con `output<T>()` |
| **Limpieza de Recursos** | Modificador `autoDispose` de Riverpod | Operador `takeUntilDestroyed()` en inyección |
| **Tipado Fuerte** | Clases inmutables con `fromJson` | Interfaces de TypeScript estrictas |

---

## 4. Qué Quedó Pendiente y Qué Mejoraría con Más Tiempo

1. **Pruebas de Integración End-to-End (E2E):**
   * En Flutter: Crear pruebas con `integration_test` o Patrol para validar el flujo completo *Búsqueda → Detalle → Carrito → Modificación de cantidad*.
   * En Angular: Configurar pruebas E2E con Cypress o Playwright simulando la interacción administrativa.

2. **Manejo de Errores con Tipo Result / Either:**
   * Reemplazar las excepciones convencionales por una clase funcional tipada `Result<T, Failure>` (estilo `fpdart`), evitando bloques `try-catch` y forzando la evaluación exhaustiva de fallos en la capa de presentación.

3. **Virtual Scrolling en Angular:**
   * Integrar `@angular/cdk/scrolling` para renderizado virtual eficiente en listas masivas de carritos.

4. **Internacionalización (i18n):**
   * Implementar soporte multiidioma con `flutter_localizations` y `@angular/localize`.
