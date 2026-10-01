import '../error/failures.dart';

/// Результат операции: [Success] с данными или [Failed] с ошибкой.
/// Sealed-тип заставляет вызывающий код обработать оба варианта.
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final Failure failure;
}
