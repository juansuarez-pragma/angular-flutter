import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shell_orchestrator/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación preferida (opcional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  print('🚀 Iniciando Flutter Shell Orquestador...');

  runApp(const App());
}
