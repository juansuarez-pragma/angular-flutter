# Angular MFE UI

Micro Frontend (MFE) de UI pura construido con Angular para ser orquestado por el Shell de Flutter.

## Características

- Angular 17 con Standalone Components
- UI pura sin lógica de negocio
- Comunicación bidireccional con Flutter Shell
- Arquitectura de "vista tonta"

## Principios de Diseño

Este MFE sigue estrictamente estos principios:

✅ **SÍ contiene:**
- Componentes de UI
- Estilos y presentación visual
- Manejo de interacciones de usuario
- Envío de mensajes al Shell

❌ **NO contiene:**
- Lógica de negocio
- Gestión de estado compleja (NgRx, etc.)
- Llamadas HTTP/APIs
- Servicios de datos

## Requisitos

- Node.js 18 o superior
- npm 9 o superior
- Angular CLI 17 o superior

## Instalación

1. Instalar dependencias:
```bash
npm install
```

2. Instalar Angular CLI globalmente (si no lo tienes):
```bash
npm install -g @angular/cli
```

## Desarrollo

### Iniciar servidor de desarrollo:
```bash
npm start
```

La aplicación estará disponible en `http://localhost:4200/`

### Otros comandos:
```bash
# Build para producción
npm run build

# Build con watch mode
npm run watch

# Ejecutar tests
npm test
```

## Arquitectura de Comunicación

### De Angular a Flutter (AppBridge)

El servicio `BridgeService` envía mensajes al Shell de Flutter:

```typescript
// Actualizar nombre
bridgeService.updateName('Nuevo Nombre');
```

Internamente usa:
```typescript
window.flutter_inappwebview.callHandler('AppBridge', {
  event: 'UPDATE_NAME',
  payload: { newName: '...' }
});
```

### De Flutter a Angular (CustomEvents)

El MFE escucha eventos del Shell:

```typescript
// Datos actualizados
document.addEventListener('flutterDataUpdate', (event: CustomEvent) => {
  console.log(event.detail.userName);
  console.log(event.detail.timestamp);
});
```

## Contrato de API

### Mensajes de Angular a Flutter

**UPDATE_NAME**
```json
{
  "event": "UPDATE_NAME",
  "payload": {
    "newName": "string"
  }
}
```

### Eventos de Flutter a Angular

**flutterDataUpdate**
```json
{
  "userName": "string",
  "timestamp": "ISO8601"
}
```

## Estructura del Proyecto

```
src/
├── main.ts                      # Bootstrap de la aplicación
├── index.html                   # HTML principal
├── styles.css                   # Estilos globales
└── app/
    ├── app.component.ts         # Componente principal
    ├── app.component.html       # Template de UI
    ├── app.component.css        # Estilos del componente
    ├── app.config.ts            # Configuración de la app
    └── services/
        └── bridge.service.ts    # Servicio de comunicación
```

## Modo Standalone

Este proyecto puede ejecutarse de forma independiente (fuera del WebView de Flutter) para desarrollo y testing. En este modo:

- El badge mostrará "Modo Standalone"
- Los botones estarán deshabilitados
- Se pueden probar los estilos y la UI sin funcionalidad

## Integración con Flutter

Para que este MFE funcione dentro del Shell de Flutter:

1. Este servidor debe estar corriendo en `http://localhost:4200`
2. El Shell de Flutter debe cargar esta URL en el `InAppWebView`
3. El Shell registrará el `AppBridge` automáticamente
4. La comunicación bidireccional funcionará automáticamente

## Desarrollo de UI

Para agregar nuevas características de UI:

1. Agregar el HTML/CSS necesario en el componente
2. Crear métodos para interacciones en `app.component.ts`
3. Usar `BridgeService` para comunicarse con Flutter
4. NO agregar lógica de negocio - delegar todo a Flutter

## Troubleshooting

**El MFE no se conecta con Flutter:**
- Verificar que el servidor esté en `http://localhost:4200`
- Verificar que el Shell de Flutter esté corriendo
- Revisar la consola del WebView en Flutter

**Los eventos no se reciben:**
- Verificar que `BridgeService` esté inicializado
- Revisar los logs en la consola del navegador
- Verificar que el contrato de API esté correcto

**Estilos no se ven bien en WebView:**
- Verificar viewport en `index.html`
- Probar en un navegador primero
- Ajustar CSS para móviles

## Consideraciones de Producción

Para producción:

1. Build optimizado:
   ```bash
   npm run build
   ```

2. Servir desde un servidor web real (no localhost)

3. Actualizar la URL en el Shell de Flutter

4. Considerar:
   - HTTPS para seguridad
   - CDN para assets
   - Compresión GZIP
   - Cache-Control headers
