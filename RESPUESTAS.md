Respuestas a la Prueba Técnica — Desarrollador Jr Flutter (Riverpod) + Angular
Documento de respuestas conceptuales y técnicas correspondientes a la evaluación para Desarrollador Jr Flutter (Riverpod) + Angular.


Parte 1 — Preguntas conceptuales (15 %)

Dart y Flutter


1. ¿Qué diferencia hay entre final y const en Dart? ¿Por qué importa usar const en constructores de widgets?

Diferencia: final se evalúa en tiempo de ejecución (runtime) y su valor se asigna una sola vez; const es una constante en tiempo de compilación (compile-time) que crea instancias canónicas e inmutables en memoria.

Importancia en widgets: Usar const en constructores de widgets permite que Flutter reutilice la misma instancia en memoria en lugar de crear un nuevo objeto cuando el árbol se reconstruye (rebuild), reduciendo el trabajo del Garbage Collector y optimizando el rendimiento de renderizado.

final now = DateTime.now(); // Asignación única en tiempo de ejecución

const pi = 3.14159;         // Conocido y fijado en tiempo de compilación

const Text('Catálogo');     // Reutiliza la misma instancia en el árbol de widgets


2. Explica el null safety de Dart. ¿Cuándo usarías ?, !, ?? y late? ¿Por qué abusar de ! es una mala práctica?

Null Safety: El sistema de tipos garantiza en tiempo de compilación que una variable no contendrá null, salvo que se declare explícitamente como nullable.

?: Declara tipos que admiten nulo (String?) o navegación segura (user?.name).

??: Operador coalesce para proveer un valor alternativo por defecto (price ?? 0.0).

!: Operador de aserción no nula (fuerza al compilador a tratar el valor como no nulo).

late: Indica inicialización tardía garantizando que se asignará antes de su lectura.

Riesgo de !: Abusar del operador ! anula las garantías de seguridad del compilador y traslada el riesgo a tiempo de ejecución, provocando excepciones no controladas (NullCheckError/crashes).

3. ¿Cuál es la diferencia entre StatelessWidget y StatefulWidget? ¿Qué aportan ConsumerWidget y ConsumerStatefulWidget?

Diferencia: StatelessWidget es inmutable y no mantiene estado interno entre reconstrucciones; StatefulWidget delega su comportamiento mutable a una clase State que persiste a lo largo del ciclo de vida del widget.

Aporte de Riverpod: ConsumerWidget y ConsumerStatefulWidget proporcionan una referencia WidgetRef directamente en el método build, permitiendo escuchar (ref.watch), leer (ref.read) o reaccionar (ref.listen) a providers de Riverpod de manera reactiva y desacoplada del BuildContext.

4. ¿Qué es un Future y qué es un Stream? Da un caso de uso real de cada uno.

Future: Representa un valor o error asíncrono único que estará disponible en el futuro (1 solo evento).
Caso real: Obtener el detalle de un producto mediante una petición HTTP GET /products/1.

Stream: Representa una secuencia continua de eventos asíncronos que se emiten a lo largo del tiempo (0 a múltiples eventos).
Caso real: Escuchar cambios de conectividad a internet en tiempo real o recibir mensajes vía WebSockets.

5. ¿Por qué es preferible extraer un widget a una clase propia en lugar de un método _buildAlgo() que retorna un Widget?

Optimización de rebuilds: Una clase propia puede tener un constructor const, evitando reconstrucciones innecesarias cuando el widget padre se actualiza.

Árbol de contexto y testing: Cada clase cuenta con su propio BuildContext y ciclo de vida, lo que facilita el profiling con Flutter Inspector y permite realizar pruebas de widget aisladas.

Clean Code: Los métodos auxiliares _buildAlgo() acumulan lógica y dependencias en un único archivo gigante, volviéndolo difícil de mantener.
-----------------------------------------------------------------------------------------------------------------------------------

Riverpod

6. ¿Qué problema resuelve Riverpod frente a setState o frente a Provider (el paquete)?

Frente a setState: Desacopla la lógica de negocio y el estado de la capa visual (UI), permitiendo reutilizar el estado globalmente y escribir pruebas unitarias sin depender de widgets.

Frente a Provider: Riverpod no depende del árbol de widgets (BuildContext), eliminando los errores en tiempo de ejecución como ProviderNotFoundException. Es seguro en tiempo de compilación, permite múltiples providers del mismo tipo y facilita la limpieza automática de memoria (autoDispose).

