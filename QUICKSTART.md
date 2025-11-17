# ⚡ Guía de Inicio Rápido

## 🎯 Objetivo

Tener ambos repositorios ejecutándose y comunicándose en **5 minutos**.

## 📋 Checklist de Prerrequisitos

Antes de comenzar, asegúrate de tener:

```bash
# Flutter
flutter --version  # ≥ 3.2.0
dart --version     # ≥ 3.0.0

# Angular
node --version     # ≥ 18.0.0
npm --version      # ≥ 9.0.0
ng version         # ≥ 17.0.0 (o instalar: npm install -g @angular/cli)

# Verificar dispositivos
flutter devices    # Al menos 1 disponible
```

## 🚀 Pasos de Instalación

### Terminal 1: Angular MFE

```bash
# 1. Navegar al proyecto
cd angular_mfe_ui

# 2. Instalar dependencias
npm install

# 3. Iniciar servidor de desarrollo
npm start

# ✅ Debes ver: "Angular live Development Server is listening on localhost:4200"
```

### Terminal 2: Flutter Shell

```bash
# 1. Navegar al proyecto
cd flutter_shell_orchestrator

# 2. Instalar dependencias
flutter pub get

# 3. Verificar dispositivos disponibles
flutter devices

# 4. Ejecutar (usa el device ID de tu preferencia)
flutter run

# Para ejecutar en un dispositivo específico:
# flutter run -d <device-id>

# Ejemplos:
# flutter run -d chrome          # Web
# flutter run -d macos           # macOS
# flutter run -d emulator-5554   # Android Emulator
# flutter run -d iPhone-15       # iOS Simulator
```

## ✅ Verificación Rápida

Una vez que ambas apps estén ejecutándose:

### 1. Verificar Conexión
- En la app de Flutter, deberías ver el contenido de Angular cargado
- El badge en Angular debe mostrar "🟢 Conectado a Flutter"

### 2. Probar Flujo 1: Inicialización
- Al cargar, deberías ver "Usuario Inicial" en la UI de Angular
- **✅ Si lo ves, Flutter → Angular funciona**

### 3. Probar Flujo 2: Actualizar Nombre
1. En el input de Angular, escribe "Mi Nombre"
2. Presiona "Actualizar Nombre"
3. Deberías ver "Mi Nombre" actualizado instantáneamente
- **✅ Si funciona, Angular → Flutter → Angular funciona**

## 🐛 Solución Rápida de Problemas

### Problema: "Cannot connect to localhost:4200"

**Causa:** Angular no está ejecutándose

**Solución:**
```bash
cd angular_mfe_ui
npm start
# Espera a ver: "✔ Compiled successfully"
```

### Problema: "No devices available"

**Causa:** No hay emuladores/dispositivos conectados

**Solución:**
```bash
# Para iOS Simulator
open -a Simulator

# Para Android Emulator
emulator -avd <nombre-del-avd>

# O usar Chrome (más rápido para pruebas)
flutter run -d chrome
```

### Problema: "AppBridge is undefined"

**Causa:** WebView aún no cargó completamente

**Solución:**
- Espera unos segundos
- Verifica logs de Flutter: "AppBridge JavaScriptHandler registrado"
- Recarga la app: `r` en la terminal de Flutter

## 📱 Ejecución en Dispositivo Real

### Para usar IP local (en lugar de localhost):

**1. Obtener tu IP local:**

```bash
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows
ipconfig | findstr IPv4
```

**2. Iniciar Angular con host accesible:**

```bash
npm start -- --host 0.0.0.0
```

**3. Actualizar URL en Flutter:**

```dart
// lib/presentation/screens/webview_host_screen.dart
static const String _mfeUrl = 'http://192.168.1.XXX:4200';
```

**4. Reconstruir Flutter:**

```bash
flutter run
```

## 🔍 Comandos de Debugging

### Ver logs de Flutter:

