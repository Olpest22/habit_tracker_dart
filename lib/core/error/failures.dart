import 'package:equatable/equatable.dart';

/// Ошибки, с которыми работают domain и presentation.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Не удалось прочитать или записать данные.
final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Нарушено бизнес-правило (например, пустое название привычки).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
