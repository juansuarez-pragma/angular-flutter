import 'package:equatable/equatable.dart';

/// Estado de la aplicación
class AppState extends Equatable {
  final String userName;
  final DateTime lastUpdated;

  const AppState({
    required this.userName,
    required this.lastUpdated,
  });

  /// Estado inicial
  factory AppState.initial() {
    return AppState(
      userName: 'Usuario Inicial',
      lastUpdated: DateTime.now(),
    );
  }

  /// Copiar con nuevos valores
  AppState copyWith({
    String? userName,
    DateTime? lastUpdated,
  }) {
    return AppState(
      userName: userName ?? this.userName,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [userName, lastUpdated];
}
