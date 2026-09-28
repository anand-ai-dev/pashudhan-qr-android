class UnauthenticatedException implements Exception {
  final String message;
  UnauthenticatedException([this.message = 'User is unauthenticated']);

  @override
  String toString() => 'UnauthenticatedException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Internal Server Error']);

  @override
  String toString() => 'ServerException: $message';
}
