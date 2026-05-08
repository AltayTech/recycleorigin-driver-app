/// Lightweight result type for HTTP responses.
///
/// Mirrors the user app's `core/utils/result.dart` so call sites in the
/// driver app feel familiar. `Success` carries a value; `Failure` carries a
/// short, user-facing message.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success<T>(value: final v) => v,
        Failure<T>() => null,
      };

  String? get errorOrNull => switch (this) {
        Failure<T>(message: final m) => m,
        Success<T>() => null,
      };
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.message);
  final String message;
}
