import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/repository/pet_repository.dart';
import 'package:pashudhan_qr/repository/dto/pet_dtos.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'livestock_member_details_petowner_associate.dart';

class AddLivestockDetailsPetOwnerAssociateViewModel extends BaseViewModel {
  final _petRepository = locator<PetRepository>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  final String? initialMobile;

  AddLivestockDetailsPetOwnerAssociateViewModel({this.initialMobile});

  String _selectedPetType = 'DOG';
  String get selectedPetType => _selectedPetType;

  String? selectedGender;

  // Controllers — only for fields visible on UI
  final ownerMobileController = TextEditingController();
  final breedController = TextEditingController();
  final dobController = TextEditingController();
  final breedingNoController = TextEditingController();
  final petNameController = TextEditingController();
  final weightController = TextEditingController();
  final petIdNoController = TextEditingController();

  // ── Photos ───────────────────────────────────────────────────────────
  List<File> capturedPhotos = [];
  final _picker = ImagePicker();

  Future<void> capturePhoto() async {
    if (capturedPhotos.length >= 5) {
      _showError("Maximum 5 photos allowed.");
      return;
    }
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) {
      capturedPhotos.add(File(picked.path));
      notifyListeners();
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < capturedPhotos.length) {
      capturedPhotos.removeAt(index);
      notifyListeners();
    }
  }

  void setPetType(String value) {
    _selectedPetType = value;
    notifyListeners();
  }

  void setGender(String? value) {
    selectedGender = value;
    notifyListeners();
  }

  void initialize() {
    if (initialMobile != null) {
      ownerMobileController.text = initialMobile!;
    }
  }

  Future<void> submit() async {
    // ── Validate all visible fields ──────────────────────────────────
    final mobile = ownerMobileController.text.trim();
    final breed = breedController.text.trim();
    final dob = dobController.text.trim(); // optional/can be current date if empty

    final breedingNo = breedingNoController.text.trim();
    final name = petNameController.text.trim();
    final weight = weightController.text.trim();
    final petId = petIdNoController.text.trim();

    if (mobile.isEmpty) {
      _showError('Mobile number is required to identify the pet owner.');
      return;
    }
    if (mobile.length != 10 || int.tryParse(mobile) == null) {
      _showError('Please enter a valid 10-digit mobile number.');
      return;
    }
    if (name.isEmpty) {
      _showError('Please enter the pet name.');
      return;
    }
    if (breed.isEmpty) {
      _showError('Please enter the breed.');
      return;
    }
    if (weight.isEmpty || double.tryParse(weight) == null) {
      _showError('Please enter a valid weight in kg.');
      return;
    }
    if (petId.isEmpty) {
      _showError('Please enter the pet ID number.');
      return;
    }
    if (capturedPhotos.length < 3) {
      _showError('Please capture at least 3 photos before submitting.');
      return;
    }

    // ── Build request ────────────────────────────────────────────────
    setBusy(true);
    try {
      final request = CreatePetRequest(
        ownerUserName: mobile, // use the mobile number typed in the field
        category: _selectedPetType,
        name: name,
        breed: breed,
        gender: selectedGender,
        weight: double.tryParse(weight) ?? 0.0,
        heightInCms: 24.0,
        numberOfOffspring: int.tryParse(breedingNo) ?? 0,
        petIdNumber: petId,
        ageMonthsAtRecord: 12,
        ageRecordedAt: dob.isNotEmpty ? '${dob}T00:00:00.000Z' : DateTime.now().toIso8601String(),
      );

      final pet = await _petRepository.createPet(request);

      // Upload captured photos
      for (int i = 0; i < capturedPhotos.length; i++) {
        final bytes = await capturedPhotos[i].readAsBytes();
        await _petRepository.uploadVisual(pet.uuid, bytes, 'pet_photo_${i + 1}.jpg');
      }

      // ── Success → pet registered under existing customer ─────
      _dialogService.showDialog(
        title: 'Success! 🎉',
        description: 'Pet registered successfully under mobile $mobile.',
      );

      // Navigate back to home screen
      _navigationService.clearStackAndShow(Routes.homePetOwnerAssociate);
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 400) {
        final message = _friendlyDioMessage(e);
        if (message.toLowerCase().contains('not registered')) {
          // Owner not registered → go to customer registration screen
          final confirm = await _dialogService.showConfirmationDialog(
            title: 'Pet Owner Not Registered',
            description:
                'No customer found with mobile $mobile. Would you like to register this owner first?',
            confirmationTitle: 'Register',
            cancelTitle: 'Cancel',
          );
          if (confirm?.confirmed == true) {
            _navigationService.navigateToView(
              LivestockMemberDetailsPetOwnerAssociate(ownerMobile: mobile),
            );
          }
        } else {
          _showError(message);
        }
      } else {
        _showError(_friendlyDioMessage(e));
      }
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      setBusy(false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Future<void> selectDob(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = picked.toIso8601String().substring(0, 10);
      notifyListeners();
    }
  }

  void _showError(String msg) {
    _dialogService.showDialog(title: 'Oops!', description: msg);
  }

  String _friendlyDioMessage(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    switch (status) {
      case 400: return 'Pet owner is not registered. Please register the owner first.';
      case 401: return 'Your session has expired. Please log in again.';
      case 403: return 'You are not authorized to register pets.';
      case 409: return 'This pet ID number is already registered, or the owner is not verified.';
      case 500: return 'Server error. Please try again later.';
      case 503: return 'Service temporarily unavailable. Try again shortly.';
      default: return e.message ?? 'Network error. Check your connection.';
    }
  }

  @override
  void dispose() {
    ownerMobileController.dispose();
    breedController.dispose();
    dobController.dispose();

    breedingNoController.dispose();
    petNameController.dispose();
    weightController.dispose();
    petIdNoController.dispose();
    super.dispose();
  }
}
