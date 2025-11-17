# 🚀 PoC: Shell Orquestador de MFE en WebView

> **Estado:** ✅ **100% FUNCIONAL EN ANDROID** | Última actualización: 2025-11-11

Prueba de Concepto (PoC) completa de una arquitectura híbrida móvil con Flutter como Shell Orquestador y Angular como Micro Frontend (MFE) de UI pura con comunicación bidireccional.

---

## 📋 Arquitectura

```
┌─────────────────────────────────────────┐
│      Flutter Shell Orquestador          │
│  ┌────────────────────────────────┐     │
│  │  - flutter_bloc (Estado)       │     │
│  │  - go_router (Navegación)      │     │
│  │  - dio (Red)                   │     │
│  └────────────────────────────────┘     │
│              ↕ JavaScript Bridge        │
│  ┌────────────────────────────────┐     │
│  │   flutter_inappwebview         │     │
│  │  ┌──────────────────────────┐  │     │
│  │  │   Angular MFE UI         │  │     │
│  │  │  - UI Pura               │  │     │
│  │  │  - Sin lógica negocio    │  │     │
│  │  │  - Sin estado complejo   │  │     │
│  │  └──────────────────────────┘  │     │
│  └────────────────────────────────┘     │
└─────────────────────────────────────────┘
```

## 🎯 Principios de Diseño

### Flutter Shell (Cerebro)
- ✅ Maneja toda la lógica de negocio
- ✅ Gestiona el estado con BLoC
- ✅ Proporciona datos al MFE
- ✅ Controla funcionalidades nativas

### Angular MFE (Vista Tonta)
- ✅ Solo contiene UI y presentación
- ✅ NO tiene lógica de negocio
- ✅ NO maneja estado complejo
- ✅ NO hace llamadas HTTP
- ✅ Delega todo al Shell vía puente JavaScript

---

## 🚀 Inicio Rápido

### Prerrequisitos

- Flutter SDK 3.2.0+
- Node.js 18+
- Emulador Android o iOS

### Ejecutar la PoC (2 comandos)

**Terminal 1 - Angular MFE:**
```bash
cd angular_mfe_ui
npm install
npm start
```

**Terminal 2 - Flutter Shell:**
```bash
cd flutter_shell_orchestrator
flutter run -d emulator-5554  # Android
# o
flutter run -d "iPhone 16 Pro"  # iOS
```

### Probar Funcionalidad

1. ✅ Verifica que aparece "Usuario Inicial"
2. ✅ Escribe un nombre en el input
3. ✅ Presiona "Actualizar Nombre"
4. ✅ El nombre se actualiza instantáneamente

---

## 🔌 Comunicación Bidireccional

### Angular → Flutter

```typescript
// En Angular (bridge.service.ts)
(window as any).flutter_inappwebview.callHandler('AppBridge', {
  event: 'UPDATE_NAME',
  payload: { newName: 'Juan' }
});
```

### Flutter → Angular

```dart
// En Flutter (bridge_service.dart)
await controller.evaluateJavascript(source: '''
  const event = new CustomEvent('flutterDataUpdate', {
    detail: { userName: '$userName', timestamp: '$timestamp' }
  });
  document.dispatchEvent(event);
''');
```

---

## 📊 Flujos Implementados

### Flujo 1: Inicialización (Flutter → Web)

```
Flutter (AppState inicial)
  → BlocListener detecta estado
  → BridgeService.sendDataUpdate()
  → evaluateJavascript('flutterDataUpdate')
  → Angular recibe evento
  → UI actualiza con "Usuario Inicial" ✅
```

### Flujo 2: Actualizar Nombre (Web ↔ Flutter ↔ Web)

```
Angular input
  → bridgeService.updateName()
  → flutter_inappwebview.callHandler()
  → Flutter recibe mensaje
  → appBloc.add(UpdateNameEvent)
  → emit nuevo estado
  → BlocListener detecta cambio
  → BridgeService.sendDataUpdate()
  → Angular recibe evento
  → UI actualiza con nuevo nombre ✅
```

---

## 📱 Plataformas Soportadas

Esta PoC está diseñada para **aplicaciones móviles** únicamente:

| Plataforma | Estado | Notas |
|------------|--------|-------|
| **Android** | ✅ 100% Funcional | Usar `10.0.2.2:4200` en emulador |
| **iOS** | ⚠️ Compilación falla | Errores de Xcode (no crítico para PoC) |

**Nota:** Flutter Web y plataformas desktop (macOS, Windows, Linux) no están soportadas por diseño, ya que `InAppWebView` no funciona en estas plataformas.

---

## 📁 Estructura del Proyecto

