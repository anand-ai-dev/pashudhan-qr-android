import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/core/exceptions.dart';
import 'package:pashudhan_qr/repository/auth_repository.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LoginViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authRepository = locator<AuthRepository>();
  final _dialogService = locator<DialogService>();

  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;

  /// Guard flag — prevents duplicate OTP requests from rapid taps / rebuilds.
  bool _isRequestingOtp = false;

  /// 🔹 The missing init method to fix the View error
  void init() {
    // You can initialize logic here (e.g., checking if user is already logged in)
  }

  /// 🔹 Updates the phone number and refreshes the UI
  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  /// 🔹 Helper to check if the number is complete and numeric
  bool get isPhoneNumberValid {
    final trimmed = _phoneNumber.trim();
    return trimmed.length == 10 && RegExp(r"^\d+$").hasMatch(trimmed);
  }

  /// 🔹 Main login logic — ONE OTP call per tap, no matter what.
  Future<void> onGetStarted() async {
    // 1. Debounce: already waiting on API or Stacked busy state → ignore tap.
    if (_isRequestingOtp || isBusy) return;

    // 2. Basic Validation
    if (!isPhoneNumberValid) {
      await _dialogService.showDialog(
        title: 'Invalid Number',
        description: 'Please enter a valid 10-digit mobile number.',
      );
      return;
    }

    _isRequestingOtp = true;
    setBusy(true);

    try {
      // 3. Call the Auth Repository — exactly once
      final response = await _authRepository.generateOtp(_phoneNumber.trim());

      if (response != null) {
        // 4. Success: Navigate to OTP View with the returned otpId
        _navigationService.navigateToOtpVerifyView(
          phoneNumber: _phoneNumber.trim(),
          otpId: response.otpId, // ONLY this id must be used downstream
        );
      } else {
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to generate OTP. Please try again.',
        );
      }
    } catch (e) {
      // 5. Catch Network/API Errors
      await _dialogService.showDialog(
        title: 'Error',
        description: _friendlyErrorMessage(e),
      );
    } finally {
      // 6. Always release locks
      _isRequestingOtp = false;
      setBusy(false);
    }
  }

  String _friendlyErrorMessage(Object error) {
    if (error is ServerException) {
      return error.message;
    }
    if (error is UnauthenticatedException) {
      return error.message;
    }
    return 'Unable to generate OTP. Please try again.';
  }
}
