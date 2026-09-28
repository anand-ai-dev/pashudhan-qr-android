import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/core/exceptions.dart';
import 'package:pashudhan_qr/repository/dto/otp_dtos.dart';
import 'package:pashudhan_qr/screens/login/login_viewmodel.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockNavigationService mockNav;
  late MockDialogService mockDialog;
  late MockAuthRepository mockAuth;
  late LoginViewModel viewModel;

  setUp(() {
    locator.allowReassignment = true;
    mockNav = getAndRegisterNavigationService();
    mockDialog = getAndRegisterDialogService();
    mockAuth = getAndRegisterAuthRepository();

    viewModel = LoginViewModel();
  });

  tearDown(() => locator.reset());

  // ─── Phone validation ──────────────────────────────────────────────────────

  group('isPhoneNumberValid', () {
    test('valid 10-digit numeric number', () {
      viewModel.setPhoneNumber('9876543210');
      expect(viewModel.isPhoneNumberValid, isTrue);
    });

    test('invalid: 9 digits', () {
      viewModel.setPhoneNumber('987654321');
      expect(viewModel.isPhoneNumberValid, isFalse);
    });

    test('invalid: 11 digits', () {
      viewModel.setPhoneNumber('98765432101');
      expect(viewModel.isPhoneNumberValid, isFalse);
    });

    test('invalid: contains letters', () {
      viewModel.setPhoneNumber('98765A3210');
      expect(viewModel.isPhoneNumberValid, isFalse);
    });

    test('invalid: empty string', () {
      viewModel.setPhoneNumber('');
      expect(viewModel.isPhoneNumberValid, isFalse);
    });

    test('invalid: only spaces', () {
      viewModel.setPhoneNumber('          ');
      expect(viewModel.isPhoneNumberValid, isFalse);
    });
  });

  // ─── setPhoneNumber ────────────────────────────────────────────────────────

  group('setPhoneNumber', () {
    test('updates phoneNumber getter', () {
      viewModel.setPhoneNumber('1234567890');
      expect(viewModel.phoneNumber, '1234567890');
    });
  });

  // ─── onGetStarted ─────────────────────────────────────────────────────────

  group('onGetStarted', () {
    test('shows dialog and does not call API when phone number is invalid',
        () async {
      viewModel.setPhoneNumber('123');

      await viewModel.onGetStarted();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockAuth.generateOtp(any()));
    });

    test('calls generateOtp with trimmed phone on valid number', () async {
      viewModel.setPhoneNumber('9876543210');

      when(() => mockAuth.generateOtp('9876543210'))
          .thenAnswer((_) async => GenerateOtpResponse(otpId: 42));

      await viewModel.onGetStarted();

      verify(() => mockAuth.generateOtp('9876543210')).called(1);
    });

    test('navigates to OTP view on successful OTP generation', () async {
      viewModel.setPhoneNumber('9876543210');

      when(() => mockAuth.generateOtp(any()))
          .thenAnswer((_) async => GenerateOtpResponse(otpId: 77));

      await viewModel.onGetStarted();

      verify(() => mockNav.navigateTo(
            any(),
            arguments: any(named: 'arguments'),
            id: any(named: 'id'),
            preventDuplicates: any(named: 'preventDuplicates'),
            parameters: any(named: 'parameters'),
            transition: any(named: 'transition'),
          )).called(1);
    });

    test('shows error dialog when API throws', () async {
      viewModel.setPhoneNumber('9876543210');

      when(() => mockAuth.generateOtp(any()))
          .thenThrow(Exception('Network error'));

      await viewModel.onGetStarted();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
    });

    test('shows clean server message when OTP service is unavailable',
        () async {
      viewModel.setPhoneNumber('9876543210');

      when(() => mockAuth.generateOtp(any())).thenThrow(
        ServerException(
            'The server is temporarily unavailable. Please try again shortly.'),
      );

      await viewModel.onGetStarted();

      verify(() => mockDialog.showDialog(
            title: 'Error',
            description:
                'The server is temporarily unavailable. Please try again shortly.',
          )).called(1);
    });

    test('shows error dialog when API returns null response', () async {
      viewModel.setPhoneNumber('9876543210');

      when(() => mockAuth.generateOtp(any())).thenAnswer((_) async => null);

      await viewModel.onGetStarted();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
    });

    test('debounce: second concurrent tap is ignored', () async {
      viewModel.setPhoneNumber('9876543210');

      when(() => mockAuth.generateOtp(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return GenerateOtpResponse(otpId: 1);
      });

      final first = viewModel.onGetStarted();
      final second = viewModel.onGetStarted();

      await Future.wait([first, second]);

      verify(() => mockAuth.generateOtp(any())).called(1);
    });
  });
}
