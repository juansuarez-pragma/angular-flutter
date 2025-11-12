import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_shell_orchestrator/core/bloc/app_bloc.dart';
import 'package:flutter_shell_orchestrator/core/bloc/app_event.dart';
import 'package:flutter_shell_orchestrator/core/bloc/app_state.dart';
import 'package:flutter_shell_orchestrator/core/services/bridge_service.dart';

/// Pantalla que aloja el WebView con el MFE de Angular
class WebViewHostScreen extends StatefulWidget {
  const WebViewHostScreen({super.key});

  @override
  State<WebViewHostScreen> createState() => _WebViewHostScreenState();
}

class _WebViewHostScreenState extends State<WebViewHostScreen> {
  double _loadingProgress = 0;
  bool _isWebViewReady = false;

  // URL del MFE de Angular (desarrollo)
  // Usar 10.0.2.2 para Android emulator (apunta a la máquina host)
  static const String _mfeUrl = 'http://10.0.2.2:4200';

  @override
  Widget build(BuildContext context) {
    final bridgeService = context.read<BridgeService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Shell Orquestador'),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Indicador de estado del WebView
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _isWebViewReady
                  ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                  : const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          // Enviar actualizaciones al MFE cuando cambie el estado
          print('WebViewHost: Estado actualizado - userName: ${state.userName}');

          if (_isWebViewReady) {
            bridgeService.sendAppState(state);
          }
        },
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_mfeUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                allowContentAccess: true,
                allowFileAccess: true,
                useOnLoadResource: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                // Configuración de seguridad
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                // Permitir localhost para desarrollo
                allowUniversalAccessFromFileURLs: false,
              ),
              onWebViewCreated: (controller) {
                bridgeService.setWebViewController(controller);
                print('WebViewHost: WebView creado');

                // Registrar el manejador JavaScript para recibir mensajes del MFE
                _setupJavaScriptHandler(controller, context);
              },
              onLoadStart: (controller, url) {
                print('WebViewHost: Cargando URL: $url');
                setState(() {
                  _isWebViewReady = false;
                });
              },
              onLoadStop: (controller, url) async {
                print('WebViewHost: Carga completada: $url');
                setState(() {
                  _isWebViewReady = true;
                  _loadingProgress = 1.0;
                });

                // Enviar estado inicial al MFE
                final appState = context.read<AppBloc>().state;
                await bridgeService.sendAppState(appState);
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _loadingProgress = progress / 100;
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                // Log de consola del WebView
                print('WebView Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}');
              },
              onReceivedError: (controller, request, error) {
                print('WebViewHost: Error cargando ${request.url} - ${error.type}: ${error.description}');
                _showErrorSnackbar(context, 'Error cargando MFE: ${error.description}');
              },
            ),
            // Barra de progreso
            if (_loadingProgress < 1.0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Configura el manejador JavaScript para recibir mensajes del MFE
  void _setupJavaScriptHandler(
    InAppWebViewController controller,
    BuildContext context,
  ) {
    controller.addJavaScriptHandler(
      handlerName: 'AppBridge',
      callback: (args) {
        // CRÍTICO: Validación de seguridad de origen
        if (args.isEmpty) {
          print('AppBridge: Mensaje recibido sin datos');
          return {'error': 'No data received'};
        }

        try {
          final messageData = args[0];
          print('AppBridge: Mensaje recibido desde Web: $messageData');

          // Parsear JSON
          final Map<String, dynamic> payload;
          if (messageData is String) {
            payload = jsonDecode(messageData);
          } else if (messageData is Map) {
            payload = Map<String, dynamic>.from(messageData);
          } else {
            print('AppBridge: Tipo de mensaje inválido');
            return {'error': 'Invalid message type'};
          }

          // Validación de origen (CRÍTICO para seguridad)
          // En producción, verificar el origen real del mensaje
          // Por ahora, validamos la estructura del mensaje

          final event = payload['event'] as String?;
          if (event == null) {
            print('AppBridge: Evento no especificado');
            return {'error': 'Event not specified'};
          }

          // Procesar evento según su tipo
          _handleWebMessage(context, event, payload['payload']);

          return {'success': true, 'message': 'Event processed'};
        } catch (e) {
          print('AppBridge: Error procesando mensaje: $e');
          return {'error': 'Error processing message: $e'};
        }
      },
    );

    print('WebViewHost: AppBridge JavaScriptHandler registrado');
  }

  /// Maneja los mensajes recibidos del MFE
  void _handleWebMessage(
    BuildContext context,
    String event,
    dynamic payload,
  ) {
    final appBloc = context.read<AppBloc>();

    print('AppBridge: Procesando evento: $event');

    switch (event) {
      case 'UPDATE_NAME':
        if (payload is Map && payload.containsKey('newName')) {
          final newName = payload['newName'] as String;
          print('AppBridge: Actualizando nombre a: $newName');
          appBloc.add(UpdateNameEvent(newName));
        } else {
          print('AppBridge: Payload inválido para UPDATE_NAME');
        }
        break;

      default:
        print('AppBridge: Evento desconocido: $event');
    }
  }

  /// Muestra un SnackBar con mensaje de error
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
