# 🏗️ Documentación de Arquitectura

## Resumen Ejecutivo

Esta PoC implementa una arquitectura híbrida móvil donde:
- **Flutter** actúa como el orquestador principal (Shell)
- **Angular** proporciona la interfaz de usuario (MFE)
- La comunicación es bidireccional vía puente JavaScript

## Componentes Principales

### 1. Flutter Shell Orquestador

#### Responsabilidades
- Gestión de estado global (flutter_bloc)
- Navegación (go_router)
- Orquestación de funcionalidades nativas (biometría, almacenamiento, etc.)
- Provisión de datos al MFE
- Validación de seguridad

#### Tecnologías Clave
```yaml
dependencies:
  flutter_bloc: ^8.1.3          # Gestión de estado
  go_router: ^13.0.0            # Navegación
  flutter_inappwebview: ^6.0.0  # WebView con JS bridge
  local_auth: ^2.2.0            # Biometría
  dio: ^5.4.0                   # HTTP client
```

#### Arquitectura de Código

```
lib/
├── main.dart                      # Entry point
├── app.dart                       # Root widget con providers
├── config/
│   └── router_config.dart         # Configuración de rutas
├── core/
│   ├── bloc/
│   │   ├── app_bloc.dart          # BLoC principal
│   │   ├── app_event.dart         # Eventos de la app
│   │   └── app_state.dart         # Estados de la app
│   └── services/
│       ├── bridge_service.dart    # Comunicación con WebView
│       └── biometric_service.dart # Wrapper de local_auth
└── presentation/
    └── screens/
        └── webview_host_screen.dart  # Pantalla con WebView
```

#### Flujo de Datos (BLoC Pattern)

```
UI Event
   ↓
Event Dispatch (add)
   ↓
BLoC Event Handler
   ↓
Business Logic / Service Calls
   ↓
State Emission (emit)
   ↓
BlocListener / BlocBuilder
   ↓
UI Update / Side Effects
```

### 2. Angular MFE UI

#### Responsabilidades
- Renderizar interfaz de usuario
- Capturar interacciones del usuario
- Enviar eventos al Shell
- Recibir y mostrar datos del Shell

#### Tecnologías Clave
```json
{
  "@angular/core": "^17.0.0",       // Framework base
  "@angular/common": "^17.0.0",     // Módulos comunes
  "rxjs": "~7.8.0"                  // Reactive programming
}
```

#### Arquitectura de Código

```
src/
├── main.ts                        # Bootstrap
├── app/
│   ├── app.component.ts           # Componente raíz
│   ├── app.component.html         # Template
│   ├── app.component.css          # Estilos
│   ├── app.config.ts              # Configuración standalone
│   └── services/
│       └── bridge.service.ts      # Servicio de comunicación
```

#### Principios de Diseño

**✅ SÍ contiene:**
- Componentes de presentación
- Manejo de eventos de UI
- Estilos y animaciones
- Validación de formularios (cliente)

**❌ NO contiene:**
- Lógica de negocio
- Llamadas HTTP/API
- Gestión de estado compleja (NgRx)
- Servicios de datos

## Comunicación Bidireccional

### Arquitectura del Puente

