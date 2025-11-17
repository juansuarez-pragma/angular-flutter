# 📋 Contexto del Proyecto - Shell Orchestrator PoC

## 🎯 Resumen Ejecutivo

**Nombre:** Flutter Shell Orchestrator + Angular MFE
**Tipo:** Proof of Concept (PoC)
**Objetivo:** Demostrar comunicación bidireccional entre un Shell Orquestador Flutter y un Micro Frontend Angular
**Estado:** ✅ **Funcional en Android e iOS**
**Última actualización:** 2025-11-17

---

## 📐 Arquitectura en 60 Segundos

```
┌─────────────────────────────────────────┐
│    Flutter Shell (Cerebro)              │
│    ├─ BLoC Pattern (Estado)             │
│    ├─ go_router (Navegación)            │
│    └─ flutter_inappwebview (WebView)    │
│              ↕ JavaScript Bridge        │
│    ┌────────────────────────────────┐   │
│    │   Angular MFE (Vista)          │   │
│    │   ├─ UI Pura                   │   │
│    │   ├─ RxJS (Reactivo)           │   │
│    │   └─ BridgeService             │   │
│    └────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

**Principio fundamental:** Flutter maneja lógica de negocio, Angular solo renderiza UI.

---

## 📁 Estructura del Proyecto

```
flutter+angular/
├── flutter_shell_orchestrator/    # Shell Flutter (Android/iOS)
├── angular_mfe_ui/                 # MFE Angular (UI pura)
├── README.md                       # Punto de entrada principal
├── QUICKSTART.md                   # Guía de inicio rápido
├── ARCHITECTURE.md                 # Documentación técnica detallada
├── CLAUDE.md                       # Instrucciones para Claude Code
└── PROJECT_CONTEXT.md              # Este archivo (índice navegable)
```

---

## 📚 Guía de Navegación

### ¿Quieres...?

#### 🚀 Ejecutar el proyecto rápidamente
→ Lee **[QUICKSTART.md](QUICKSTART.md)**
- Prerrequisitos
- Comandos de ejecución (2 terminales)
- Troubleshooting básico

#### 📖 Entender la arquitectura completa
→ Lee **[ARCHITECTURE.md](ARCHITECTURE.md)**
- Componentes detallados
- Protocolo de comunicación
- Flujos de datos paso a paso
- Seguridad y performance
- Testing y monitoreo

#### 🔧 Desarrollar y contribuir
→ Lee **[CLAUDE.md](CLAUDE.md)**
- Comandos de desarrollo
- Convenciones del proyecto
- Flujo de trabajo
- Problemas comunes

#### 📱 Trabajar con Flutter Shell
→ Lee **[flutter_shell_orchestrator/README.md](flutter_shell_orchestrator/README.md)**
- Configuración específica de Flutter
- BLoC pattern
- Bridge service
- Comandos de build

#### 🎨 Trabajar con Angular MFE
→ Lee **[angular_mfe_ui/README.md](angular_mfe_ui/README.md)**
- Configuración específica de Angular
- Principios de diseño (UI pura)
- Bridge service
- Modo standalone

---

## 🔑 Información Clave

### Plataformas Soportadas

| Plataforma | Estado | Notas |
|------------|--------|-------|
| **Android** | ✅ 100% Funcional | Usar `10.0.2.2:4200` en emulador |
| **iOS** | ⚠️ Compilación con issues | Errores Xcode (no crítico) |

**Nota:** Solo plataformas móviles. `flutter_inappwebview` no funciona en web ni desktop.

### Stack Tecnológico

**Flutter:**
- `flutter_bloc: ^8.1.3` - Estado
- `go_router: ^13.0.0` - Navegación
- `flutter_inappwebview: ^6.0.0` - WebView
- `dio: ^5.4.0` - HTTP

**Angular:**
- `@angular/core: ^17.0.0` - Framework
- `rxjs: ~7.8.0` - Programación reactiva
- Standalone Components (sin NgModules)

### Flujos Implementados

1. **Inicialización (Flutter → Web)**
   Flutter envía `userName` inicial cuando el WebView carga

2. **Actualizar Nombre (Web ↔ Flutter ↔ Web)**
   Angular envía nuevo nombre → Flutter actualiza BLoC → Notifica a Angular

---

## 🚀 Inicio Rápido (2 Comandos)

**Terminal 1 - Angular:**
```bash
cd angular_mfe_ui && npm install && npm start
```

**Terminal 2 - Flutter:**
```bash
cd flutter_shell_orchestrator && flutter pub get && flutter run
```

✅ Verifica que "Usuario Inicial" aparece en la UI
✅ Cambia el nombre y verifica que se actualiza

---

## 🔧 Comandos Esenciales

### Flutter
```bash
flutter devices           # Ver dispositivos disponibles
flutter run               # Ejecutar en dispositivo disponible
flutter run -d <id>       # Ejecutar en dispositivo específico
flutter logs              # Ver logs en tiempo real
flutter clean             # Limpiar build
```

### Angular
```bash
npm start                 # Servidor de desarrollo (port 4200)
npm run build             # Build de producción
npm test                  # Ejecutar tests
```

---

## ⚠️ Troubleshooting Rápido

### "Cannot connect to localhost:4200"
- Verifica que Angular esté corriendo: `npm start`
- En Android emulator usa `10.0.2.2:4200` en el código

### "AppBridge is undefined"
- El WebView aún no cargó completamente
- Espera unos segundos o presiona `r` (hot reload)

### "No devices available"
- Ejecuta `flutter devices` para ver opciones
- Inicia un emulador/simulador

**Más soluciones:** Ver [QUICKSTART.md - Troubleshooting](QUICKSTART.md#-solución-rápida-de-problemas)

---

## 🎓 Conceptos Importantes

### 1. Shell Orchestrator Pattern
Flutter es el "cerebro" que controla todo. Angular es solo una "vista tonta" que renderiza UI.

### 2. JavaScript Bridge
Comunicación bidireccional entre Flutter (nativo) y Angular (web):
- **Flutter → Angular:** `evaluateJavascript()` + `CustomEvent`
- **Angular → Flutter:** `callHandler()` + Message passing

### 3. BLoC Pattern (Flutter)
```
Event → BLoC → State Change → UI Update → Bridge Notification
```

### 4. Micro Frontend (Angular)
Angular MFE **NUNCA** debe:
- ❌ Tener lógica de negocio
- ❌ Hacer llamadas HTTP
- ❌ Gestionar estado complejo
- ✅ Solo renderizar UI y comunicarse con Flutter

---

## 📞 Archivos de Configuración Clave

### URLs según plataforma
```dart
// flutter_shell_orchestrator/lib/presentation/screens/webview_host_screen.dart

