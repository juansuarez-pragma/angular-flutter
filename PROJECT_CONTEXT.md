# 📋 Contexto del Proyecto - Shell Orchestrator PoC

## 🎯 Resumen del Proyecto

**Nombre:** Flutter Shell Orchestrator + Angular MFE
**Tipo:** Proof of Concept (PoC)
**Objetivo:** Demostrar comunicación bidireccional entre un Shell Orquestador Flutter y un Micro Frontend Angular cargado en WebView
**Estado:** ✅ **100% FUNCIONAL EN ANDROID**
**Fecha:** 2025-11-11

---

## 🏗️ Arquitectura

### Patrón: Shell Orchestrator

```
┌─────────────────────────────────────────────────────┐
│         Flutter Shell Orquestador                    │
│  ┌───────────────────────────────────────────────┐  │
│  │              AppBloc (BLoC Pattern)            │  │
│  │  - Maneja estado global                        │  │
│  │  - Gestiona lógica de negocio                  │  │
│  │  - Procesa eventos                             │  │
│  └───────────────────────────────────────────────┘  │
│                        ↕                             │
│  ┌───────────────────────────────────────────────┐  │
│  │           BridgeService                        │  │
│  │  - Comunicación bidireccional                  │  │
│  │  - JavaScript Handler                          │  │
│  │  - CustomEvent dispatcher                      │  │
│  └───────────────────────────────────────────────┘  │
│                        ↕                             │
│  ┌───────────────────────────────────────────────┐  │
│  │         InAppWebView                           │  │
│  │  ┌─────────────────────────────────────────┐  │  │
│  │  │    Angular MFE (Micro Frontend)         │  │  │
│  │  │  - UI Pura (sin lógica de negocio)     │  │  │
│  │  │  - Standalone Components                │  │  │
│  │  │  - BridgeService para comunicación      │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

---

## 📁 Estructura del Proyecto

### Directorio Raíz
```
/Users/juancarlossuarezmarin/Desktop/front/flutter+angular/
├── flutter_shell_orchestrator/    # Flutter Shell
├── angular_mfe_ui/                 # Angular MFE
├── PROJECT_CONTEXT.md             # Este archivo
├── CHANGES_SUMMARY.md             # Resumen de cambios
├── BIOMETRY_REMOVED.md            # Documentación de eliminación de biometría
└── RUN_NOW.md                     # Guía rápida de ejecución
```

### Flutter Shell Orchestrator

```
flutter_shell_orchestrator/
├── lib/
│   ├── main.dart                                    # Entry point
│   ├── app.dart                                     # Root widget con providers
│   ├── core/
│   │   ├── bloc/
│   │   │   ├── app_bloc.dart                       # BLoC principal
│   │   │   ├── app_event.dart                      # Eventos (UpdateNameEvent)
│   │   │   └── app_state.dart                      # Estado (userName, lastUpdated)
│   │   └── services/
│   │       └── bridge_service.dart                 # Servicio de comunicación
│   └── presentation/
│       └── screens/
│           └── webview_host_screen.dart            # Pantalla con WebView
├── android/                                         # Configuración Android
├── ios/                                             # Configuración iOS
├── pubspec.yaml                                     # Dependencias Flutter
└── test/                                            # Tests
```

**Dependencias Flutter:**
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  go_router: ^13.0.0
  flutter_inappwebview: ^6.0.0
  dio: ^5.4.0
```

### Angular MFE UI

```
angular_mfe_ui/
├── src/
│   └── app/
│       ├── app.component.ts                        # Componente principal
│       ├── app.component.html                      # Template UI
│       ├── app.component.css                       # Estilos
│       ├── app.config.ts                           # Configuración
│       └── services/
│           └── bridge.service.ts                   # Servicio de comunicación
├── package.json                                     # Dependencias npm
└── angular.json                                     # Configuración Angular
```

**Stack Angular:**
- Angular 17+
- Standalone Components (sin NgModules)
- RxJS para reactive programming
- TypeScript

---

## 🔄 Flujos Implementados

### Flujo 1: Inicialización (Flutter → Web)

**Propósito:** Enviar datos iniciales de Flutter a Angular cuando carga el WebView

```
1. Flutter: AppBloc se inicializa con userName="Usuario Inicial"
   ↓
2. Flutter: WebView termina de cargar (onLoadStop)
   ↓
3. Flutter: BridgeService.sendDataUpdate() ejecuta JavaScript
   ↓
4. JavaScript: CustomEvent('flutterDataUpdate', {userName, timestamp})
   ↓
5. Angular: document.addEventListener() recibe el evento
   ↓
6. Angular: bridgeService.userName$.next(userName)
   ↓
7. Angular: AppComponent actualiza this.userName
   ↓
8. Angular: UI se renderiza con el nombre recibido ✅
```

**Logs de éxito:**
```
I/flutter: BridgeService: Datos enviados al MFE - userName: Usuario Inicial
I/chromium: Angular: Nombre de usuario actualizado: Usuario Inicial
```

### Flujo 2: Actualizar Nombre (Web ↔ Flutter ↔ Web)