```
┌──────────────────────────────────────────────────────────┐
│                    Flutter Shell                          │
│                                                           │
│  ┌─────────────────────────────────────────────────┐    │
│  │              AppBloc (Estado)                    │    │
│  │  - userName: string                              │    │
│  │  - isAuthenticated: bool                         │    │
│  │  - biometricResult: bool?                        │    │
│  └────────────┬───────────────────────┬─────────────┘    │
│               │                       │                   │
│               ↓                       ↓                   │
│  ┌────────────────────┐   ┌──────────────────────┐      │
│  │  BiometricService  │   │   BridgeService      │      │
│  │  - authenticate()  │   │   - sendDataUpdate() │      │
│  └────────────────────┘   │   - sendBiometric()  │      │
│                            └──────────┬───────────┘      │
│                                       │                   │
│  ┌────────────────────────────────────┼────────────┐     │
│  │         InAppWebViewController     │            │     │
│  │                                    ↓            │     │
│  │    ┌──────────────────────────────────────┐    │     │
│  │    │   evaluateJavascript()               │    │     │
│  │    │   (Envía CustomEvent a Angular)      │    │     │
│  │    └──────────────────────────────────────┘    │     │
│  │                                                 │     │
│  │    ┌──────────────────────────────────────┐    │     │
│  │    │   addJavaScriptHandler('AppBridge')  │    │     │
│  │    │   (Recibe postMessage de Angular)    │    │     │
│  │    └──────────────────────────────────────┘    │     │
│  └────────────────────────────────────────────────┘     │
│                         ↕                                 │
│         ═══════════════════════════════                  │
│              JavaScript Bridge                            │
│         ═══════════════════════════════                  │
│                         ↕                                 │
│  ┌────────────────────────────────────────────────┐     │
│  │              Angular MFE                        │     │
│  │                                                 │     │
│  │   ┌──────────────────────────────────────┐     │     │
│  │   │      BridgeService                   │     │     │
│  │   │                                      │     │     │
│  │   │  Enviar → Flutter:                  │     │     │
│  │   │  window.AppBridge.postMessage()     │     │     │
│  │   │                                      │     │     │
│  │   │  Recibir ← Flutter:                 │     │     │
│  │   │  document.addEventListener()        │     │     │
│  │   └──────────────┬───────────────────────┘     │     │
│  │                  │                             │     │
│  │                  ↓                             │     │
│  │   ┌──────────────────────────────────────┐     │     │
│  │   │      AppComponent                    │     │     │
│  │   │  - userName: string                  │     │     │
│  │   │  - authStatus: string                │     │     │
│  │   │  - onUpdateNameClick()               │     │     │
│  │   │  - onBiometricAuthClick()            │     │     │
│  │   └──────────────────────────────────────┘     │     │
│  └────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────┘
```

### Protocolo de Mensajes

#### Formato de Mensaje (Angular → Flutter)

```typescript
interface Message {
  event: string;      // Tipo de evento
  payload?: any;      // Datos opcionales
}
```

**Ejemplos:**

```json
// Actualizar nombre
{
  "event": "UPDATE_NAME",
  "payload": {
    "newName": "Juan Pérez"
  }
}

// Solicitar biometría
{
  "event": "BIOMETRIC_REQUEST"
}
```

#### Formato de Evento (Flutter → Angular)

**CustomEvent con detail:**

```javascript
// Datos actualizados
{
  type: 'flutterDataUpdate',
  detail: {
    userName: 'Juan Pérez',
    timestamp: '2025-11-11T10:30:00Z'
  }
}

// Resultado de biometría
{
  type: 'biometricResult',
  detail: {
    success: true,
    error: null,
    timestamp: '2025-11-11T10:30:05Z'
  }
}
```

### Implementación del Puente

#### En Flutter (Emisor)

```dart
// BridgeService.dart
Future<void> sendDataUpdate({required String userName}) async {
  final payload = {
    'userName': userName,
    'timestamp': DateTime.now().toIso8601String(),
  };

  final jsCode = '''
    (function() {
      const event = new CustomEvent('flutterDataUpdate', {
        detail: ${jsonEncode(payload)}
      });
      document.dispatchEvent(event);
    })();
  ''';

  await _webViewController!.evaluateJavascript(source: jsCode);
}
```

#### En Flutter (Receptor)

```dart
// WebViewHostScreen.dart
controller.addJavaScriptHandler(
  handlerName: 'AppBridge',
  callback: (args) {
    // Validación de seguridad
    if (args.isEmpty) {
      return {'error': 'No data received'};
    }

    // Parsear mensaje
    final payload = jsonDecode(args[0]);
    final event = payload['event'];

    // Procesar eventos
    switch (event) {
      case 'UPDATE_NAME':
        appBloc.add(UpdateNameEvent(payload['payload']['newName']));
        break;
      case 'BIOMETRIC_REQUEST':
        appBloc.add(BiometricAuthRequestedEvent());
        break;
    }

    return {'success': true};
  },
);
```

