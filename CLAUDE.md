# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Descripción del Proyecto

Esta es una **Prueba de Concepto (PoC)** que demuestra una arquitectura móvil híbrida donde:
- **Flutter** actúa como el shell orquestador (maneja lógica de negocio, gestión de estado y funcionalidades nativas)
- **Angular** sirve como Micro Frontend (MFE) proporcionando UI pura (sin lógica de negocio, sin llamadas HTTP, sin estado complejo)
- Comunicación bidireccional vía puente JavaScript usando `flutter_inappwebview`

**Principio Clave:** Flutter es el "cerebro" que maneja toda la lógica; Angular es una "vista tonta" que solo renderiza UI y delega todo a Flutter.

## Estructura del Proyecto

```
flutter+angular/
├── flutter_shell_orchestrator/       # Aplicación shell de Flutter
│   ├── lib/
│   │   ├── main.dart                 # Punto de entrada
│   │   ├── app.dart                  # Widget raíz con BlocProvider
│   │   ├── core/
│   │   │   ├── bloc/                 # Patrón BLoC (gestión de estado)
│   │   │   │   ├── app_bloc.dart     # BLoC principal
│   │   │   │   ├── app_event.dart    # Definición de eventos
│   │   │   │   └── app_state.dart    # Definición de estados
│   │   │   └── services/
│   │   │       └── bridge_service.dart  # Comunicación Flutter ↔ WebView
│   │   ├── config/
│   │   │   └── router_config.dart    # Configuración de go_router
│   │   └── presentation/
│   │       └── screens/
│   │           └── webview_host_screen.dart  # Pantalla host del WebView
│   └── pubspec.yaml
│
└── angular_mfe_ui/                   # MFE de Angular
    ├── src/
    │   └── app/
    │       ├── app.component.ts      # Componente raíz
    │       ├── app.component.html    # Template
    │       ├── app.component.css     # Estilos
    │       └── services/
    │           └── bridge.service.ts  # Comunicación Angular ↔ Flutter
    └── package.json
```

## Comandos de Desarrollo Comunes

### Ejecutar la Aplicación

**Ambas aplicaciones deben ejecutarse simultáneamente en terminales separadas:**

**Terminal 1 - Angular MFE:**
```bash
cd angular_mfe_ui
npm install               # Solo la primera vez
npm start                 # Inicia servidor en http://0.0.0.0:4200
```

**Terminal 2 - Flutter Shell:**
```bash
cd flutter_shell_orchestrator
flutter pub get           # Solo la primera vez
flutter run               # Ejecuta en dispositivo disponible
flutter run -d chrome     # Para testing web (más rápido, pero WebView no funciona)

# Ejemplos para dispositivos específicos:
flutter devices          # Listar dispositivos disponibles
flutter run -d emulator-5554              # Android emulador específico
flutter run -d "iPhone 16 Pro"            # iOS simulador específico
flutter run -d macos                      # macOS
```

### Testing

**Flutter:**
```bash
cd flutter_shell_orchestrator
flutter test                          # Ejecutar todos los tests
flutter test test/path/to/test.dart   # Ejecutar un test específico
```

**Angular:**
```bash
cd angular_mfe_ui
npm test                  # Ejecutar tests de Karma
ng test                   # Alternativa
```

### Linting y Formateo

**Flutter:**
```bash
cd flutter_shell_orchestrator
dart analyze              # Análisis de lint
dart format .             # Formatear todos los archivos Dart
```

**Angular:**
```bash
cd angular_mfe_ui
ng lint                   # Ejecutar linter (si está configurado)
```

### Build

**Flutter:**
```bash
cd flutter_shell_orchestrator
flutter build apk         # APK Android
flutter build ios         # Build iOS
flutter build web         # Build web (nota: InAppWebView no soportado en web)
```

**Angular:**
```bash
cd angular_mfe_ui
npm run build             # Build de producción
ng build --configuration production
```

## Aspectos Destacados de la Arquitectura

### Puente de Comunicación

