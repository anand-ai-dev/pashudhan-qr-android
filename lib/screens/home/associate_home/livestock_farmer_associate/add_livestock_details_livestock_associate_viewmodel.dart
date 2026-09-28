import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/core/exceptions.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/repository/dto/pashudhan_dtos.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/repository/user_repository.dart';
import 'package:pashudhan_qr/screens/home/associate_home/livestock_farmer_associate/muzzle_photo_upload_livestock_associate.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'livestock_member_details_livestock_associate.dart';

class AddLivestockDetailsLivestockAssociateViewModel extends BaseViewModel {
  final _pashudhanRepository = locator<PashudhanRepository>();
  final _userRepository = locator<UserRepository>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  final String? initialMobile;

  AddLivestockDetailsLivestockAssociateViewModel({this.initialMobile});

  String _selectedLivestockType = 'COW';
  String get selectedLivestockType => _selectedLivestockType;

  String? selectedGender;

  bool _ownerConfirmed = false;
  bool get ownerConfirmed => _ownerConfirmed;

  String? _confirmedOwnerMobile;
  String? get confirmedOwnerMobile => _confirmedOwnerMobile;

  final lfMobileController = TextEditingController();
  final breedController = TextEditingController();
  final ageController = TextEditingController();
  final lactationNoController = TextEditingController();
  final livestockNameController = TextEditingController();
  final weightController = TextEditingController();
  final idNoController = TextEditingController();

  void initialize() {
    if (initialMobile != null) {
      lfMobileController.text = initialMobile!;
    }
  }

  String? selectedLactationNumber;
  DateTime? selectedAgeDate;

  void setSelectedLactationNumber(String value) {
    selectedLactationNumber = value;
    notifyListeners();
  }

  int get calculatedAgeInMonths {
    if (selectedAgeDate == null) return 0;
    final now = DateTime.now();
    int months = (now.year - selectedAgeDate!.year) * 12 + now.month - selectedAgeDate!.month;
    if (now.day < selectedAgeDate!.day) {
      months--;
    }
    return months < 0 ? 0 : months;
  }