// Android Emulator
static const String _mfeUrl = 'http://10.0.2.2:4200';

// iOS Simulator
static const String _mfeUrl = 'http://localhost:4200';

// Dispositivo físico
static const String _mfeUrl = 'http://192.168.1.X:4200'; // IP local
```

### Permisos nativos
- **Android:** `AndroidManifest.xml` - Permiso `INTERNET`, `usesCleartextTraffic`
- **iOS:** `Info.plist` - `NSAppTransportSecurity` para localhost

---

## 🔐 Consideraciones de Seguridad

Ver detalles completos en [ARCHITECTURE.md - Seguridad](ARCHITECTURE.md#consideraciones-de-seguridad)

- ✅ Validación de mensajes en Flutter
- ✅ Whitelist de eventos permitidos
- ⚠️ Implementar rate limiting en producción
- ⚠️ Encriptar datos sensibles en producción

---

## 🔜 Próximos Pasos Potenciales

- Resolver issues de compilación iOS
- Agregar más flujos de comunicación
- Implementar navegación entre múltiples MFEs
- Agregar tests automatizados
- Performance optimization
- State persistence

---

## 💡 Tips para Desarrolladores

1. **Siempre inicia Angular primero** antes de ejecutar Flutter
2. **En emulador Android** usa `10.0.2.2` no `localhost`
3. **Hot reload** (presiona `r`) funciona en ambas apps
4. **Los logs** son tu mejor amigo para debugging
5. **El bridge es asíncrono** - maneja errores apropiadamente

---

## 📊 Estado del Proyecto

### ✅ Funcionando
- Compilación Flutter en Android/iOS
- Carga de Angular en WebView
- Comunicación bidireccional completa
- Actualización reactiva de UI
- BLoC pattern funcionando
- Hot reload en ambas apps

### ⚠️ Conocido pero No Crítico
- iOS puede tener errores de compilación de Xcode
- Solo plataformas móviles soportadas (por diseño)

---

## 📝 Historial de Cambios

**2025-11-17:**
- Eliminadas plataformas desktop/web (linux, macos, windows)
- Actualizado `.metadata` para reflejar solo Android/iOS
- Unificada documentación eliminando duplicaciones
- Eliminado `RUN_NOW.md` (contenido en QUICKSTART)

**2025-11-11:**
- Eliminadas referencias a biometría
- Reducido MVP a solo actualización de nombre
- Proyecto funcional al 100% en Android

---

**Creado:** 2025-11-11
**Actualizado:** 2025-11-17
**Desarrollador:** Juan Carlos Suarez Marin
