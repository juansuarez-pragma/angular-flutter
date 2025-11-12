import 'package:go_router/go_router.dart';
import 'package:flutter_shell_orchestrator/presentation/screens/webview_host_screen.dart';

/// Configuración de rutas de la aplicación
class AppRouterConfig {
  static const String home = '/';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const WebViewHostScreen(),
      ),
    ],
  );
}
