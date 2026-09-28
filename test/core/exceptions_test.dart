import 'package:flutter_test/flutter_test.dart';
import 'package:pashudhan_qr/core/exceptions.dart';

void main() {
  group('UnauthenticatedException', () {
    test('uses default message when none provided', () {
      final e = UnauthenticatedException();
      expect(e.message, 'User is unauthenticated');
    });

    test('stores custom message', () {
      final e = UnauthenticatedException('Token expired');
      expect(e.message, 'Token expired');
    });

    test('toString includes class name and message', () {
      final e = UnauthenticatedException('Token expired');
      expect(e.toString(), 'UnauthenticatedException: Token expired');
    });

    test('is an Exception', () {
      expect(UnauthenticatedException(), isA<Exception>());
    });

    test('can be caught as Exception', () {
      expect(
        () => throw UnauthenticatedException('oops'),
        throwsA(isA<UnauthenticatedException>()),
      );
    });
  });

  group('ServerException', () {
    test('uses default message when none provided', () {
      final e = ServerException();
      expect(e.message, 'Internal Server Error');
    });

    test('stores custom message', () {
      final e = ServerException('Service unavailable');
      expect(e.message, 'Service unavailable');
    });

    test('toString includes class name and message', () {
      final e = ServerException('Service unavailable');
      expect(e.toString(), 'ServerException: Service unavailable');
    });

    test('is an Exception', () {
      expect(ServerException(), isA<Exception>());
    });

    test('can be caught as Exception', () {
      expect(
        () => throw ServerException('boom'),
        throwsA(isA<ServerException>()),
      );
    });

    test('UnauthenticatedException and ServerException are distinct types', () {
      expect(UnauthenticatedException(), isNot(isA<ServerException>()));
      expect(ServerException(), isNot(isA<UnauthenticatedException>()));
    });
  });
}