#### En Angular (Emisor)

```typescript
// bridge.service.ts
public updateName(newName: string): void {
  const message = {
    event: 'UPDATE_NAME',
    payload: { newName }
  };

  (window as any).AppBridge.postMessage(JSON.stringify(message));
}
```

#### En Angular (Receptor)

```typescript
// bridge.service.ts
private initializeListeners(): void {
  document.addEventListener('flutterDataUpdate', ((event: CustomEvent) => {
    if (event.detail && event.detail.userName) {
      this.userName$.next(event.detail.userName);
    }
  }) as EventListener);

  document.addEventListener('biometricResult', ((event: CustomEvent) => {
    if (event.detail) {
      this.biometricResult$.next({
        success: event.detail.success,
        error: event.detail.error
      });
    }
  }) as EventListener);
}
```

## Flujos de Datos Detallados

### Flujo 1: Inicialización

```
1. App Flutter inicia
   │
   ├─→ main.dart ejecuta runApp(App())
   │
   ├─→ App.dart crea BlocProvider con AppBloc
   │   │
   │   └─→ AppBloc se inicializa con AppState.initial()
   │       (userName = "Usuario Inicial")
   │
   ├─→ GoRouter navega a WebViewHostScreen
   │
   ├─→ WebViewHostScreen inicializa InAppWebView
   │   │
   │   ├─→ Registra AppBridge handler
   │   │
   │   └─→ Carga URL: http://localhost:4200
   │
   ├─→ onLoadStop se dispara (WebView cargado)
   │
   ├─→ BlocListener detecta estado inicial
   │
   ├─→ BridgeService.sendAppState() se ejecuta
   │   │
   │   └─→ evaluateJavascript dispara 'flutterDataUpdate'
   │
   └─→ Angular recibe evento
       │
       ├─→ BridgeService.userName$ emite "Usuario Inicial"
       │
       └─→ AppComponent actualiza UI
```

### Flujo 2: Actualizar Nombre

```
1. Usuario en Angular ingresa "Nuevo Nombre"
   │
   ├─→ Click en botón "Actualizar Nombre"
   │
   ├─→ AppComponent.onUpdateNameClick()
   │   │
   │   └─→ BridgeService.updateName("Nuevo Nombre")
   │       │
   │       └─→ window.AppBridge.postMessage(...)
   │
   └─→ Flutter recibe mensaje en AppBridge handler
       │
       ├─→ Parsea JSON: { event: 'UPDATE_NAME', payload: {...} }
       │
       ├─→ Valida estructura y evento
       │
       ├─→ appBloc.add(UpdateNameEvent("Nuevo Nombre"))
       │
       └─→ AppBloc procesa evento
           │
           ├─→ _onUpdateName() se ejecuta
           │
           ├─→ emit(state.copyWith(userName: "Nuevo Nombre"))
           │
           └─→ BlocListener detecta nuevo estado
               │
               ├─→ BridgeService.sendDataUpdate()
               │   │
               │   └─→ evaluateJavascript('flutterDataUpdate')
               │
               └─→ Angular recibe evento
                   │
                   └─→ UI actualiza con "Nuevo Nombre"
```

### Flujo 3: Autenticación Biométrica