**Propósito:** Actualización bidireccional del nombre desde Angular

```
1. Usuario escribe nombre en input de Angular
   ↓
2. Angular: onClick() → bridgeService.updateName(newName)
   ↓
3. Angular: flutter_inappwebview.callHandler('AppBridge', {event, payload})
   ↓
4. Flutter: addJavaScriptHandler recibe el mensaje
   ↓
5. Flutter: Valida estructura del mensaje
   ↓
6. Flutter: appBloc.add(UpdateNameEvent(newName))
   ↓
7. Flutter: AppBloc._onUpdateName() procesa evento
   ↓
8. Flutter: emit(state.copyWith(userName: newName))
   ↓
9. Flutter: BlocListener detecta cambio de estado
   ↓
10. Flutter: bridgeService.sendDataUpdate(userName)
    ↓
11. JavaScript: CustomEvent('flutterDataUpdate') se dispara
    ↓
12. Angular: Recibe evento y actualiza UI ✅
```

**Logs de éxito:**
```
I/chromium: Angular: Usuario solicita actualizar nombre a: juan
I/flutter: AppBridge: Mensaje recibido desde Web: {event: UPDATE_NAME, payload: {newName: juan}}
I/flutter: AppBloc: Actualizando nombre a: juan
I/chromium: Angular: Nombre de usuario actualizado: juan
```

---

## 🔧 Detalles Técnicos Importantes

### 1. JavaScript Bridge (InAppWebView)

**En Flutter:**
```dart
// Registrar handler
controller.addJavaScriptHandler(
  handlerName: 'AppBridge',
  callback: (args) { /* procesar mensaje */ }
);

// Enviar datos a Angular
await controller.evaluateJavascript(source: '''
  const event = new CustomEvent('flutterDataUpdate', {
    detail: ${jsonEncode(payload)}
  });
  document.dispatchEvent(event);
''');
```

**En Angular:**
```typescript
// Recibir datos de Flutter
document.addEventListener('flutterDataUpdate', (event: CustomEvent) => {
  this.userName$.next(event.detail.userName);
});

// Enviar datos a Flutter
(window as any).flutter_inappwebview.callHandler('AppBridge', message);
```

### 2. BLoC Pattern (Flutter)

**Estado:**
```dart
class AppState extends Equatable {
  final String userName;
  final DateTime lastUpdated;
}
```

**Eventos:**
```dart
class UpdateNameEvent extends AppEvent {
  final String newName;
}
```

**BLoC:**
```dart
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState.initial()) {
    on<UpdateNameEvent>(_onUpdateName);
  }

  void _onUpdateName(UpdateNameEvent event, Emitter<AppState> emit) {
    emit(state.copyWith(userName: event.newName));
  }
}
```

### 3. URLs y Networking

**Para Android Emulator:**
- URL Angular: `http://10.0.2.2:4200`
- Razón: `10.0.2.2` es la IP especial que apunta al host desde el emulador
- `localhost` NO funciona en emulador Android

**Para iOS Simulator:**
- URL Angular: `http://localhost:4200`
- `localhost` funciona correctamente en iOS

**Permisos requeridos:**
- Android: `INTERNET` permission en `AndroidManifest.xml`
- iOS: `NSAppTransportSecurity` permitiendo `localhost` en `Info.plist`

---

## ⚠️ Problemas Resueltos

### 1. ❌ Biometría Eliminada

**Problema:** Dependencias de `local_auth` causaban errores de compilación en iOS

**Solución:** Eliminación completa de biometría de la PoC
- 14 archivos modificados
- ~377 líneas de código eliminadas
- 2 flujos finales (vs 3 originales)

**Archivos de documentación:**
- `BIOMETRY_REMOVED.md`
- `CHANGES_SUMMARY.md`

### 2. ❌ AppBridge no disponible

**Problema:** Angular no detectaba el bridge de Flutter

**Error:**
```
Angular: AppBridge no disponible (ejecutando fuera de Flutter)
```

**Causa:** Angular buscaba `window.AppBridge.postMessage()` pero InAppWebView expone `window.flutter_inappwebview.callHandler()`

**Solución:** Actualizar `angular_mfe_ui/src/app/services/bridge.service.ts`:
```typescript
// ANTES (incorrecto):
(window as any).AppBridge.postMessage(JSON.stringify(message));

// DESPUÉS (correcto):
(window as any).flutter_inappwebview.callHandler('AppBridge', message);
```

### 3. ❌ iOS No Compila

**Problema:** Errores de Swift Compiler con CoreFoundation en Xcode

**Intentos de solución:**
- `flutter clean`
- Eliminación de DerivedData
- `pod install`
- Múltiples limpiezas

**Estado:** No resuelto, pero no crítico porque Android funciona perfectamente

**Alternativa:** Usar emulador Android o macOS (ambos soportados)

### 4. ❌ WebView en blanco en Chrome

**Problema:** `flutter run -d chrome` mostraba WebView en blanco

**Causa:** `flutter_inappwebview` NO soporta Flutter Web, solo plataformas nativas

