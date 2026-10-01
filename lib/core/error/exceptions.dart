/// Ошибка локального хранилища (слой data).
/// Не выходит за пределы репозитория — там превращается в [StorageFailure].
class CacheException implements Exception {
  const CacheException(this.message);

  final String message;
}
