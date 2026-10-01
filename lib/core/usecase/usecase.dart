import 'package:equatable/equatable.dart';

import '../result/result.dart';

/// Базовый контракт сценария использования: одно действие бизнес-логики.
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