7. Explica la diferencia entre ref.watch, ref.read y ref.listen. ¿Dónde es incorrecto usar ref.read?

ref.watch: Se suscribe al provider y reconstruye el widget cada vez que el valor cambia. Debe usarse dentro del método build.

ref.read: Obtiene el valor actual del provider una sola vez sin suscribirse a cambios futuros.

ref.listen: Escucha cambios en el provider para ejecutar efectos secundarios (navegación, mostrar un SnackBar, diálogos).

Uso incorrecto: Es un antipatrón usar ref.read dentro del método build, ya que no escuchará actualizaciones y la UI quedará desactualizada. ref.read solo debe usarse dentro de callbacks de eventos (como onPressed o onTap).

8. ¿Cuándo usarías un Provider, un FutureProvider, un Notifier y un AsyncNotifier?

Provider: Para exponer valores síncronos inmutables o dependencias de sólo lectura (ej. cliente HTTP, instancias de repositorios).

FutureProvider: Para lectura asíncrona de datos de sólo lectura que no cambian frecuentemente (ej. obtener configuraciones remotas).

Notifier: Para gestionar estados síncronos mutables con métodos que manipulan el estado (ej. carrito de compras local, filtros de selección).

AsyncNotifier: Para gestionar estados asíncronos mutables complejos con operaciones de carga, mutación y error (ej. autenticación, listados con paginación y mutaciones remotas).

9. ¿Qué hace el modificador autoDispose y qué problema evita? ¿Y family?

autoDispose: Destruye y libera automáticamente el estado del provider cuando deja de tener escuchas activos en la UI. Evita fugas de memoria y asegura que al volver a una pantalla se carguen datos frescos en lugar de datos residuales.

family: Permite pasar parámetros externos a un provider (por ejemplo, el ID de un producto: productDetailProvider(productId)), creando instancias aisladas para cada parámetro único.

10. ¿Cómo manejas los estados de carga, error y datos con AsyncValue? Escribe un ejemplo con .when o pattern matching.

AsyncValue encapsula de forma exhaustiva y segura los estados asíncronos (data, loading, error), obligando a la interfaz a manejar cada escenario:

final productAsync = ref.watch(productDetailProvider(productId));

return productAsync.when(

  data: (product) => ProductDetailView(product: product),

  loading: () => const Center(child: CircularProgressIndicator()),

  error: (err, stack) => Center(

    child: ElevatedButton(

      onPressed: () => ref.invalidate(productDetailProvider(productId)),

      child: const Text('Reintentar'),

    ),

  ),

);

11. ¿Cómo sobrescribirías un provider en un test para inyectar un repositorio falso?

Se utiliza la propiedad overrides en ProviderContainer (para pruebas unitarias) o en ProviderScope (para pruebas de widgets), reemplazando el provider original con una implementación falsa (mock o fake):

final container = ProviderContainer(

  overrides: [

    productsRepositoryProvider.overrideWithValue(FakeProductsRepository()),

  ],

);

addTearDown(container.dispose);

-------------------------------------------------------------------------------------------------------------------------------------

Angular

12. ¿Qué diferencia hay entre un componente standalone y uno declarado en un NgModule?

Standalone: (standalone: true, estándar moderno desde Angular 14/17+) gestiona sus propias dependencias importando directamente lo que necesita en su decorador (imports: [CommonModule, ReactiveFormsModule]), sin intermediación de módulos.

NgModule: Requiere registrar el componente en el arreglo declarations de un módulo contenedor.

Ventaja standalone: Reduce el boilerplate, facilita el lazy-loading a nivel de componente y optimiza el empaquetado final (tree-shaking).

13. Explica la diferencia entre un Observable (RxJS) y un Signal. ¿Cuándo preferirías cada uno?

Observable: Flujo asíncrono en el tiempo con múltiples emisiones, perezoso (cold) y con potente soporte para operadores complejos (switchMap, debounceTime, catchError).

Signal: Contenedor reactivo síncrono de un valor con seguimiento fino de dependencias (signal(), computed()), integrado al nuevo motor de detección de cambios de Angular.

