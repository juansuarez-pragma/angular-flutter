import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shell_orchestrator/core/bloc/app_event.dart';
import 'package:flutter_shell_orchestrator/core/bloc/app_state.dart';

/// BLoC principal de la aplicación
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState.initial()) {
    // Registrar manejador de eventos
    on<UpdateNameEvent>(_onUpdateName);
  }

  /// Maneja la actualización del nombre
  void _onUpdateName(UpdateNameEvent event, Emitter<AppState> emit) {
    print('AppBloc: Actualizando nombre a: ${event.newName}');
    emit(state.copyWith(
      userName: event.newName,
      lastUpdated: DateTime.now(),
    ));
  }
}
