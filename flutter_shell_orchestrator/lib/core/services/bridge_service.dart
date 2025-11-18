import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_shell_orchestrator/core/bloc/app_state.dart';

/// Servicio para gestionar el puente de comunicación entre Flutter y Web
class BridgeService {
  InAppWebViewController? _webViewController;

  /// Establece el controlador del WebView
  void setWebViewController(InAppWebViewController controller) {
    _webViewController = controller;
    print('BridgeService: Controlador WebView establecido');
  }

  /// Envía datos actualizados al MFE de Angular
  Future<void> sendDataUpdate({
    required String userName,
  }) async {
    if (_webViewController == null) {
      print('BridgeService: Error - Controlador WebView no inicializado');
      return;
    }

    final Map<String, String> payload = {
      'userName': userName,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final jsCode = '''
      (function() {
        try {
          const event = new CustomEvent('flutterDataUpdate', {
            detail: ${jsonEncode(payload)}
          });
          document.dispatchEvent(event);
          console.log('Flutter -> Web: flutterDataUpdate enviado', ${jsonEncode(payload)});
        } catch (error) {
          console.error('Error despachando evento flutterDataUpdate:', error);
        }
      })();
    ''';

    try {
      await _webViewController!.evaluateJavascript(source: jsCode);
      print('BridgeService: Datos enviados al MFE - userName: $userName');
    } catch (e) {
      print('BridgeService: Error enviando datos: $e');
    }
  }

  /// Envía el estado completo de la app al MFE
  Future<void> sendAppState(AppState state) async {
    await sendDataUpdate(userName: state.userName);
  }
}