**Flutter → Angular (enviar datos):**
- Flutter usa `InAppWebViewController.evaluateJavascript()` para despachar CustomEvents
- Angular escucha vía `document.addEventListener('flutterDataUpdate', ...)`
- Implementado en: `bridge_service.dart:sendDataUpdate()`

**Angular → Flutter (enviar comandos):**
- Angular llama `window.flutter_inappwebview.callHandler('AppBridge', message)`
- Flutter recibe vía `addJavaScriptHandler('AppBridge', callback)`
- Implementado en: `bridge.service.ts:sendMessage()` y `webview_host_screen.dart`

**Protocolo de Mensajes:**
```typescript
// Angular → Flutter
{
  event: 'UPDATE_NAME',  // Actualmente solo UPDATE_NAME está implementado
  payload?: { ... }
}
```

### Gestión de Estado (Flutter)

Usa el **patrón BLoC** (paquete `flutter_bloc`):
1. UI/WebView despacha eventos: `appBloc.add(UpdateNameEvent(name))`
2. BLoC procesa evento: `_onUpdateName()` en `app_bloc.dart`
3. BLoC emite nuevo estado: `emit(state.copyWith(userName: newName))`
4. `BlocListener` en `webview_host_screen.dart` reacciona y dispara `bridgeService.sendAppState()`

**Eventos implementados:**
- `UpdateNameEvent(String newName)` - Actualiza el nombre del usuario

**Estado actual:**
- `userName: String` - Nombre del usuario
- `lastUpdated: DateTime` - Timestamp de última actualización

### Configuración de URL

**Importante:** Se necesitan diferentes URLs según la plataforma:
```dart
// Emulador Android (configurado actualmente)
const _mfeUrl = 'http://10.0.2.2:4200';

// Simulador iOS / macOS
const _mfeUrl = 'http://localhost:4200';

// Dispositivo Físico
const _mfeUrl = 'http://192.168.1.X:4200'; // Usa tu IP local
```

**Configuración actual:** `webview_host_screen.dart:24` - Configurado para Android emulator (`10.0.2.2:4200`)

**Para cambiar:** Edita la constante `_mfeUrl` en `lib/presentation/screens/webview_host_screen.dart` según tu plataforma de desarrollo.

## Tecnologías Clave

### Flutter
- `flutter_bloc: ^8.1.3` - Gestión de estado
- `equatable: ^2.0.5` - Comparación de estado inmutable
- `go_router: ^13.0.0` - Enrutamiento declarativo
- `flutter_inappwebview: ^6.0.0` - WebView con puente JavaScript
- `dio: ^5.4.0` - Cliente HTTP (para uso futuro)

### Angular
- `@angular/core: ^17.0.0` - Usa componentes standalone (sin NgModules)
- `rxjs: ~7.8.0` - Programación reactiva con Subjects para comunicación del puente

## Notas Importantes

### Soporte de Plataformas
- ✅ **Android:** Totalmente funcional (usa `10.0.2.2:4200` para emulador)
- ⚠️ **iOS:** Existen problemas de compilación (no crítico para PoC)
- ✅ **macOS:** Debería funcionar (no completamente probado)
- ❌ **Web:** No soportado (InAppWebView no funciona en Flutter Web)

### Biometría Eliminada
La autenticación biométrica fue eliminada para simplificar la PoC. Pueden existir referencias en la documentación pero la dependencia `local_auth` y código biométrico han sido removidos.

### Principio de Diseño de Angular
El MFE de Angular **NUNCA** debe:
- Hacer llamadas HTTP/API
- Contener lógica de negocio
- Gestionar estado complejo (sin NgRx)
- Almacenar datos persistentemente

El MFE de Angular **SOLO** debe:
- Renderizar UI
- Capturar interacciones del usuario
- Enviar eventos a Flutter
- Mostrar datos recibidos de Flutter

### Consideraciones de Seguridad
- La validación de mensajes está implementada en el manejador AppBridge
- Solo se procesan tipos de eventos conocidos
- En producción, agregar validación de origen y rate limiting
- Considerar encriptar payloads sensibles

