import 'package:dio/dio.dart';
import 'package:pashudhan_qr/core/exceptions.dart';
import 'package:pashudhan_qr/repository/auth_repository.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/repository/associate_partner_repository.dart';
import 'package:pashudhan_qr/repository/associate_repository.dart';
import 'package:pashudhan_qr/repository/dto/associate_dtos.dart';
import 'package:pashudhan_qr/repository/dto/user_dtos.dart';
import 'package:pashudhan_qr/repository/user_repository.dart';
import 'package:pashudhan_qr/models/role.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class RegistrationViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _userRepository = locator<UserRepository>();
  final _associatePartnerRepository = locator<AssociatePartnerRepository>();
  final _associateRepository = locator<AssociateRepository>();
  final _storage = locator<StorageService>();
  final _dialogService = locator<DialogService>();

  final UserRole type;
  RegistrationViewModel({required this.type});

  /// ================= FIELDS =================
  String name = '';
  String aadharNo = '';
  String idNo = '';
  String pinCode = '';

  /// ✅ CUSTOMER TYPE
  String selectedCustomerType = 'farmer';

  /// ✅ ASSOCIATE PARTNER LIST
  List<AssociatePartnerResponse> partners = [];
  AssociatePartnerResponse? selectedPartner;

  /// ✅ PARTNER TYPE (FIXED)
  String? selectedPartnerType;

  /// ================= INIT =================
  void init() async {
    if (type == UserRole.ASSOCIATE) {
      setBusy(true);
      try {
        partners = await _associatePartnerRepository.getAssociatePartners();
        notifyListeners();
      } on DioException catch (e) {
        final msg = _extractDioMessage(e);
        _dialogService.showDialog(
          title: 'Could Not Load Partners',
          description: msg,
        );
      } catch (e) {
        _dialogService.showDialog(
          title: 'Could Not Load Partners',
          description:
              'Unable to fetch partner list. Please check your connection and try again.',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  /// ================= SETTERS =================
  void setName(String value) => name = value.trim();
  void setAadharNo(String value) => aadharNo = value.trim();
  void setIdNo(String value) => idNo = value.trim();
  void setPinCode(String value) => pinCode = value.trim();

  void setPartner(AssociatePartnerResponse value) {
    selectedPartner = value;
    notifyListeners();
  }

  void setCustomerType(String value) {
    selectedCustomerType = value;
    notifyListeners();
  }

  void setPartnerType(String value) {
    selectedPartnerType = value;
    notifyListeners();
  }

  /// ================= HELPERS =================
  String _extractDioMessage(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    switch (status) {
      case 400:
        return 'Invalid data submitted. Please check your details and try again.';
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'An account with these details already exists.';
      case 422:
        return 'Some fields have invalid values. Please review and try again.';
      case 500:
        return 'Our server encountered an error. Please try again in a moment.';
      case 503:
        return 'Service is temporarily unavailable. Please try again shortly.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }

  /// ================= SUBMIT =================
  Future<void> onSubmit() async {
    // ── Name validation ──────────────────────────────────────────────
    if (name.isEmpty) {
      _dialogService.showDialog(
        title: 'Name Required',
        description: 'Please enter your full name before continuing.',
      );
      return;
    }

    if (isBusy) return;
    setBusy(true);

    try {
      final userName = await _storage.getCustomData('user_name');

      if (userName == null || userName.isEmpty) {
        _dialogService.showDialog(
          title: 'Session Expired',
          description:
              'Your login session could not be found. Please log in again.',
        );
        return;
      }

      /// ================= CUSTOMER =================
      if (type == UserRole.CUSTOMER) {
        // Prefer auth_token (returning user); fall back to otp_token (new user).
        // UserRepository.createCustomer upgrades otp_token → auth_token on success.
        final token = await _storage.getToken() ?? await _storage.getOtpToken();
        final isVerified = token != null && token.isNotEmpty;
        if (!isVerified) {
          _dialogService.showDialog(
            title: 'Verification Required',
            description:
                'Please complete the OTP verification before registering.',
          );
          return;
        }

        if (pinCode.length != 6 || int.tryParse(pinCode) == null) {
          _dialogService.showDialog(
            title: 'Invalid Pin Code',
            description: 'Please enter a valid 6-digit numeric pin code.',
          );
          return;
        }

        if (aadharNo.length != 12 || int.tryParse(aadharNo) == null) {
          _dialogService.showDialog(
            title: 'Invalid Aadhar Number',
            description: 'Please enter a valid 12-digit numeric Aadhar number.',
          );
          return;
        }

        final res = await _userRepository.createCustomer(
          CreateCustomerRequest(
            fullName: name,
            userName: userName,
            pinCode: int.parse(pinCode),
            aadharNumber: aadharNo,
          ),
        );

        await _storage.saveCustomData('user_id', res.id.toString());
        await _storage.saveCustomData('user_role', type.name);
        await _storage.saveCustomData('user_name', name);

        _navigationService.clearStackAndShow(Routes.splashView);
      }

      /// ================= ASSOCIATE =================
      else if (type == UserRole.ASSOCIATE) {
        if (selectedPartner == null) {
          _dialogService.showDialog(
            title: 'Partner Required',
            description:
                'Please select a partner from the dropdown before continuing.',
          );
          return;
        }

        if (idNo.isEmpty) {
          _dialogService.showDialog(
            title: 'ID Number Required',
            description: 'Please enter your government ID number.',
          );
          return;
        }

        final otpToken = await _storage.getOtpToken();
        if (otpToken == null || otpToken.isEmpty) {
          _dialogService.showDialog(
            title: 'Session Error',
            description:
                'OTP verification token is missing. Please go back and verify your phone number again.',
          );
          return;
        }

        // ── Call POST /v1/associate (uses OTP token via ApiClientService) ──
        final res = await _associateRepository.createAssociate(
          CreateAssociateRequest(
            userName: userName,
            fullName: name,
            partnerId: selectedPartner!.id,
            idNo: idNo,
          ),
        );

        // Persist associate profile data
        await _storage.saveCustomData('user_id', res.id.toString());
        await _storage.saveCustomData('user_role', 'ASSOCIATE');
        await _storage.saveCustomData('user_name', name);
        if (res.partnerType != null) {
          await _storage.saveCustomData('partner_type', res.partnerType!);
        }

        // Navigate to approval pending screen and stop
        _navigationService.clearStackAndShow(Routes.approvalPendingView);
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        locator<AuthRepository>().logout();
        _navigationService.clearStackAndShow(Routes.loginView);
        return;
      }
      _dialogService.showDialog(
        title: 'Registration Failed',
        description: _extractDioMessage(e),
      );
    } on ServerException catch (e) {
      _dialogService.showDialog(
        title: 'Registration Failed',
        description: e.message,
      );
    } catch (e) {
      if (e is UnauthenticatedException) {
        locator<AuthRepository>().logout();
        _navigationService.clearStackAndShow(Routes.loginView);
        return;
      }
      _dialogService.showDialog(
        title: 'Registration Failed',
        description: 'Something unexpected happened. Please try again.',
      );
    } finally {
      setBusy(false);
    }
  }
}
