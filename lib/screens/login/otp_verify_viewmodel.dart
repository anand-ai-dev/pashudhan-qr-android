import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pashudhan_qr/core/exceptions.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/repository/auth_repository.dart';
import 'package:pashudhan_qr/repository/dto/otp_dtos.dart';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class OtpVerifyViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _authRepository = locator<AuthRepository>();
  final _storage = locator<StorageService>();

  final String phoneNumber;
  late int _otpId;

  OtpVerifyViewModel({
    required this.phoneNumber,
    required int otpId,
  }) {
    _otpId = otpId;
  }

  String _otp = '';

  /// Guard flag — prevents duplicate verify calls from rapid taps.
  bool _isVerifying = false;

  void setOtp(String value) {
    _otp = value;
    notifyListeners();
  }

  Future<void> onVerify() async {
    final trimmedOtp = _otp.trim();
    final parsedOtp = int.tryParse(trimmedOtp);

    if (parsedOtp == null || trimmedOtp.length < 4) {
      _dialogService.showDialog(
        title: 'Invalid OTP',
        description: 'Please enter a valid numeric OTP.',
      );
      return;
    }

    // Debounce: already in-flight → ignore tap.
    if (_isVerifying || isBusy) return;

    _isVerifying = true;
    setBusy(true);

    try {
      final verifyOtpRequest = VerifyOtpRequest(
        otpId: _otpId,
        otp: parsedOtp,
        userName: phoneNumber.trim(),
      );

      final verifyResponse = await _authRepository.verifyOtp(verifyOtpRequest);

      // ── Validate the token returned from server ──────────────────────────
      final token = verifyResponse.jwtToken;
      if (token == null || token.isEmpty) {
        // Server responded 200 but no token — treat as invalid OTP
        _dialogService.showDialog(
          title: 'Invalid OTP',
          description: 'OTP could not be verified. Please try again.',
        );
        return;
      }

      // ── Token is valid — save user meta and route accordingly ────────────
      await _storage.saveCustomData('user_name', phoneNumber.trim());

      final userId = verifyResponse.userId;
      final role = verifyResponse.role;

      if (role != null) {
        await _storage.saveCustomData('user_role', role.toString());
      }

      if (kDebugMode) {
        debugPrint('🔥 OTP VERIFIED SUCCESS');
        final otpTok = await _storage.getOtpToken();
        final authTok = await _storage.getToken();
        debugPrint(
            '   otp_token present : ${otpTok != null && otpTok.isNotEmpty}');
        debugPrint(
            '   auth_token present: ${authTok != null && authTok.isNotEmpty}');
        debugPrint('   userId=$userId  role=$role');
      }

      if (userId == null) {
        // ── Case 2: New / unregistered user ─────────────────────────────────
        // AuthRepository already saved otp_token.  Go to role selection.
        if (kDebugMode) {
          debugPrint('🔥 New user detected → navigating to roleSelectionView');
        }
        _navigationService.navigateToRoleSelectionView();
      } else {
        // ── Case 1: Existing user ────────────────────────────────────────────
        // AuthRepository already saved auth_token.  Go to splash for routing.
        await _storage.saveCustomData('user_id', userId.toString());
        _navigationService.clearStackAndShow(Routes.splashView);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ OTP VERIFY FAILED: $e');

      // ── Case 3: OTP invalid / expired ────────────────────────────────────
      if (e is UnauthenticatedException) {
        locator<AuthRepository>().logout();
        _navigationService.clearStackAndShow(Routes.loginView);
        return;
      }

      if (e is DioException) {
        final status = e.response?.statusCode;

        // 400 / 401 → wrong OTP entered — stay on screen, show error
        if (status == 400 || status == 401) {
          _dialogService.showDialog(
            title: 'Invalid OTP',
            description: 'The OTP you entered is incorrect or has expired. Please try again.',
          );
          return; // ← DO NOT navigate
        }

        if (status == 403) {
          _navigationService.clearStackAndShow(Routes.approvalPendingView);
          return;
        }

        if (status == 503) {
          _dialogService.showDialog(
            title: 'Server Busy',
            description: 'Service is temporarily unavailable. Please try again.',
          );
          return;
        }

        // Any other HTTP error — show message, stay on screen
        String errorMessage = 'Verification failed';
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        } else {
          errorMessage =
              e.response?.data.toString() ?? e.message ?? e.toString();
        }

        _dialogService.showDialog(
          title: 'Error',
          description: errorMessage,
        );
        return;
      }

      // Non-DioException (network, parse errors, etc.) — stay on screen
      _dialogService.showDialog(
        title: 'Error',
        description: 'Something went wrong. Please try again.',
      );
    } finally {
      _isVerifying = false;
      setBusy(false);
    }
  }

  Future<void> resendOtp() async {
    if (isBusy) return;
    setBusy(true);
    try {
      final response = await _authRepository.generateOtp(phoneNumber.trim());
      if (response == null || response.otpId == 0) {
        _dialogService.showDialog(
          title: 'Failed',
          description: 'Could not resend OTP. Please try again.',
        );
        return;
      }
      _otpId = response.otpId;
      _dialogService.showDialog(
        title: 'OTP Sent',
        description: 'A new OTP has been sent to $phoneNumber.',
      );
    } catch (e) {
      _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to resend OTP. Please check your connection.',
      );
    } finally {
      setBusy(false);
    }
  }
}
