import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/repository/auth_repository.dart';
import 'package:pashudhan_qr/repository/dto/otp_dtos.dart';
import 'package:pashudhan_qr/repository/dto/user_dtos.dart';
import 'package:pashudhan_qr/repository/user_repository.dart';
import 'package:pashudhan_qr/core/exceptions.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'add_livestock_details_livestock_associate.dart';

class LivestockMemberDetailsLivestockAssociateViewModel extends BaseViewModel {
  final _log = getLogger('LivestockMemberDetailsVM');
  final _authRepo = locator<AuthRepository>();
  final _userRepo = locator<UserRepository>();
  final _dialogService = locator<DialogService>();

  /// Mobile number passed from the home screen / quick actions (optional)
  final String? initialMobile;
  final bool returnToPreviousFlow;

  LivestockMemberDetailsLivestockAssociateViewModel({
    this.initialMobile,
    this.returnToPreviousFlow = false,
  });

  // ── Controllers (visible fields on UI) ─────────────────────────────
  final mobileController = TextEditingController();
  final nameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final genderController = TextEditingController();
  final pincodeController = TextEditingController();
  final aadharController = TextEditingController();
  final locationController = TextEditingController();
  final otpController = TextEditingController();

  void setGender(String value) {
    genderController.text = value;
    notifyListeners();
  }

  // ── Location ───────────────────────────────────────────────────────
  double? _latitude;
  double? _longitude;
  bool isFetchingLocation = false;
  String? locationError;

  // ── OTP State ──────────────────────────────────────────────────────
  int? _otpId;
  bool _otpSent = false;
  bool get otpSent => _otpSent;

  bool _otpVerified = false;
  bool get otpVerified => _otpVerified;

  bool _isSendingOtp = false;
  bool get isSendingOtp => _isSendingOtp;

  bool _isVerifyingOtp = false;
  bool get isVerifyingOtp => _isVerifyingOtp;

  String? _otpError;
  String? get otpError => _otpError;

  // ── Init ───────────────────────────────────────────────────────────
  void initialize() {
    if (initialMobile != null && initialMobile!.isNotEmpty) {
      mobileController.text = initialMobile!;
      sendOtp();
    }
    mobileController.addListener(_onMobileChanged);
    fetchLocation();
  }

