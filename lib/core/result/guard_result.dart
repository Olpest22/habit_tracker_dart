import '../error/exceptions.dart';
import '../error/failures.dart';
import 'result.dart';

/// Выполняет операцию слоя данных и переводит исключения в [Result].
Future<Result<T>> guardResult<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } on CacheException catch (exception) {
    return Failed(StorageFailure(exception.message));
  } on FormatException {
    return Failed(const StorageFailure('Сохранённые данные повреждены.'));
  }
}
