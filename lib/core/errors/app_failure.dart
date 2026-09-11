class AppFailure implements Exception {
  const AppFailure(this.message, {this.details});

  final String message;
  final String? details;

  @override
  String toString() => details == null ? message : '$message ($details)';
}
