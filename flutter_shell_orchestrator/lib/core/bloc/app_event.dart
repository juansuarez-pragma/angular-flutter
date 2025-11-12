import 'package:equatable/equatable.dart';

/// Eventos base para el AppBloc
abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para actualizar el nombre del usuario
class UpdateNameEvent extends AppEvent {
  final String newName;

  const UpdateNameEvent(this.newName);

  @override
  List<Object?> get props => [newName];
}
