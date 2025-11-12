# 🚀 START HERE - Guía de Inicio para Claude Code

> **Para cualquier nueva sesión de Claude:** Lee este archivo primero para obtener contexto completo del proyecto.

---

## 📌 Resumen Ejecutivo

**Proyecto:** PoC de Shell Orchestrator con Flutter + Angular
**Estado:** ✅ **100% FUNCIONAL EN ANDROID**
**Última actualización:** 2025-11-11 03:05 UTC
**Ubicación:** `/Users/juancarlossuarezmarin/Desktop/front/flutter+angular/`

---

## 🎯 Qué es este proyecto

Una **Proof of Concept (PoC)** que demuestra:
- ✅ **Flutter Shell** como orquestador con BLoC pattern
- ✅ **Angular MFE** como UI pura sin lógica de negocio
- ✅ **Comunicación bidireccional** via JavaScript Bridge
- ✅ **2 flujos completos** funcionando perfectamente

---

## 📚 Documentación Disponible

### 🔴 PRIMERO: Lee esto

| Archivo | Propósito | Cuándo leerlo |
|---------|-----------|---------------|
| **PROJECT_CONTEXT.md** | Contexto completo técnico del proyecto | Siempre al iniciar nueva sesión |
| **README.md** | Overview general del proyecto | Para entender arquitectura |

### 🟡 SEGUNDO: Documentación adicional

| Archivo | Propósito |
|---------|-----------|
| **RUN_NOW.md** | Guía rápida para ejecutar la PoC |
| **CHANGES_SUMMARY.md** | Historial completo de cambios |
| **BIOMETRY_REMOVED.md** | Detalles de simplificación realizada |

---

## ⚡ Quick Start (Para ejecutar AHORA)

### Terminal 1 - Angular
```bash
cd angular_mfe_ui
npm start
```

### Terminal 2 - Flutter
```bash
cd flutter_shell_orchestrator
flutter run -d emulator-5554  # ID del emulador Android
```

### Validar que funciona
1. ✅ Ve "Usuario Inicial" en la app
2. ✅ Escribe un nombre
3. ✅ Presiona "Actualizar Nombre"
4. ✅ El nombre se actualiza instantáneamente

---

## 🏗️ Arquitectura en 30 segundos

```
Flutter Shell (Cerebro)
   ├─ BLoC: Maneja estado
   ├─ BridgeService: Comunicación
   └─ InAppWebView
       └─ Angular MFE (Vista)
           └─ BridgeService: Comunicación
```

**Comunicación:**
- Flutter → Angular: `CustomEvent` via `evaluateJavascript()`
- Angular → Flutter: `flutter_inappwebview.callHandler()`

---

## 📂 Estructura de Archivos Clave

### Flutter
```
flutter_shell_orchestrator/lib/
├── core/bloc/
│   ├── app_bloc.dart         # Lógica de negocio
│   ├── app_state.dart        # userName, lastUpdated
│   └── app_event.dart        # UpdateNameEvent
├── core/services/
│   └── bridge_service.dart   # Comunicación Flutter ↔ Angular
└── presentation/screens/
    └── webview_host_screen.dart  # WebView host
```

### Angular
```
angular_mfe_ui/src/app/
├── app.component.ts          # UI Component
├── app.component.html        # Template
└── services/
    └── bridge.service.ts     # Comunicación Angular ↔ Flutter
```

---

## ⚠️ Información Crítica

### ✅ Lo que funciona
- Android emulator (100% funcional)
- Comunicación bidireccional completa
- BLoC pattern funcionando
- Hot reload en ambas apps

### ⚠️ Lo que NO funciona
- iOS (errores de compilación de Xcode - no crítico)
- Flutter Web (InAppWebView no soportado)

### 🔧 Problemas resueltos
- **Biometría eliminada** (~377 líneas de código removidas)
- **AppBridge corregido** (uso de `flutter_inappwebview.callHandler()`)
- **URL Android** (debe ser `10.0.2.2:4200` no `localhost`)

---

## 🔍 Búsqueda Rápida de Código

### Ver estado actual
```dart
// Flutter: lib/core/bloc/app_state.dart
class AppState {
  final String userName;
  final DateTime lastUpdated;
}
```

### Ver eventos
```dart
// Flutter: lib/core/bloc/app_event.dart
class UpdateNameEvent extends AppEvent {
  final String newName;
}
```

