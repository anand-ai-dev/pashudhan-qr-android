import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/core/exceptions.dart';
import 'package:pashudhan_qr/repository/dto/otp_dtos.dart';
import 'package:pashudhan_qr/screens/login/otp_verify_viewmodel.dart';

import '../../helpers/test_helpers.dart';

OtpVerifyViewModel _makeViewModel() => OtpVerifyViewModel(
      phoneNumber: '9876543210',
      otpId: 42,
    );

void main() {
  setUpAll(registerFallbackValues);

  late MockNavigationService mockNav;
  late MockDialogService mockDialog;
  late MockAuthRepository mockAuth;
  late MockStorageService mockStorage;
  late OtpVerifyViewModel viewModel;

  setUp(() {
    locator.allowReassignment = true;
    mockNav = getAndRegisterNavigationService();
    mockDialog = getAndRegisterDialogService();
    mockAuth = getAndRegisterAuthRepository();
    mockStorage = getAndRegisterStorageService();

    when(() => mockStorage.saveCustomData(any(), any())).thenAnswer((_) async {});
    when(() => mockStorage.getOtpToken()).thenAnswer((_) async => null);
    when(() => mockStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockAuth.logout()).thenAnswer((_) async {});

    viewModel = _makeViewModel();
  });

  tearDown(() => locator.reset());

  // ─── OTP Validation ────────────────────────────────────────────────────────

  group('onVerify — input validation', () {
    test('shows dialog when OTP is empty', () async {
      viewModel.setOtp('');
      await viewModel.onVerify();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockAuth.verifyOtp(any()));
    });

    test('shows dialog when OTP is non-numeric', () async {
      viewModel.setOtp('abcd');
      await viewModel.onVerify();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockAuth.verifyOtp(any()));
    });

    test('shows dialog when OTP is fewer than 4 digits', () async {
      viewModel.setOtp('123');
      await viewModel.onVerify();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockAuth.verifyOtp(any()));
    });

    test('proceeds to API when OTP is exactly 4 digits', () async {
      viewModel.setOtp('1234');

      when(() => mockAuth.verifyOtp(any())).thenAnswer((_) async =>
          VerifyOtpParsedResponse(jwtToken: 'tok', userId: 1, role: 'CUSTOMER'));

      await viewModel.onVerify();

      verify(() => mockAuth.verifyOtp(any())).called(1);
    });
  });

  // ─── Existing user routing ─────────────────────────────────────────────────

  group('onVerify — existing user (userId != null)', () {
    test('saves userId and clears stack to splash', () async {
      viewModel.setOtp('123456');

      when(() => mockAuth.verifyOtp(any())).thenAnswer((_) async =>
          VerifyOtpParsedResponse(jwtToken: 'auth.tok', userId: 7, role: 'CUSTOMER'));

      await viewModel.onVerify();

      verify(() => mockStorage.saveCustomData('user_id', '7')).called(1);
      verify(() => mockNav.clearStackAndShow(
            Routes.splashView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('saves user_role when role present', () async {
      viewModel.setOtp('123456');

      when(() => mockAuth.verifyOtp(any())).thenAnswer((_) async =>
          VerifyOtpParsedResponse(jwtToken: 'tok', userId: 7, role: 'ASSOCIATE'));

      await viewModel.onVerify();

      verify(() => mockStorage.saveCustomData('user_role', 'ASSOCIATE')).called(1);
    });

    test('saves user_name from phoneNumber', () async {
      viewModel.setOtp('123456');

      when(() => mockAuth.verifyOtp(any())).thenAnswer((_) async =>
          VerifyOtpParsedResponse(jwtToken: 'tok', userId: 7, role: 'CUSTOMER'));

      await viewModel.onVerify();

      verify(() => mockStorage.saveCustomData('user_name', '9876543210')).called(1);
    });
  });

  // ─── New user routing ──────────────────────────────────────────────────────

  group('onVerify — new user (userId == null)', () {
    test('navigates to role selection when userId is null', () async {
      viewModel.setOtp('123456');

      when(() => mockAuth.verifyOtp(any())).thenAnswer((_) async =>
          VerifyOtpParsedResponse(jwtToken: 'otp.tok', userId: null, role: 'OTP_VERIFIED_USER'));

      await viewModel.onVerify();

      verifyNever(() => mockNav.clearStackAndShow(Routes.splashView));
      verify(() => mockNav.navigateTo(
            Routes.roleSelectionView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            preventDuplicates: any(named: 'preventDuplicates'),
            parameters: any(named: 'parameters'),
            transition: any(named: 'transition'),
          )).called(1);
    });

    test('does not save user_id when userId is null', () async {
      viewModel.setOtp('123456');

      when(() => mockAuth.verifyOtp(any())).thenAnswer((_) async =>
          VerifyOtpParsedResponse(jwtToken: 'otp.tok', userId: null, role: null));

      await viewModel.onVerify();

      verifyNever(() => mockStorage.saveCustomData('user_id', any()));
    });
  });

  // ─── Missing token case ────────────────────────────────────────────────────

  group('onVerify — missing token in response', () {
    test('shows dialog when server returns null token', () async {
      viewModel.setOtp('123456');

      when(() => mockAuth.verifyOtp(any())).thenAnswer((_) async =>
          VerifyOtpParsedResponse(jwtToken: null, userId: null, role: null));

      await viewModel.onVerify();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
    });

    test('shows dialog when server returns empty token', () async {
      viewModel.setOtp('123456');

      when(() => mockAuth.verifyOtp(any())).thenAnswer((_) async =>
          VerifyOtpParsedResponse(jwtToken: '', userId: null, role: null));

      await viewModel.onVerify();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
    });
  });

  // ─── HTTP error handling ───────────────────────────────────────────────────

  group('onVerify — DioException HTTP status handling', () {
    DioException dioErr(int status) => DioException(
          requestOptions: RequestOptions(path: '/v1/otp/verify'),
          response: Response(
            requestOptions: RequestOptions(path: '/v1/otp/verify'),
            statusCode: status,
          ),
          type: DioExceptionType.badResponse,
        );

    test('shows dialog on 400 (wrong OTP), stays on screen', () async {
      viewModel.setOtp('000000');
      when(() => mockAuth.verifyOtp(any())).thenThrow(dioErr(400));

      await viewModel.onVerify();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockNav.clearStackAndShow(any()));
    });

    test('navigates to approval pending on 403', () async {
      viewModel.setOtp('000000');
      when(() => mockAuth.verifyOtp(any())).thenThrow(dioErr(403));

      await viewModel.onVerify();

      verify(() => mockNav.clearStackAndShow(
            Routes.approvalPendingView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('shows server busy dialog on 503', () async {
      viewModel.setOtp('000000');
      when(() => mockAuth.verifyOtp(any())).thenThrow(dioErr(503));

      await viewModel.onVerify();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
    });
  });

  // ─── UnauthenticatedException ─────────────────────────────────────────────

  group('onVerify — UnauthenticatedException', () {
    test('calls logout and navigates to login', () async {
      viewModel.setOtp('000000');

      when(() => mockAuth.verifyOtp(any()))
          .thenThrow(UnauthenticatedException('Session expired.'));

      await viewModel.onVerify();

      verify(() => mockAuth.logout()).called(1);
      verify(() => mockNav.clearStackAndShow(
            Routes.loginView,
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            parameters: any(named: 'parameters'),
          )).called(1);
    });
  });

  // ─── Generic error handling ────────────────────────────────────────────────

  group('onVerify — generic exception', () {
    test('shows error dialog for non-Dio exceptions', () async {
      viewModel.setOtp('000000');

      when(() => mockAuth.verifyOtp(any())).thenThrow(Exception('Unexpected'));

      await viewModel.onVerify();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
    });
  });

  // ─── resendOtp ─────────────────────────────────────────────────────────────

  group('resendOtp — success', () {
    test('calls generateOtp with the phone number', () async {
      when(() => mockAuth.generateOtp(any()))
          .thenAnswer((_) async => GenerateOtpResponse(otpId: 99));

      await viewModel.resendOtp();

      verify(() => mockAuth.generateOtp('9876543210')).called(1);
    });

    test('shows success dialog after resend', () async {
      when(() => mockAuth.generateOtp(any()))
          .thenAnswer((_) async => GenerateOtpResponse(otpId: 99));

      await viewModel.resendOtp();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
    });

    test('isBusy is false after successful resend', () async {
      when(() => mockAuth.generateOtp(any()))
          .thenAnswer((_) async => GenerateOtpResponse(otpId: 99));

      await viewModel.resendOtp();

      expect(viewModel.isBusy, isFalse);
    });

    test('new otpId is used in subsequent verify call', () async {
      when(() => mockAuth.generateOtp(any()))
          .thenAnswer((_) async => GenerateOtpResponse(otpId: 99));

      await viewModel.resendOtp();

      // Stub verifyOtp so we can capture what otpId was sent
      when(() => mockAuth.verifyOtp(any())).thenAnswer((_) async =>
          VerifyOtpParsedResponse(jwtToken: null, userId: null, role: null));
      when(() => mockStorage.getOtpToken()).thenAnswer((_) async => null);

      viewModel.setOtp('123456');
      await viewModel.onVerify();

      final captured =
          verify(() => mockAuth.verifyOtp(captureAny())).captured.single
              as VerifyOtpRequest;
      expect(captured.otpId, 99);
    });
  });

  group('resendOtp — null response', () {
    test('shows error dialog when generateOtp returns null', () async {
      when(() => mockAuth.generateOtp(any())).thenAnswer((_) async => null);

      await viewModel.resendOtp();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
    });

    test('shows error dialog when generateOtp returns otpId 0', () async {
      when(() => mockAuth.generateOtp(any()))
          .thenAnswer((_) async => GenerateOtpResponse(otpId: 0));

      await viewModel.resendOtp();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
    });
  });

  group('resendOtp — error handling', () {
    test('shows error dialog on exception', () async {
      when(() => mockAuth.generateOtp(any()))
          .thenThrow(Exception('network error'));

      await viewModel.resendOtp();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      expect(viewModel.isBusy, isFalse);
    });

    test('does not call generateOtp when already busy', () async {
      // Simulate busy state by making the first resend hang
      when(() => mockAuth.generateOtp(any()))
          .thenAnswer((_) async => GenerateOtpResponse(otpId: 77));

      // First call in-flight
      final first = viewModel.resendOtp();
      // Second call while busy should be a no-op
      await viewModel.resendOtp();
      await first;

      verify(() => mockAuth.generateOtp(any())).called(1);
    });
  });
}