  Future<void> fetchLocation() async {
    isFetchingLocation = true;
    locationError = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
          
      _latitude = position.latitude;
      _longitude = position.longitude;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final addressParts = [
            place.subLocality,
            place.locality,
            place.administrativeArea,
          ].where((part) => part != null && part.isNotEmpty).toList();
          
          if (addressParts.isNotEmpty) {
            locationController.text = addressParts.join(', ');
          }
          if (place.postalCode != null && place.postalCode!.isNotEmpty && place.postalCode!.length == 6) {
             pincodeController.text = place.postalCode!;
          }
        }
      } catch (e) {
        _log.w('Geocoding failed: $e');
        locationController.text = '${position.latitude}, ${position.longitude}';
      }
    } catch (e) {
      locationError = e.toString().replaceAll('Exception: ', '');
      _log.e('fetchLocation error: $e');
    } finally {
      isFetchingLocation = false;
      notifyListeners();
    }
  }

  void _onMobileChanged() {
    if (_otpSent || _otpVerified) {
      _otpSent = false;
      _otpVerified = false;
      _otpId = null;
      _otpError = null;
      notifyListeners();
    }
  }

  // ── Send OTP → GET /v1/otp/{userName} ──────────────────────────────
  Future<void> sendOtp() async {
    final mobile = mobileController.text.trim();
    if (mobile.length != 10) {
      _otpError = 'Invalid mobile number.';
      notifyListeners();
      return;
    }

    _isSendingOtp = true;
    _otpError = null;
    notifyListeners();

    try {
      final response = await _authRepo.generateOtp(mobile);
      if (response != null) {
        _otpId = response.otpId;
        _otpSent = true;
        _log.i('OTP sent successfully. otpId=$_otpId');
      } else {
        _otpError = 'Failed to send OTP. Please try again.';
      }
    } on DioException catch (e) {
      _otpError = _friendlyDioMessage(e, 'sending OTP');
    } catch (e) {
      _otpError = 'Failed to send OTP. Please check your connection.';
      _log.e('sendOtp error: $e');
    } finally {
      _isSendingOtp = false;
      notifyListeners();
    }
  }

  // ── Verify OTP → POST /v1/otp/verify ───────────────────────────────
  Future<void> verifyOtp() async {
    final mobile = mobileController.text.trim();
    final otpText = otpController.text.trim();
    if (otpText.isEmpty) {
      _otpError = 'Please enter the OTP.';
      notifyListeners();
      return;
    }
    final otpInt = int.tryParse(otpText);
    if (otpInt == null) {
      _otpError = 'OTP must be a number.';
      notifyListeners();
      return;
    }
    if (_otpId == null) {
      _otpError = 'OTP session expired. Please resend.';
      notifyListeners();
      return;
    }

    _isVerifyingOtp = true;
    _otpError = null;
    notifyListeners();

    try {
      await _authRepo.verifyOtp(
        VerifyOtpRequest(otpId: _otpId!, otp: otpInt, userName: mobile),
        isSubUserFlow: true,
      );
      _otpVerified = true;
      _log.i('OTP verified successfully for $mobile');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        _otpError = 'Invalid OTP. Please try again.';
      } else {
        _otpError = _friendlyDioMessage(e, 'OTP verification');
      }
    } catch (e) {
      _otpError = 'OTP verification failed. Please try again.';
      _log.e('verifyOtp error: $e');
    } finally {
      _isVerifyingOtp = false;
      notifyListeners();
    }
  }

  // ── Submit → POST /v1/users/createCustomer ─────────────────────────
  Future<void> submit(BuildContext context) async {
    // ── Validate visible fields ──
    final mobile = mobileController.text.trim();
    final name = nameController.text.trim();
    final fatherName = fatherNameController.text.trim();
    final gender = genderController.text.trim();
    final pincode = pincodeController.text.trim();
    final aadhar = aadharController.text.trim();
    final location = locationController.text.trim();

    if (mobile.isEmpty || mobile.length != 10 || int.tryParse(mobile) == null) {
      _showError('Please enter a valid 10-digit mobile number.');
      return;
    }
    if (name.isEmpty) {
      _showError('Please enter the farmer\'s full name.');
      return;
    }
    if (fatherName.isEmpty) {
      _showError('Please enter the father\'s name.');
      return;
    }
    if (gender.isEmpty) {
      _showError('Please select a gender.');
      return;
    }
    if (pincode.isEmpty ||
        pincode.length != 6 ||
        int.tryParse(pincode) == null) {
      _showError('Please enter a valid 6-digit pincode.');
      return;
    }
    if (location.isEmpty) {
      _showError('Please enter the location.');
      return;
    }
    if (aadhar.isNotEmpty && (aadhar.length != 12 || int.tryParse(aadhar) == null)) {
      _showError('If provided, Aadhar must be a valid 12-digit number.');
      return;
    }
    if (!_otpVerified) {
      _showError('Please verify the OTP before submitting.');
      return;
    }

    setBusy(true);
    try {
      final request = CreateCustomerRequest(
        userName: mobile,
        fullName: name,
        fatherName: fatherName,
        gender: gender.toLowerCase(),
        aadharNumber: aadhar.isEmpty ? '' : aadhar,
        address: location,
        pinCode: int.tryParse(pincode) ?? 0,
        deviceId: 'NA',
        caste: 'NA',
        latitude: _latitude,
        longitude: _longitude,
      );

      final customer = await _userRepo.createCustomer(
        request,
        preserveExistingSession: true,
      );
      if (returnToPreviousFlow) {
        await _userRepo.approveCustomer(customer.id, true);
      }

      await _dialogService.showDialog(
        title: 'Success! 🎉',
        description: 'Livestock farmer registered successfully.',
      );

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AddLivestockDetailsLivestockAssociate(initialMobile: mobile),
          ),
        );
      }
    } on DioException catch (e) {
      final msg = _friendlyDioMessage(e, 'customer registration').toLowerCase();
      final isAlreadyRegistered = e.response?.statusCode == 409 ||
          msg.contains('already registered') ||
          (e.response?.statusCode == 403 && msg.contains('otp not verified'));

      if (isAlreadyRegistered) {
        _log.i(
            'Farmer has an active role (already registered). Proceeding anyway.');
        if (context.mounted) {
          if (returnToPreviousFlow) {
            Navigator.of(context).pop(true);
          } else {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
        return;
      }
      _showError(msg);
    } on ServerException catch (e) {
      if (e.message.toLowerCase().contains('otp not verified')) {
        _log.i(
            'Farmer has an active role (already registered via ServerException). Proceeding anyway.');
        if (context.mounted) {
          if (returnToPreviousFlow) {
            Navigator.of(context).pop(true);
          } else {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
        return;
      }
      _showError(e.message);
    } catch (e) {
      _showError('Registration failed. Please try again.');
    } finally {
      setBusy(false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────

  void _showError(String msg) {
    _dialogService.showDialog(title: 'Oops!', description: msg);
  }

  String _friendlyDioMessage(DioException e, String context) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    switch (status) {
      case 400:
        return 'User already registered or invalid data for $context.';
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return 'You are not authorized for $context.';
      case 404:
        return 'Resource not found for $context.';
      case 409:
        return 'This user is already registered.';
      case 500:
        return 'Server error during $context. Try again later.';
      case 503:
        return 'Service unavailable. Try again shortly.';
      default:
        return e.message ?? 'Network error during $context.';
    }
  }

  @override
  void dispose() {
    mobileController.removeListener(_onMobileChanged);
    mobileController.dispose();
    nameController.dispose();
    fatherNameController.dispose();
    genderController.dispose();
    pincodeController.dispose();
    aadharController.dispose();
    locationController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