Elección: Se prefieren Signals para estados de UI en componentes y enlaces directos a plantillas; se prefieren Observables para flujos asíncronos complejos, peticiones HTTP y eventos temporales continuos.

14. ¿Para qué sirven @Input() / input() y @Output() / output()? ¿Cómo se comunican dos componentes hermanos?

Input / Output: input() recibe datos desde un componente padre; output() emite eventos desde el hijo hacia el padre.

Comunicación entre hermanos: Dos componentes hermanos no deben acoplarse directamente; la comunicación se realiza elevando el estado al componente padre común (mediante inputs/outputs) o, preferiblemente, a través de un servicio compartido inyectado que gestione el estado común con un Signal o un BehaviorSubject.

15. ¿Qué es la inyección de dependencias en Angular y para qué sirve providedIn: 'root'?

Inyección de Dependencias (DI): Mecanismo donde el framework provee automáticamente las instancias requeridas por una clase en su constructor, facilitando desacoplamiento y testeabilidad.

providedIn: 'root': Registra el servicio en el inyector raíz de la aplicación, creando una única instancia compartida (Singleton) disponible globalmente y habilitando la optimización tree-shaking (si el servicio nunca se usa, se excluye del bundle en producción).

16. ¿Por qué hay que preocuparse por las suscripciones a Observables? Menciona dos formas de evitar fugas de memoria.

Riesgo: Si un componente se destruye y la suscripción sigue activa, las funciones de callback continúan en memoria reteniendo referencias, lo que causa fugas de memoria y ejecuciones duplicadas no deseadas.

Dos formas de evitarlo:

1. Usar el pipe | async o toSignal() en la plantilla, delegando la desuscripción automática al ciclo de vida del componente.

2. Usar el operador takeUntilDestroyed() en el contexto de inyección (o gestionar un DestroyRef / Subject con takeUntil).

--------------------------------------------------------------------------------------------------------------------------------

Código limpio y buenas prácticas

17. Explica con tus palabras el principio de responsabilidad única (SRP) y cómo lo aplicarías en una app Flutter.

Definición: Una clase o módulo debe tener una única razón para cambiar, resolviendo una tarea específica.

Aplicación en Flutter:

La UI (Widget) solo dibuja y captura gestos del usuario.

El State Notifier coordina la lógica de presentación y flujo de estados.

El Repositorio orquesta la obtención de datos y abstracciones de red.

Un widget jamás debe hacer peticiones HTTP directas ni parsear JSONs en su código.

18. ¿Por qué separar la app en capas (presentación, dominio, datos)? ¿Qué va en cada una?

Por qué: Aísla las reglas de negocio de los detalles de implementación (frameworks, librerías HTTP, bases de datos), facilitando cambios tecnológicos, mantenimiento y pruebas independientes.

Capas:

Presentación: Widgets, pantallas, componentes de UI y Notifiers/Providers de Riverpod.

Dominio: Entidades de negocio puras, casos de uso y contratos/interfaces de repositorios (sin dependencias de Flutter ni librerías de terceros).

Datos: Modelos/DTOs con serialización JSON, datasources (HTTP, persistencia local) y la implementación concreta de los repositorios.

19. ¿Qué diferencia hay entre una prueba unitaria, una de widget y una de integración?

Prueba unitaria: Prueba una clase, método o notifier en aislamiento lógico sin renderizar UI ni usar emulador (ej. comprobar que CartNotifier.addItem() calcula el total correctamente). Rápida y de bajo coste.

Prueba de widget: Prueba el comportamiento, renderizado e interacción de uno o varios widgets en un entorno simulado de Flutter sin dispositivo real (WidgetTester).

Prueba de integración: Prueba flujos completos de punta a punta (end-to-end) en un emulador o dispositivo real, verificando la integración real entre pantallas, navegación y persistencia.

20. Menciona tres convenciones que sigues al hacer commits y abrir un pull request.

Conventional Commits: Escribir mensajes atómicos con prefijos claros (feat:, fix:, refactor:, test:, docs:) que expliquen el qué y el porqué del cambio.

Commits pequeños y atómicos: Cada commit representa un solo cambio lógico coherente, facilitando la revisión y eventuales reversiones (git revert).

Pull Request descriptivo y autocontenido: Incluir resumen de cambios, capturas o grabaciones de UI si aplica, checklist de calidad (linting y tests pasando) y pasos para que el revisor pueda probarlo localmente.