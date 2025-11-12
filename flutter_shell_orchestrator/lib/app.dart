import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shell_orchestrator/config/router_config.dart';
import 'package:flutter_shell_orchestrator/core/bloc/app_bloc.dart';
import 'package:flutter_shell_orchestrator/core/services/bridge_service.dart';

/// Widget raíz de la aplicación
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Servicios
        RepositoryProvider<BridgeService>(
          create: (_) => BridgeService(),
        ),
      ],
      child: BlocProvider(
        create: (context) => AppBloc(),
        child: MaterialApp.router(
          title: 'Flutter Shell Orquestador',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 2,
            ),
          ),
          routerConfig: AppRouterConfig.router,
        ),
      ),
    );
  }
}