```
1. Usuario en Angular click en "Autenticar"
   │
   ├─→ AppComponent.onBiometricAuthClick()
   │   │
   │   ├─→ authStatus = "Autenticando..."
   │   │
   │   └─→ BridgeService.requestBiometricAuth()
   │       │
   │       └─→ window.AppBridge.postMessage({ event: 'BIOMETRIC_REQUEST' })
   │
   └─→ Flutter recibe mensaje
       │
       ├─→ AppBridge handler procesa
       │   │
       │   └─→ appBloc.add(BiometricAuthRequestedEvent())
       │
       └─→ AppBloc._onBiometricAuthRequested() se ejecuta
           │
           ├─→ emit(state.clearBiometricResult())
           │
           ├─→ biometricService.authenticate() - async
           │   │
           │   ├─→ localAuth.canCheckBiometrics()
           │   │
           │   └─→ localAuth.authenticate()
           │       │
           │       └─→ Sistema muestra diálogo nativo
           │           │
           │           ├─→ iOS: Face ID / Touch ID
           │           └─→ Android: Fingerprint / Face
           │
           ├─→ Usuario autentica (éxito/fallo)
           │
           ├─→ BiometricResult retorna
           │
           ├─→ emit(state.copyWith(
           │     biometricAuthSuccess: true/false,
           │     biometricErrorMessage: ...
           │   ))
           │
           └─→ BlocListener detecta cambio
               │
               ├─→ BridgeService.sendBiometricResult()
               │   │
               │   └─→ evaluateJavascript('biometricResult')
               │
               └─→ Angular recibe evento
                   │
                   ├─→ BridgeService.biometricResult$ emite
                   │
                   └─→ AppComponent.handleBiometricResult()
                       │
                       └─→ authStatus = "✅ Autenticación exitosa"
                           o "❌ Error: ..."
```

## Consideraciones de Seguridad

### 1. Validación de Origen

**Problema:** Mensajes maliciosos desde el WebView

**Solución en Flutter:**

```dart
controller.addJavaScriptHandler(
  handlerName: 'AppBridge',
  callback: (args) {
    // ✅ Validar origen (en producción)
    // if (origin != 'https://tu-dominio.com') {
    //   return {'error': 'Invalid origin'};
    // }

    // ✅ Validar estructura
    if (args.isEmpty) {
      return {'error': 'No data'};
    }

    try {
      final payload = jsonDecode(args[0]);

      // ✅ Validar evento conocido
      if (!['UPDATE_NAME', 'BIOMETRIC_REQUEST'].contains(payload['event'])) {
        return {'error': 'Unknown event'};
      }

      // ✅ Validar payload según evento
      if (payload['event'] == 'UPDATE_NAME' &&
          payload['payload']['newName'] == null) {
        return {'error': 'Invalid payload'};
      }

      // Procesar...
    } catch (e) {
      return {'error': 'Parse error'};
    }
  },
);
```

### 2. Sanitización de Datos

**Problema:** XSS y datos maliciosos

**Solución:**

```dart
// Flutter → Web
final jsCode = '''
  const event = new CustomEvent('flutterDataUpdate', {
    detail: ${jsonEncode(payload)}  // ✅ jsonEncode sanitiza
  });
''';

// Validar datos antes de enviar
if (userName.contains('<script>')) {
  // Rechazar o sanitizar
}
```

### 3. Rate Limiting

**Problema:** Flood de mensajes desde WebView

**Solución:**

```dart
class RateLimiter {
  final Map<String, DateTime> _lastCall = {};
  final Duration _minInterval = Duration(milliseconds: 100);

  bool canProceed(String event) {
    final now = DateTime.now();
    final last = _lastCall[event];

    if (last != null && now.difference(last) < _minInterval) {
      return false;
    }

    _lastCall[event] = now;
    return true;
  }
}
```

### 4. Encriptación (Producción)

Para datos sensibles:

```dart
// Flutter
final encrypted = encryptData(sensitiveData);
sendToWeb(encrypted);

// Angular
const decrypted = decryptData(event.detail.data);
```

## Configuración Nativa

### iOS (Info.plist)

```xml
<!-- Biometría -->
<key>NSFaceIDUsageDescription</key>
<string>Esta app necesita Face ID para autenticación</string>

<!-- Permitir localhost -->
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
  <key>NSAllowsLocalNetworking</key>
  <true/>
</dict>
```

### Android (AndroidManifest.xml)

