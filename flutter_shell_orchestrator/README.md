# Flutter Shell Orquestador

Shell orquestador de micro frontends (MFE) en WebView construido con Flutter.

## Características

- Gestión de estado con `flutter_bloc`
- Navegación con `go_router`
- WebView nativo con `flutter_inappwebview`
- Autenticación biométrica con `local_auth`
- Comunicación bidireccional con MFE de Angular

## Arquitectura

Este shell actúa como el "cerebro" de la aplicación:
- Maneja toda la lógica de negocio
- Orquesta funcionalidades nativas (biometría, almacenamiento, etc.)
- Se comunica con el MFE de Angular vía puente JavaScript

## Requisitos

- Flutter SDK 3.2.0 o superior
- Dart 3.0 o superior
- Android Studio / Xcode para desarrollo móvil
- MFE de Angular corriendo en `http://localhost:4200`

## Instalación

1. Instalar dependencias:
```bash
flutter pub get
```

2. Verificar configuración:
```bash
flutter doctor
```

3. Ejecutar en dispositivo/emulador:
```bash
flutter run
```

## Configuración Nativa

### iOS
- Permisos de Face ID configurados en `Info.plist`
- Acceso a localhost permitido para desarrollo

### Android
- Permisos de biometría en `AndroidManifest.xml`
- Tráfico cleartext habilitado para localhost

## Contrato de Comunicación

### De MFE a Flutter (AppBridge)
```javascript
window.AppBridge.postMessage(JSON.stringify({
  event: 'UPDATE_NAME',
  payload: { newName: '...' }
}));

window.AppBridge.postMessage(JSON.stringify({
  event: 'BIOMETRIC_REQUEST'
}));
```

### De Flutter a MFE (CustomEvents)
```javascript
document.addEventListener('flutterDataUpdate', (event) => {
  console.log(event.detail.userName);
});

document.addEventListener('biometricResult', (event) => {
  console.log(event.detail.success, event.detail.error);
});
```

## Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── app.dart                     # Widget raíz
├── config/
│   └── router_config.dart       # Configuración de rutas
├── core/
│   ├── bloc/                    # Gestión de estado
│   │   ├── app_bloc.dart
│   │   ├── app_event.dart
│   │   └── app_state.dart
│   └── services/                # Servicios
│       ├── bridge_service.dart  # Puente de comunicación
│       └── biometric_service.dart
└── presentation/
    └── screens/
        └── webview_host_screen.dart
```

## Flujos Implementados

1. **Flujo Inicial (Flutter → Web)**: Envía userName inicial al cargar
2. **Actualizar Nombre (Web → Flutter → Web)**: MFE actualiza nombre en BLoC
3. **Biometría (Bucle Completo)**: Solicitud → Autenticación → Respuesta

## Desarrollo

Para hacer cambios al código:
```bash
flutter analyze
flutter test
```

## Producción

Para generar release:
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Solución de Problemas

- **WebView no carga**: Verificar que el MFE esté corriendo en `localhost:4200`
- **Biometría falla**: Verificar permisos nativos y configuración del dispositivo
- **Comunicación no funciona**: Revisar logs de consola del WebView