## Debugging

### Ver Logs

**Flutter:**
```bash
flutter logs
flutter logs | grep -E "AppBridge|BridgeService"  # Filtrar logs del puente
```

**Android Logcat:**
```bash
adb logcat | grep flutter
adb logcat | grep -E "AppBridge|BridgeService|Angular"
```

**Consola WebView (Android):**
```bash
adb logcat | grep -i "webview\|console"
```

**iOS (Safari DevTools):**
- Safari → Develop → [Nombre del Dispositivo] → [Nombre de la App]

### Hot Reload
- **Flutter:** Presiona `r` para hot reload, `R` para hot restart
- **Angular:** Auto-recarga al guardar archivos

## Problemas Comunes

### "Cannot connect to localhost:4200"
- Asegúrate que el servidor de desarrollo de Angular esté corriendo: `npm start` en `angular_mfe_ui/`
- Para emulador Android, usa `10.0.2.2:4200` en lugar de `localhost:4200`

### "AppBridge is undefined"
- El WebView aún no ha cargado completamente
- Revisa los logs de Flutter por "AppBridge JavaScriptHandler registered"
- Intenta hot restart: presiona `R` en la terminal de Flutter

### "No devices available"
- Ejecuta `flutter devices` para ver dispositivos disponibles
- Inicia un emulador o usa Chrome: `flutter run -d chrome`

### WebView muestra pantalla en blanco
- Verifica que Angular está corriendo y accesible: `curl http://localhost:4200`
- Revisa los logs de Flutter por errores de inicialización del WebView
- Verifica que la URL coincide con la plataforma (ver Configuración de URL arriba)

## MCP Dart Integration

Este proyecto tiene integración con el MCP (Model Context Protocol) server de Dart que proporciona herramientas adicionales:

**Herramientas disponibles:**
- `mcp__dart__add_roots` - Agregar raíces de proyecto antes de usar otras herramientas
- `mcp__dart__analyze_files` - Analizar el proyecto completo por errores
- `mcp__dart__dart_fix` - Ejecutar `dart fix --apply` automáticamente
- `mcp__dart__dart_format` - Ejecutar `dart format` en archivos
- `mcp__dart__run_tests` - Ejecutar tests de Dart/Flutter con mejor UX
- `mcp__dart__pub` - Gestionar dependencias (add, get, remove, upgrade)
- `mcp__dart__hot_reload` - Hot reload de aplicaciones Flutter (requiere DTD conectado)
- `mcp__dart__get_runtime_errors` - Ver errores en tiempo de ejecución

**Nota:** Algunas herramientas requieren conectarse al Dart Tooling Daemon (DTD) primero usando `mcp__dart__connect_dart_tooling_daemon`.

## Documentación Adicional

- `README.md` - Documentación completa del proyecto
- `ARCHITECTURE.md` - Arquitectura detallada y diagramas de flujo de datos
- `QUICKSTART.md` - Guía de configuración paso a paso (si existe)
- `PROJECT_CONTEXT.md` - Contexto completo para asistentes de IA (si existe)
- `BIOMETRY_REMOVED.md` - Detalles sobre funcionalidad biométrica removida (si existe)

## Flujo de Trabajo de Desarrollo

Al agregar una nueva funcionalidad:

1. **Definir la interacción** - ¿Qué debería suceder en la UI de Angular?
2. **Crear evento en Angular** - Agregar método en `bridge.service.ts` para enviar evento a Flutter
3. **Crear clase de evento en Flutter** - Agregar nuevo evento a `app_event.dart`
4. **Manejar evento en BLoC** - Registrar manejador en `app_bloc.dart`
5. **Actualizar estado** - Emitir nuevo estado en BLoC
6. **Enviar resultado a Angular** - Usar `bridge_service.dart` para enviar respuesta
7. **Actualizar UI de Angular** - Escuchar evento de Flutter en `app.component.ts`

Ejemplo: Agregar una funcionalidad de "logout" requeriría tocar todas las capas anteriores.