```bash
# En la terminal donde corre Flutter, presiona:
# r - Hot reload
# R - Hot restart
# q - Quit
# s - Save screenshot
```

### Ver logs de Angular:

```bash
# Abrir DevTools del navegador (si usas Chrome)
flutter run -d chrome

# En Chrome DevTools:
# Console → Ver logs de Angular
# Network → Ver requests
```

### Ver logs del WebView (en dispositivo móvil):

**iOS:**
- Safari → Develop → [Device Name] → [App Name]

**Android:**
```bash
adb logcat | grep -i "webview\|console"
```

## 📊 Verificación de Comunicación

### Comando útil: Ver todos los logs

**Flutter:**
```bash
# Ver todos los logs relacionados con el puente
flutter logs | grep -E "AppBridge|BridgeService|WebView"
```

**Angular (en Chrome DevTools):**
```javascript
// Ejecutar en consola para ver listeners
getEventListeners(document)

// Ver si AppBridge existe
console.log(window.AppBridge)
```

## 🎉 Todo Funciona, ¿Ahora Qué?

### Explora el código:

**Flutter:**
```bash
# Ver el BLoC principal
cat flutter_shell_orchestrator/lib/core/bloc/app_bloc.dart

# Ver el puente de comunicación
cat flutter_shell_orchestrator/lib/core/services/bridge_service.dart

# Ver la pantalla del WebView
cat flutter_shell_orchestrator/lib/presentation/screens/webview_host_screen.dart
```

**Angular:**
```bash
# Ver el servicio de comunicación
cat angular_mfe_ui/src/app/services/bridge.service.ts

# Ver el componente principal
cat angular_mfe_ui/src/app/app.component.ts
```

### Modifica algo:

**Cambiar el nombre inicial (Flutter):**
```dart
// lib/core/bloc/app_state.dart
factory AppState.initial() {
  return AppState(
    userName: 'Tu Nombre Aquí',  // ← Cambia esto
    isAuthenticated: false,
    lastUpdated: DateTime.now(),
  );
}
```

```bash
# Hot reload
flutter run
# Presiona 'r'
```

**Cambiar el diseño (Angular):**
```css
/* src/app/app.component.css */
.header {
  background: linear-gradient(135deg, #FF6B6B 0%, #4ECDC4 100%); /* ← Cambia esto */
}
```

Angular se recargará automáticamente.

## 📚 Próximos Pasos

1. **Lee la documentación detallada:**
   - [README.md](README.md) - Guía completa
   - [ARCHITECTURE.md](ARCHITECTURE.md) - Arquitectura detallada

2. **Experimenta con el código:**
   - Agrega un nuevo evento al puente
   - Agrega una nueva funcionalidad nativa
   - Mejora el diseño de Angular

3. **Implementa nuevas características:**
   - Cámara
   - Geolocalización
   - Almacenamiento local
   - Notificaciones

## 💡 Tips

- **Hot Reload** es tu amigo en Flutter (presiona `r`)
- **Angular auto-reload** es automático al guardar
- Usa **Chrome DevTools** para debugging de Angular
- Los logs son tu mejor herramienta de debug
- Mantén ambas terminales visibles

## 🆘 ¿Necesitas Ayuda?

1. Verifica los logs primero
2. Lee la sección de Troubleshooting en [README.md](README.md)
3. Revisa que todos los prerrequisitos estén instalados
4. Asegúrate de que ambos servidores estén corriendo

## ✨ ¡Eso es Todo!

Si llegaste hasta aquí y todo funciona:

```
┌─────────────────────────────────────┐
│  ✅ ¡Felicidades!                   │
│                                      │
│  Tienes una arquitectura híbrida    │
│  Flutter + Angular funcionando      │
│  con comunicación bidireccional     │
│  completa.                          │
│                                      │
│  🚀 Happy Coding!                   │
└─────────────────────────────────────┘
```
