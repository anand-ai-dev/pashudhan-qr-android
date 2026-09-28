import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pashudhan_qr/repository/dto/otp_dtos.dart';

void main() {
  group('GenerateOtpResponse', () {
    test('fromMap parses otpId as int', () {
      final r = GenerateOtpResponse.fromMap({'otpId': 42});
      expect(r.otpId, 42);
    });

    test('fromMap parses otpId from string', () {
      final r = GenerateOtpResponse.fromMap({'otpId': '99'});
      expect(r.otpId, 99);
    });

    test('fromMap defaults otpId to 0 when null', () {
      final r = GenerateOtpResponse.fromMap({'otpId': null});
      expect(r.otpId, 0);
    });

    test('fromJson round-trips correctly', () {
      final original = GenerateOtpResponse(otpId: 77);
      final json = original.toJson();
      final restored = GenerateOtpResponse.fromJson(json);

      expect(restored, original);
    });

    test('toJson produces valid JSON', () {
      final json = GenerateOtpResponse(otpId: 10).toJson();
      final decoded = jsonDecode(json);

      expect(decoded['otpId'], 10);
    });

    test('equality: same otpId', () {
      final a = GenerateOtpResponse(otpId: 55);
      final b = GenerateOtpResponse(otpId: 55);

      expect(a, equals(b));
    });

    test('inequality: different otpId', () {
      final a = GenerateOtpResponse(otpId: 1);
      final b = GenerateOtpResponse(otpId: 2);

      expect(a, isNot(equals(b)));
    });

    test('hashCode consistent for equal objects', () {
      final a = GenerateOtpResponse(otpId: 33);
      final b = GenerateOtpResponse(otpId: 33);

      expect(a.hashCode, b.hashCode);
    });

    test('toString includes otpId', () {
      expect(GenerateOtpResponse(otpId: 44).toString(), contains('44'));
    });

    test('copyWith overrides otpId', () {
      final original = GenerateOtpResponse(otpId: 1);
      final copy = original.copyWith(otpId: 99);

      expect(copy.otpId, 99);
    });

    test('copyWith preserves otpId when not provided', () {
      final original = GenerateOtpResponse(otpId: 7);
      expect(original.copyWith().otpId, 7);
    });
  });

  group('VerifyOtpRequest', () {
    test('toMap includes all required keys', () {
      final req = VerifyOtpRequest(otpId: 1, otp: 123456, userName: '9876543210');
      final map = req.toMap();

      expect(map['otpId'], 1);
      expect(map['otp'], 123456);
      expect(map['userName'], '9876543210');
    });

    test('fromMap parses all fields', () {
      final req = VerifyOtpRequest.fromMap({
        'otpId': 5,
        'otp': 654321,
        'userName': '9000000001',
      });

      expect(req.otpId, 5);
      expect(req.otp, 654321);
      expect(req.userName, '9000000001');
    });

    test('fromJson round-trip', () {
      final original = VerifyOtpRequest(otpId: 2, otp: 111111, userName: '9000000002');
      final restored = VerifyOtpRequest.fromJson(original.toJson());

      expect(restored, original);
    });

    test('equality', () {
      final a = VerifyOtpRequest(otpId: 1, otp: 2222, userName: 'u1');
      final b = VerifyOtpRequest(otpId: 1, otp: 2222, userName: 'u1');

      expect(a, equals(b));
    });

    test('inequality when otp differs', () {
      final a = VerifyOtpRequest(otpId: 1, otp: 1111, userName: 'u1');
      final b = VerifyOtpRequest(otpId: 1, otp: 9999, userName: 'u1');

      expect(a, isNot(equals(b)));
    });

    test('hashCode consistent', () {
      final a = VerifyOtpRequest(otpId: 3, otp: 3333, userName: 'u3');
      final b = VerifyOtpRequest(otpId: 3, otp: 3333, userName: 'u3');

      expect(a.hashCode, b.hashCode);
    });
  });

  group('VerifyOtpParsedResponse', () {
    test('stores all fields', () {
      final r = VerifyOtpParsedResponse(
        jwtToken: 'tok.en.here',
        userId: 42,
        role: 'CUSTOMER',
      );

      expect(r.jwtToken, 'tok.en.here');
      expect(r.userId, 42);
      expect(r.role, 'CUSTOMER');
    });

    test('all fields nullable', () {
      final r = VerifyOtpParsedResponse();

      expect(r.jwtToken, isNull);
      expect(r.userId, isNull);
      expect(r.role, isNull);
    });

    test('new user: userId is null', () {
      final r = VerifyOtpParsedResponse(jwtToken: 'otp.tok.en', userId: null, role: 'OTP_VERIFIED_USER');
      expect(r.userId, isNull);
    });
  });
}
