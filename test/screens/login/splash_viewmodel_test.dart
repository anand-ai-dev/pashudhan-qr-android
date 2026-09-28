import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/screens/login/splash_viewmodel.dart';

import '../../helpers/test_helpers.dart';

/// Builds a minimal (unsigned) JWT. The ViewModel only reads the payload claim.
String _makeJwt(Map<String, dynamic> payload) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
  final body = base64Url.encode(utf8.encode(jsonEncode(payload)));
  return '$header.$body.fakesig';
}

void main() {
  setUpAll(registerFallbackValues);

  late MockNavigationService mockNav;
  late MockStorageService mockStorage;
  late MockAuthRepository mockAuth;

  setUp(() {
    locator.allowReassignment = true;
    mockNav = getAndRegisterNavigationService();
    mockStorage = getAndRegisterStorageService();
    mockAuth = getAndRegisterAuthRepository();

    when(() => mockAuth.logout()).thenAnswer((_) async {});
  });

  tearDown(() => locator.reset());

  SplashViewModel build() => SplashViewModel();

  // ─── No-token paths ────────────────────────────────────────────────────────

  group('_checkSession — no tokens', () {
    test('navigates to loginView when neither token exists', () async {
      when(() => mockStorage.getToken()).thenAnswer((_) async => null);
      when(() => mockStorage.getOtpToken()).thenAnswer((_) async => null);

      await build().init(true);

      verify(() => mockNav.clearStackAndShow(
            Routes.loginView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('navigates to roleSelectionView when only otp_token present', () async {
      when(() => mockStorage.getToken()).thenAnswer((_) async => null);
      when(() => mockStorage.getOtpToken()).thenAnswer((_) async => 'otp.token.value');

      await build().init(true);

      verify(() => mockNav.clearStackAndShow(
            Routes.roleSelectionView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('treats empty auth_token as absent → navigates to loginView', () async {
      when(() => mockStorage.getToken()).thenAnswer((_) async => '');
      when(() => mockStorage.getOtpToken()).thenAnswer((_) async => null);

      await build().init(true);

      verify(() => mockNav.clearStackAndShow(
            Routes.loginView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            parameters: any(named: 'parameters'),
          )).called(1);
    });
  });

  // ─── Stale OTP-role token ──────────────────────────────────────────────────

  group('_checkSession — stale OTP-role token', () {
    test('deletes stale OTP_VERIFIED_USER token and navigates to roleSelection', () async {
      final staleToken = _makeJwt({'role': 'OTP_VERIFIED_USER'});

      when(() => mockStorage.getToken()).thenAnswer((_) async => staleToken);
      when(() => mockStorage.getOtpToken()).thenAnswer((_) async => null);
      when(() => mockStorage.deleteToken()).thenAnswer((_) async {});
      when(() => mockStorage.saveOtpToken(any())).thenAnswer((_) async {});

      await build().init(true);

      verify(() => mockStorage.deleteToken()).called(1);
      verify(() => mockNav.clearStackAndShow(
            Routes.roleSelectionView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('handles ROLE_OTP_VERIFIED_USER prefix variant', () async {
      final staleToken = _makeJwt({'role': 'ROLE_OTP_VERIFIED_USER'});

      when(() => mockStorage.getToken()).thenAnswer((_) async => staleToken);
      when(() => mockStorage.getOtpToken()).thenAnswer((_) async => 'existing.otp');
      when(() => mockStorage.deleteToken()).thenAnswer((_) async {});

      await build().init(true);

      verify(() => mockStorage.deleteToken()).called(1);
      verify(() => mockNav.clearStackAndShow(
            Routes.roleSelectionView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            parameters: any(named: 'parameters'),
          )).called(1);
    });
  });

  // ─── init() idempotency guard ──────────────────────────────────────────────

  group('init() guard', () {
    test('second call to init() is a no-op — navigation happens exactly once', () async {
      when(() => mockStorage.getToken()).thenAnswer((_) async => null);
      when(() => mockStorage.getOtpToken()).thenAnswer((_) async => null);

      final vm = build();
      await vm.init(true);
      await vm.init(true);

      verify(() => mockNav.clearStackAndShow(
            any(),
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            parameters: any(named: 'parameters'),
          )).called(1);
    });
  });
}
