# 🚀 Ejecutar PoC Ahora (Sin Biometría)

## ⚡ Inicio Rápido - 2 Comandos

### Terminal 1: Angular MFE

```bash
cd angular_mfe_ui
npm install
npm start
```

✅ Espera ver: `✔ Compiled successfully` en `http://localhost:4200`

### Terminal 2: Flutter Shell

```bash
cd flutter_shell_orchestrator
flutter run -d chrome
```

✅ Espera ver: Aplicación Flutter con Angular cargado en el WebView

---

## 🎯 Probar Funcionalidad

Una vez que ambas apps estén corriendo:

### 1. Verificar Conexión
- Badge verde "🟢 Conectado a Flutter"

### 2. Ver Nombre Inicial (Flutter → Web)
- Debe aparecer "Usuario Inicial" en la UI

### 3. Actualizar Nombre (Web ↔ Flutter ↔ Web)
1. Escribir un nombre en el input
2. Presionar "Actualizar Nombre"
3. ✅ El nombre se actualiza instantáneamente

**Esto demuestra:**
- Angular → Flutter: Mensaje enviado
- Flutter → BLoC: Estado actualizado
- Flutter → Angular: Notificación enviada
- Angular → UI: Renderizado actualizado

---

## 📱 Plataformas Disponibles

### Chrome (Recomendado)
```bash
flutter run -d chrome
```
- ⚡ Compilación instantánea
- 🔥 Hot reload súper rápido
- 🛠️ DevTools completos

### macOS
```bash
flutter run -d macos
```
- 📱 Aplicación nativa de escritorio
- ✅ Más rápido que iOS

### Web
```bash
flutter run -d web-server
```
- 🌐 Servidor web en puerto 8080

---

## 🔍 Ver Logs

### Logs de Flutter
- Se muestran automáticamente en la terminal donde ejecutaste `flutter run`
- Buscar: `AppBridge:`, `BridgeService:`, `AppBloc:`

### Logs de Angular
- Abrir DevTools en Chrome: F12 o Cmd+Option+I
- Ir a Console
- Buscar: `Angular:`, `flutterDataUpdate`

---

## ✅ Checklist de Funcionamiento

- [ ] Angular compiló exitosamente en `localhost:4200`
- [ ] Flutter está corriendo (en Chrome/macOS)
- [ ] Badge muestra "🟢 Conectado a Flutter"
- [ ] Aparece "Usuario Inicial" en la UI
- [ ] Al escribir un nombre y presionar "Actualizar", el nombre cambia
- [ ] Los logs muestran mensajes de comunicación

---

## 🐛 Solución de Problemas

### Angular no inicia
```bash
cd angular_mfe_ui
rm -rf node_modules
npm install
npm start
```

### Flutter no compila
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### WebView muestra pantalla en blanco
- Verificar que Angular esté corriendo en `localhost:4200`
- Verificar logs de Flutter
- Refrescar con hot reload: presiona `r` en la terminal de Flutter

### No aparece el nombre
- Esperar unos segundos (a veces tarda en cargar)
- Verificar logs de comunicación
- Presionar `r` para hot reload

---

## 💡 Tips

- **Hot Reload en Flutter:** Presiona `r` en la terminal
- **DevTools:** Presiona `d` en la terminal de Flutter cuando esté en Chrome
- **Ver solo Angular:** Abre `http://localhost:4200` en navegador normal
- **Cerrar todo:** Ctrl+C en ambas terminales

---

## 🎉 ¡Todo Funcionando!

Si llegaste hasta aquí y todo funciona:

```
┌────────────────────────────────────────┐
│  🎉 ¡FELICIDADES!                      │
│                                        │
│  Tienes una arquitectura híbrida      │
│  Flutter + Angular funcionando         │
│  con comunicación bidireccional        │
│  completa.                             │
│                                        │
│  🚀 Explora el código                  │
│  🔧 Modifica algo                      │
│  📚 Lee la documentación               │
└────────────────────────────────────────┘
```

---

## 📚 Más Información

- `BIOMETRY_REMOVED.md` - Detalles de la simplificación
- `README.md` - Documentación completa del proyecto
- `ARCHITECTURE.md` - Arquitectura detallada
- `QUICKSTART.md` - Guía de inicio rápido original

---

**Siguiente paso:** Modifica el nombre inicial en `lib/core/bloc/app_state.dart` y observa cómo se actualiza automáticamente en Angular! 🎯