```
flutter+angular/
├── flutter_shell_orchestrator/           # Shell de Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── core/
│   │   │   ├── bloc/                     # BLoC pattern
│   │   │   │   ├── app_bloc.dart
│   │   │   │   ├── app_event.dart
│   │   │   │   └── app_state.dart
│   │   │   └── services/
│   │   │       └── bridge_service.dart   # Comunicación
│   │   └── presentation/
│   │       └── screens/
│   │           └── webview_host_screen.dart
│   └── pubspec.yaml
│
├── angular_mfe_ui/                       # Angular MFE
│   ├── src/
│   │   └── app/
│   │       ├── app.component.ts
│   │       ├── app.component.html
│   │       ├── app.component.css
│   │       └── services/
│   │           └── bridge.service.ts     # Comunicación
│   └── package.json
│
├── PROJECT_CONTEXT.md                    # 📄 Contexto completo
├── CHANGES_SUMMARY.md                    # Historial de cambios
├── ARCHITECTURE.md                       # Documentación de arquitectura
└── RUN_NOW.md                            # Guía rápida
```

---

## 🔧 Tecnologías

### Flutter
- **flutter_bloc** `^8.1.3` - State management
- **equatable** `^2.0.5` - Immutable state
- **go_router** `^13.0.0` - Navigation
- **flutter_inappwebview** `^6.0.0` - WebView con JavaScript bridge
- **dio** `^5.4.0` - HTTP client

### Angular
- **Angular** `17+` - Framework
- **Standalone Components** - Sin NgModules
- **RxJS** - Reactive programming
- **TypeScript** - Type safety

---

## 🐛 Troubleshooting

### WebView en blanco

```bash
# Verificar que Angular esté corriendo
curl http://localhost:4200

# Android: Usar 10.0.2.2 en lugar de localhost
# iOS: localhost funciona correctamente
```

### AppBridge no disponible

```
Angular: AppBridge no disponible (ejecutando fuera de Flutter)
```

**Solución:** Verifica que estás usando `flutter_inappwebview.callHandler()` en lugar de `AppBridge.postMessage()`

### Logs de debugging

```bash
# Flutter logs
flutter logs

# Android logs
adb logcat | grep flutter

# Filtrar comunicación
adb logcat | grep -E "AppBridge|BridgeService|Angular"
```

---

## 📝 Notas Importantes

### URL del MFE según plataforma

```dart
// Android Emulator
static const String _mfeUrl = 'http://10.0.2.2:4200';

// iOS Simulator
static const String _mfeUrl = 'http://localhost:4200';

// Dispositivo Real
static const String _mfeUrl = 'http://192.168.1.X:4200'; // Tu IP local
```

---

## 🔒 Seguridad

### Validación de Mensajes en Flutter

```dart
controller.addJavaScriptHandler(
  handlerName: 'AppBridge',
  callback: (args) {
    // ✅ Validar estructura
    if (args.isEmpty) return {'error': 'No data'};

    // ✅ Validar tipo de evento
    final event = payload['event'];
    if (!['UPDATE_NAME'].contains(event)) {
      return {'error': 'Unknown event'};
    }

    // ✅ Procesar solo eventos conocidos
  }
);
```

### Verificación en Angular

```typescript
// ✅ Verificar disponibilidad del bridge
private isAppBridgeAvailable(): boolean {
  return typeof (window as any).flutter_inappwebview !== 'undefined';
}

// ✅ Manejo de errores
try {
  (window as any).flutter_inappwebview.callHandler('AppBridge', message);
} catch (error) {
  console.error('Error comunicándose con Flutter', error);
}
```

---

## 📚 Documentación

- **PROJECT_CONTEXT.md** - Contexto completo del proyecto para Claude
- **CHANGES_SUMMARY.md** - Resumen detallado de cambios
- **ARCHITECTURE.md** - Arquitectura detallada y diagramas de flujo de datos
- **RUN_NOW.md** - Guía de ejecución rápida

---

## 🎓 Conceptos Demostrados

1. **Shell Orchestrator Pattern** - Separación clara entre shell y MFE
2. **BLoC Pattern** - State management robusto en Flutter
3. **Micro Frontend** - UI aislada sin lógica de negocio
4. **JavaScript Bridge** - Comunicación bidireccional nativo ↔ web
5. **Reactive Updates** - Flujo de datos unidireccional

---

## 🚀 Próximos Pasos

- [ ] Resolver problemas de compilación en iOS
- [ ] Agregar más flujos de comunicación
- [ ] Implementar navegación entre múltiples MFEs
- [ ] Agregar tests unitarios y de integración
- [ ] Optimizar performance del WebView
- [ ] Implementar cache de MFEs

---

## 📞 Soporte

**¿Problemas ejecutando la PoC?**

1. Revisa `RUN_NOW.md` para instrucciones paso a paso
2. Verifica `PROJECT_CONTEXT.md` para contexto completo
3. Consulta la sección Troubleshooting arriba

---

## 📄 Licencia

Este es un proyecto de Prueba de Concepto (PoC) con fines educativos y de demostración.

---

**Creado:** 2025-11-11
**Estado:** ✅ Funcional en Android
**Última prueba exitosa:** 2025-11-11 03:05 UTC