  Future<void> selectAgeDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedAgeDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF452B14),
              onPrimary: Color(0xFFEDC93A),
              onSurface: Color(0xFF452B14),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF452B14),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedAgeDate = picked;
      notifyListeners();
    }
  }

  void setLivestockType(String value) {
    _selectedLivestockType = value;
    notifyListeners();
  }

  void setGender(String? value) {
    selectedGender = value;
    notifyListeners();
  }

  Future<void> continueWithOwner(BuildContext context) async {
    final mobile = lfMobileController.text.trim();
    if (!_isValidMobile(mobile)) {
      _showError(
          'Please enter a valid 10-digit livestock farmer mobile number.');
      return;
    }

    setBusy(true);
    try {
      final status =
          await _userRepository.getCustomerRegistrationStatus(mobile);
      if (status.registered) {
        _ownerConfirmed = true;
        _confirmedOwnerMobile = mobile;
        notifyListeners();
        return;
      }

      await _promptOwnerRegistration(mobile);
    } on DioException catch (e) {
      _showError(_friendlyDioMessage(e));
    } catch (_) {
      _showError('Unable to check owner registration. Please try again.');
    } finally {
      setBusy(false);
    }
  }

  Future<void> registerOwnerThenContinue(BuildContext context) async {
    final mobile = lfMobileController.text.trim();
    if (!_isValidMobile(mobile)) {
      _showError(
          'Please enter a valid 10-digit mobile number before registering the farmer.');
      return;
    }

    final registered = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LivestockMemberDetailsLivestockAssociate(
          ownerMobile: mobile,
          returnToPreviousFlow: true,
        ),
      ),
    );

    if (registered == true) {
      _ownerConfirmed = true;
      _confirmedOwnerMobile = mobile;
      notifyListeners();
    }
  }

  void resetOwner() {
    _ownerConfirmed = false;
    _confirmedOwnerMobile = null;
    notifyListeners();
  }

  Future<void> submit() async {
    final mobile = _confirmedOwnerMobile ?? lfMobileController.text.trim();
    final breed = breedController.text.trim();
    final name = livestockNameController.text.trim();
    final weight = weightController.text.trim();
    final earTag = idNoController.text.trim();

    if (!_ownerConfirmed || !_isValidMobile(mobile)) {
      _showError('Please complete owner information first.');
      return;
    }
    if (name.isEmpty) {
      _showError('Please enter the livestock name.');
      return;
    }
    if (breed.isEmpty) {
      _showError('Please enter the breed.');
      return;
    }
    if (selectedAgeDate == null) {
      _showError('Please select the birth date/age from the calendar.');
      return;
    }
    if (selectedLactationNumber == null) {
      _showError('Please select a lactation number.');
      return;
    }
    if (weight.isEmpty || double.tryParse(weight) == null) {
      _showError('Please enter a valid weight in kg.');
      return;
    }
    if (earTag.isEmpty) {
      _showError('Please enter the livestock ID / ear tag number.');
      return;
    }

    setBusy(true);
    try {
      final request = CreatePashudhanRequest(
        category: _selectedLivestockType,
        name: name,
        breed: breed,
        gender: selectedGender,
        lactationNumber: int.tryParse(selectedLactationNumber?.replaceAll('+', '') ?? '0') ?? 0,
        milkYield: 1,             // hardcoded — not visible on UI
        weight: double.tryParse(weight) ?? 0.0,
        heightInCms: 1,
        numCalves: 0,
        earTagNumber: earTag,
        ageRecordedAt: DateTime.now().toIso8601String(),
        ageInMonths: calculatedAgeInMonths,
        ownerUserName: mobile,
      );

      final pashudhan =
          await _createPashudhanWithOwnerRecovery(request, mobile);

      await _dialogService.showDialog(
        title: 'Success',
        description:
            'Livestock registered successfully. Scan muzzle photos next.',
      );

      _navigationService.replaceWithTransition(
        MuzzlePhotoUploadLivestockAssociate(pashudhan: pashudhan),
      );
    } on DioException catch (e) {
      await _handleCreateFailure(e, mobile);
    } on ServerException catch (e) {
      // 503 / 502 from ApiClientService — show the message directly.
      _showError(e.message);
    } catch (e) {
      await _handleGenericFailure(e, mobile);
    } finally {
      setBusy(false);
    }
  }

  Future<Pashudhan> _createPashudhanWithOwnerRecovery(
    CreatePashudhanRequest request,
    String mobile,
  ) async {
    try {
      return await _pashudhanRepository.createPashudhan(request);
    } on DioException catch (e) {
      final message = _friendlyDioMessage(e).toLowerCase();
      if (e.response?.statusCode == 409 && message.contains('owner')) {
        final approved = await _approveRegisteredOwner(mobile);
        if (approved) {
          return await _pashudhanRepository.createPashudhan(request);
        }
      }
      rethrow;
    }
  }

  Future<bool> _approveRegisteredOwner(String mobile) async {
    try {
      final status =
          await _userRepository.getCustomerRegistrationStatus(mobile);
      if (!status.registered || status.customerId == null) {
        return false;
      }
      if (!status.approved) {
        await _userRepository.approveCustomer(status.customerId!, true);
      }
      _ownerConfirmed = true;
      _confirmedOwnerMobile = mobile;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleCreateFailure(DioException e, String mobile) async {
    final message = _friendlyDioMessage(e);
    final lower = message.toLowerCase();

    // If it explicitly says the owner/farmer is not registered
    if (lower.contains('owner') && lower.contains('not registered') || lower.contains('not found')) {
      await _promptOwnerRegistration(mobile);
      return;
    }

    if (e.response?.statusCode == 400 && lower == 'livestock owner is not registered. please register the farmer first.') {
      await _promptOwnerRegistration(mobile);
      return;
    }

    if (e.response?.statusCode == 409 && lower.contains('owner')) {
      _showError(
        'Farmer is registered but not verified yet. Please try Submit again after approval, or contact admin/support if it continues.',
      );
      return;
    }

    _showError(message);
  }

  Future<void> _handleGenericFailure(Object e, String mobile) async {
    final message = e.toString().toLowerCase();
    if (message.contains('not registered')) {
      await _promptOwnerRegistration(mobile);
      return;
    }
    _showError('Something went wrong. Please try again.');
  }

  Future<void> _promptOwnerRegistration(
    String mobile, {
    String title = 'Farmer Not Registered',
  }) async {
    final confirm = await _dialogService.showConfirmationDialog(
      title: title,
      description:
          'Complete owner registration for mobile $mobile, then continue cattle registration.',
      confirmationTitle: 'Register',
      cancelTitle: 'Cancel',
    );

    if (confirm?.confirmed != true) return;

    final context = StackedService.navigatorKey?.currentContext;
    if (context != null && context.mounted) {
      await registerOwnerThenContinue(context);
    }
  }

  bool _isValidMobile(String mobile) {
    return mobile.length == 10 && int.tryParse(mobile) != null;
  }

  void _showError(String msg) {
    _dialogService.showDialog(title: 'Oops!', description: msg);
  }

  String _friendlyDioMessage(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map) {
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['errors'] != null) {
        if (data['errors'] is List) {
          return (data['errors'] as List).join('\n');
        }
        return data['errors'].toString();
      }
    }
    switch (status) {
      case 400:
        return 'Invalid input data. Please check your fields.';
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return 'You are not authorized to register livestock.';
      case 409:
        return 'This ear-tag number is already registered, or the owner is not verified.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Try again shortly.';
      default:
        return e.message ?? 'Network error. Check your connection.';
    }
  }

  @override
  void dispose() {
    lfMobileController.dispose();
    breedController.dispose();
    ageController.dispose();
    lactationNoController.dispose();
    livestockNameController.dispose();
    weightController.dispose();
    idNoController.dispose();
    super.dispose();
  }
}