**Solución:** Usar Android, iOS o macOS

---

## 🚀 Cómo Ejecutar la PoC

### Requisitos Previos
- Flutter SDK instalado
- Node.js y npm instalados
- Emulador Android o iOS funcionando (Android preferido)

### Paso 1: Iniciar Angular MFE

```bash
cd angular_mfe_ui
npm install
npm start
```

Verificar: `http://localhost:4200` debe mostrar la app Angular

### Paso 2: Iniciar Flutter Shell (Android)

```bash
cd flutter_shell_orchestrator
flutter run -d emulator-5554  # o el ID de tu emulador
```

### Paso 3: Probar la Funcionalidad

1. ✅ Verificar que aparece "Usuario Inicial" en la UI
2. ✅ Escribir un nombre en el input
3. ✅ Presionar "Actualizar Nombre"
4. ✅ Verificar que el nombre se actualiza en la UI

---

## 📊 Estado Actual

### ✅ Funcionando
- Compilación Flutter en Android
- Carga de Angular en WebView
- Comunicación Flutter → Web (CustomEvent)
- Comunicación Web → Flutter (callHandler)
- Actualización reactiva de UI
- BLoC pattern funcionando
- Hot reload en ambas apps

### ⚠️ Conocido pero No Crítico
- iOS no compila (errores de Xcode)
- Flutter Web no soporta InAppWebView

### 🎯 Plataformas Soportadas
- ✅ **Android** (100% funcional)
- ⚠️ iOS (errores de compilación)
- ✅ macOS (debería funcionar, no probado completamente)
- ❌ Web (InAppWebView no soportado)

---

## 🔍 Comandos Útiles

### Flutter
```bash
# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Ver dispositivos disponibles
flutter devices

# Ejecutar en Android
flutter run -d emulator-5554

# Ver logs
flutter logs

# Análisis estático
flutter analyze
```

### Angular
```bash
# Instalar dependencias
npm install

# Iniciar servidor
npm start

# Build de producción
npm run build
```

### Android
```bash
# Ver dispositivos
adb devices

# Ver logs en tiempo real
adb logcat | grep flutter
```

---

## 📝 Archivos de Configuración Clave

### Flutter: `pubspec.yaml`
- Define dependencias
- Sin `local_auth` (eliminado)
- 5 dependencias principales

### Angular: `package.json`
- Angular 17+
- RxJS
- TypeScript

### Android: `AndroidManifest.xml`
- Permiso `INTERNET`
- `usesCleartextTraffic="true"` para localhost

### iOS: `Info.plist`
- `NSAppTransportSecurity` para localhost
- Sin `NSFaceIDUsageDescription` (biometría eliminada)

---

## 🎓 Conceptos Clave

### 1. Shell Orchestrator Pattern
- Shell: Flutter app que orquesta todo
- MFE: Angular app con solo UI
- Separación clara de responsabilidades

### 2. BLoC Pattern
- Business Logic Component
- Separación de UI y lógica
- Estado inmutable con Equatable
- Streams para reactive updates

### 3. Micro Frontend
- UI aislada sin lógica de negocio
- Comunicación via bridge
- Independiente del shell

### 4. JavaScript Bridge
- Puente de comunicación nativo ↔ web
- Mensajes bidireccionales
- Validación de seguridad

---

## 📚 Documentación Adicional

- `BIOMETRY_REMOVED.md` - Detalles de eliminación de biometría
- `CHANGES_SUMMARY.md` - Resumen completo de cambios
- `RUN_NOW.md` - Guía rápida de ejecución

---

## 🔐 Consideraciones de Seguridad

### Validación de Mensajes
```dart
// Validar origen y estructura
if (event == null || payload == null) {
  return {'error': 'Invalid message'};
}
```

### Producción
- Validar origen real del mensaje
- Implementar whitelist de eventos permitidos
- Encriptar datos sensibles
- Rate limiting en mensajes

---

## 🧪 Tests

**Estado actual:** Sin tests implementados

**Tests recomendados:**
- Unit tests para BLoC
- Unit tests para BridgeService
- Integration tests para comunicación
- Widget tests para UI

---

## 🔜 Próximos Pasos Potenciales

1. Resolver problemas de iOS
2. Agregar más flujos de comunicación
3. Implementar navegación entre MFEs
4. Agregar state persistence
5. Implementar error handling robusto
6. Agregar tests automatizados
7. Performance optimization
8. Documentación de API completa

---

## 💡 Tips para Nuevos Desarrolladores

1. **Siempre inicia Angular primero** antes de Flutter
2. **En Android emulator** usa `10.0.2.2` no `localhost`
3. **Hot reload** funciona en ambas apps simultáneamente
4. **Los logs** son tu mejor amigo para debugging
5. **El bridge** es asíncrono, maneja errores apropiadamente

---

## 📞 Contacto del Proyecto

**Desarrollador:** Juan Carlos Suarez Marin
**Fecha de creación:** 2025-11-11
**Última actualización:** 2025-11-11

---

**Fin del Documento de Contexto**