```xml
<!-- Permisos -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>

<!-- Cleartext traffic para localhost -->
<application
    android:usesCleartextTraffic="true">
    ...
</application>
```

### Android (build.gradle)

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Requerido para biometría
    }
}
```

## Performance y Optimizaciones

### 1. Pre-carga del WebView

```dart
// Inicializar WebView antes de mostrarlo
class WebViewManager {
  static InAppWebViewController? _preloadedController;

  static Future<void> preload() async {
    // Pre-cargar WebView en background
  }
}
```

### 2. Cache de Assets

```dart
// Configurar cache en WebView
initialSettings: InAppWebViewSettings(
  cacheEnabled: true,
  cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
),
```

### 3. Compresión de Mensajes

Para payloads grandes:

```dart
import 'dart:convert';
import 'package:archive/archive.dart';

String compressMessage(Map<String, dynamic> data) {
  final json = jsonEncode(data);
  final bytes = utf8.encode(json);
  final compressed = GZipEncoder().encode(bytes);
  return base64Encode(compressed!);
}
```

### 4. Debouncing de Eventos

```typescript
// Angular
import { debounceTime } from 'rxjs/operators';

this.bridgeService.userName$
  .pipe(debounceTime(300))
  .subscribe(name => this.userName = name);
```

## Testing

### Unit Tests (Flutter)

```dart
// test/core/bloc/app_bloc_test.dart
void main() {
  group('AppBloc', () {
    late AppBloc appBloc;
    late BiometricService biometricService;

    setUp(() {
      biometricService = MockBiometricService();
      appBloc = AppBloc(biometricService: biometricService);
    });

    test('emits updated name when UpdateNameEvent is added', () {
      expectLater(
        appBloc.stream,
        emits(predicate<AppState>((state) => state.userName == 'Test')),
      );

      appBloc.add(UpdateNameEvent('Test'));
    });
  });
}
```

### Unit Tests (Angular)

```typescript
// bridge.service.spec.ts
describe('BridgeService', () => {
  let service: BridgeService;

  beforeEach(() => {
    service = TestBed.inject(BridgeService);
  });

  it('should send UPDATE_NAME message', () => {
    spyOn(window.AppBridge, 'postMessage');
    service.updateName('Test');
    expect(window.AppBridge.postMessage).toHaveBeenCalled();
  });
});
```

### Integration Tests

```dart
// integration_test/app_test.dart
void main() {
  testWidgets('Full flow test', (tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    // Verificar que WebView cargó
    expect(find.byType(InAppWebView), findsOneWidget);

    // Simular mensaje desde WebView
    // ...
  });
}
```

## Métricas y Monitoreo

### Logging Estructurado

```dart
// Flutter
class Logger {
  static void logBridgeMessage({
    required String direction,
    required String event,
    Map<String, dynamic>? payload,
  }) {
    print(json.encode({
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'bridge_message',
      'direction': direction,
      'event': event,
      'payload': payload,
    }));
  }
}
```

### Performance Monitoring

```dart
class PerformanceMonitor {
  static Future<T> measure<T>(
    String operation,
    Future<T> Function() fn,
  ) async {
    final start = DateTime.now();
    try {
      return await fn();
    } finally {
      final duration = DateTime.now().difference(start);
      print('$operation took ${duration.inMilliseconds}ms');
    }
  }
}

// Uso
await PerformanceMonitor.measure(
  'biometric_auth',
  () => biometricService.authenticate(),
);
```

## Conclusión

Esta arquitectura proporciona:

✅ **Separación de responsabilidades clara**
- Flutter: Lógica de negocio
- Angular: UI pura

✅ **Comunicación bidireccional robusta**
- Puente JavaScript bien definido
- Validación de seguridad

✅ **Escalabilidad**
- Fácil agregar nuevos eventos
- Fácil agregar nuevos MFEs

✅ **Mantenibilidad**
- Código bien estructurado
- Documentación completa
- Testing implementable

✅ **Performance**
- Optimizaciones posibles
- Carga asíncrona
- Cache estratégico