### Ver comunicación Flutter → Angular
```dart
// Flutter: lib/core/services/bridge_service.dart
Future<void> sendDataUpdate({required String userName})
```

### Ver comunicación Angular → Flutter
```typescript
// Angular: src/app/services/bridge.service.ts
public updateName(newName: string): void
```

---

## 📊 Flujos Implementados

### Flujo 1: Inicialización
```
Flutter init → BLoC emite estado → BridgeService → Angular actualiza UI
```

### Flujo 2: Actualizar Nombre
```
Angular input → callHandler → Flutter recibe → BLoC actualiza →
BridgeService envía → Angular actualiza UI
```

---

## 🐛 Debugging

### Ver logs de comunicación
```bash
# Android
adb logcat | grep -E "AppBridge|BridgeService|Angular|AppBloc"

# Flutter
flutter logs
```

### Logs clave de éxito
```
I/flutter: AppBridge: Mensaje recibido desde Web
I/flutter: AppBloc: Actualizando nombre a: [nombre]
I/chromium: Angular: Nombre de usuario actualizado: [nombre]
```

---

## 🛠️ Comandos Útiles

```bash
# Ver dispositivos
flutter devices

# Limpiar Flutter
flutter clean && flutter pub get

# Limpiar Angular
cd angular_mfe_ui && rm -rf node_modules && npm install

# Ver estado emulador Android
adb devices
```

---

## 💡 Tips para Claude

1. **Siempre lee PROJECT_CONTEXT.md primero** - Tiene TODO el contexto técnico
2. **La PoC está 100% funcional en Android** - No hay que arreglar nada crítico
3. **Biometría fue eliminada** - No la menciones ni intentes restaurarla
4. **iOS no compila** - Problema conocido, no es prioritario
5. **Usa `10.0.2.2:4200` en Android** - No `localhost`
6. **El código está limpio y probado** - Confía en lo que ves

---

## 🎯 Tareas Comunes

### Usuario pide "ejecutar la PoC"
→ Referir a **RUN_NOW.md** y ejecutar los 2 comandos

### Usuario pide "explicar arquitectura"
→ Referir a **README.md** sección Arquitectura

### Usuario pide "ver contexto completo"
→ Abrir y leer **PROJECT_CONTEXT.md**

### Usuario reporta "AppBridge no disponible"
→ Verificar `bridge.service.ts` usa `flutter_inappwebview.callHandler()`

### Usuario reporta "WebView en blanco en Android"
→ Verificar URL es `http://10.0.2.2:4200` no `localhost`

---

## 📞 Estado del Proyecto

| Aspecto | Estado | Última Verificación |
|---------|--------|---------------------|
| Compilación Flutter | ✅ OK | 2025-11-11 03:05 |
| Compilación Angular | ✅ OK | 2025-11-11 02:57 |
| Android Emulator | ✅ Corriendo | emulator-5554 |
| Comunicación Flutter → Web | ✅ Funcional | Probado |
| Comunicación Web → Flutter | ✅ Funcional | Probado |
| Logs de éxito | ✅ Visible | Ver arriba |

---

## 🔐 Información del Usuario

**Desarrollador:** Juan Carlos Suarez Marin
**Directorio:** `/Users/juancarlossuarezmarin/Desktop/front/flutter+angular/`
**Última sesión exitosa:** 2025-11-11 03:05 UTC

---

## 📋 Checklist para Nueva Sesión

Cuando inicies una nueva sesión de Claude:

- [ ] Lee este archivo (START_HERE.md)
- [ ] Lee PROJECT_CONTEXT.md para contexto completo
- [ ] Verifica que Angular esté corriendo (puerto 4200)
- [ ] Verifica que emulador Android esté activo
- [ ] Ejecuta `flutter devices` para ver dispositivos disponibles
- [ ] Lee los logs más recientes en la conversación anterior

---

## 🎓 Lo Más Importante

1. **El proyecto FUNCIONA** - No hay bugs críticos
2. **Android es la plataforma target** - iOS falla pero no es crítico
3. **2 flujos implementados** - Inicialización y actualización de nombre
4. **Biometría fue eliminada** - Simplificación intencional
5. **Toda la documentación está actualizada** - Confía en ella

---

**🚀 ¡Ahora estás listo para continuar el proyecto!**

Lee **PROJECT_CONTEXT.md** para información técnica detallada.
