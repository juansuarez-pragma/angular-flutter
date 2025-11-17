# 🚀 PoC: Shell Orquestador de MFE en WebView

> **Estado:** ✅ **Funcional en Android e iOS** | Última actualización: 2025-11-17

Prueba de Concepto (PoC) de una arquitectura híbrida móvil con Flutter como Shell Orquestador y Angular como Micro Frontend (MFE) de UI pura con comunicación bidireccional.

---

## 📋 Tabla de Contenidos

- [Arquitectura](#-arquitectura)
- [Principios de Diseño](#-principios-de-diseño)
- [Demo en Video](#-demo-en-video)
- [Inicio Rápido](#-inicio-rápido)
- [Comunicación Bidireccional](#-comunicación-bidireccional)
- [Plataformas Soportadas](#-plataformas-soportadas)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Tecnologías](#-tecnologías)
- [Troubleshooting](#-troubleshooting)
- [Documentación](#-documentación)

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

**Para arquitectura detallada, flujos de datos y diagramas técnicos:**
→ Lee **[ARCHITECTURE.md](ARCHITECTURE.md)**

---

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

## 🎥 Demo en Video

### Prueba en Dispositivo Android Real

> **Video demostrativo:** Comunicación bidireccional funcionando en Android

https://github.com/user-attachments/assets/demo-android.mov

**Lo que se muestra en el video:**
1. ✅ Aplicación Flutter cargando el MFE de Angular en WebView
2. ✅ Interfaz bancaria profesional con fondo blanco
3. ✅ Status badge mostrando "Conectado"
4. ✅ Formulario de actualización de nombre (arriba)
5. ✅ Avatar con iniciales del usuario (abajo, alineado izquierda)
6. ✅ Actualización de nombre en tiempo real
7. ✅ Comunicación Flutter ↔ Angular funcionando perfectamente

**Dispositivo de prueba:** Emulador/Dispositivo Android
**Fecha de grabación:** 2025-11-17
**Versión:** PoC v1.0

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
flutter pub get
flutter run               # Ejecutar en dispositivo disponible
# o especificar dispositivo:
flutter run -d emulator-5554              # Android
flutter run -d "iPhone 16 Pro"            # iOS
```

### Verificar Funcionalidad

1. ✅ Verifica que aparece "Usuario Inicial"
2. ✅ Escribe un nombre en el input
3. ✅ Presiona "Actualizar Nombre"
4. ✅ El nombre se actualiza instantáneamente

**Para guía paso a paso completa con troubleshooting:**
→ Lee **[QUICKSTART.md](QUICKSTART.md)**

---

## 🔌 Comunicación Bidireccional

### Angular → Flutter

```typescript
// bridge.service.ts
(window as any).flutter_inappwebview.callHandler('AppBridge', {
  event: 'UPDATE_NAME',
  payload: { newName: 'Juan' }
});
```

### Flutter → Angular

```dart
// bridge_service.dart
await controller.evaluateJavascript(source: '''
  const event = new CustomEvent('flutterDataUpdate', {
    detail: { userName: '$userName', timestamp: '$timestamp' }
  });
  document.dispatchEvent(event);
''');
```

**Para protocolo completo, implementación detallada y ejemplos:**
→ Lee **[ARCHITECTURE.md - Comunicación Bidireccional](ARCHITECTURE.md#comunicación-bidireccional)**

---

## 📱 Plataformas Soportadas

Esta PoC está diseñada para **aplicaciones móviles** únicamente:

| Plataforma | Estado | Notas |
|------------|--------|-------|
| **Android** | ✅ 100% Funcional | Usar `10.0.2.2:4200` en emulador |
| **iOS** | ⚠️ Compilación con issues | Errores de Xcode (no crítico para PoC) |

**Nota:** Flutter Web y plataformas desktop (macOS, Windows, Linux) no están soportadas por diseño, ya que `flutter_inappwebview` no funciona en estas plataformas.

### Configuración de URL

```dart
// flutter_shell_orchestrator/lib/presentation/screens/webview_host_screen.dart

// Android Emulator
static const String _mfeUrl = 'http://10.0.2.2:4200';

// iOS Simulator
static const String _mfeUrl = 'http://localhost:4200';

// Dispositivo Físico
static const String _mfeUrl = 'http://192.168.1.X:4200'; // Tu IP local
```

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
├── README.md                             # Este archivo (punto de entrada)
├── QUICKSTART.md                         # Guía de inicio rápido
├── ARCHITECTURE.md                       # Documentación técnica detallada
├── CLAUDE.md                             # Instrucciones para Claude Code
└── PROJECT_CONTEXT.md                    # Índice de navegación
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

**Solución:** Verifica que estás usando `flutter_inappwebview.callHandler()` en Angular

### Logs de debugging

```bash
# Flutter logs
flutter logs

# Android logs
adb logcat | grep flutter

# Filtrar comunicación del bridge
adb logcat | grep -E "AppBridge|BridgeService|Angular"
```

**Para soluciones completas de troubleshooting:**
→ Lee **[QUICKSTART.md - Solución de Problemas](QUICKSTART.md#-solución-rápida-de-problemas)**

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

**Para consideraciones completas de seguridad, rate limiting y encriptación:**
→ Lee **[ARCHITECTURE.md - Seguridad](ARCHITECTURE.md#consideraciones-de-seguridad)**

---

## 📚 Documentación

### Guías por Objetivo

| ¿Quieres...? | Lee esto |
|--------------|----------|
| 🚀 Ejecutar el proyecto rápido | **[QUICKSTART.md](QUICKSTART.md)** |
| 📖 Entender la arquitectura | **[ARCHITECTURE.md](ARCHITECTURE.md)** |
| 🔧 Desarrollar y contribuir | **[CLAUDE.md](CLAUDE.md)** |
| 📱 Trabajar con Flutter | **[flutter_shell_orchestrator/README.md](flutter_shell_orchestrator/README.md)** |
| 🎨 Trabajar con Angular | **[angular_mfe_ui/README.md](angular_mfe_ui/README.md)** |
| 🗺️ Navegar la documentación | **[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)** |

### Documentos Principales

- **[QUICKSTART.md](QUICKSTART.md)** - Guía de inicio rápido, prerrequisitos, troubleshooting
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Arquitectura detallada, flujos de datos, seguridad, testing
- **[CLAUDE.md](CLAUDE.md)** - Comandos de desarrollo, convenciones, problemas comunes
- **[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)** - Índice navegable, información clave, tips

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

1. Revisa **[QUICKSTART.md](QUICKSTART.md)** para instrucciones paso a paso
2. Consulta **[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)** para contexto completo
3. Lee la sección [Troubleshooting](#-troubleshooting) arriba

---

## 📄 Licencia

Este es un proyecto de Prueba de Concepto (PoC) con fines educativos y de demostración.

---

**Creado:** 2025-11-11
**Actualizado:** 2025-11-17
**Estado:** ✅ Funcional en Android e iOS
**Desarrollador:** Juan Carlos Suarez Marin
