import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/models/pet_model.dart';
import 'package:pashudhan_qr/repository/pet_repository.dart';
import 'package:pashudhan_qr/repository/deworming_repository.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:pashudhan_qr/widgets/qr_scanner_screen.dart';
import 'package:pashudhan_qr/screens/reports/pet_details_associate_view.dart';
import 'package:pashudhan_qr/screens/reports/pet_full_report_screen.dart';

class DewormingDetailsPetOwnerAssociateViewModel extends BaseViewModel {
  final _petRepository = locator<PetRepository>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _storage = locator<StorageService>();
  final _dewormingRepository = locator<DewormingRepository>();

  final dewormerNameController = TextEditingController();
  final mobileController = TextEditingController();

  List<Pet> pets = [];
  Pet? selectedPet;
  bool isPetLocked = false;
  DateTime? selectedReminderDate;

  // ── Photos ───────────────────────────────────────────────────────────
  File? frontPhoto;
  File? backPhoto;
  final _picker = ImagePicker();

  Future<void> pickFrontPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) {
      frontPhoto = File(picked.path);
      notifyListeners();
    }
  }

  Future<void> pickBackPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) {
      backPhoto = File(picked.path);
      notifyListeners();
    }
  }

  void removeFrontPhoto() {
    frontPhoto = null;
    notifyListeners();
  }

  void removeBackPhoto() {
    backPhoto = null;
    notifyListeners();
  }

  String get formattedReminderDate {
    if (selectedReminderDate == null) return '';
    final year = selectedReminderDate!.year;
    final month = selectedReminderDate!.month.toString().padLeft(2, '0');
    final day = selectedReminderDate!.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> selectReminderDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
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
      selectedReminderDate = picked;
      notifyListeners();
    }
  }


  void initialize() {
    // Initialization logic here
  }

  void selectPet(Pet pet) {
    if (isPetLocked) return;
    selectedPet = pet;
    notifyListeners();
  }

  void lockPet() {
    if (selectedPet == null) {
      _showError("Please select a pet");
      return;
    }
    isPetLocked = true;
    notifyListeners();
  }

  void resetPet() {
    isPetLocked = false;
    selectedPet = null;
    notifyListeners();
  }

  Future<void> fetchPets() async {
    final mobile = mobileController.text.trim();
    if (mobile.length != 10) {
      _showError("Enter valid 10-digit mobile number");
      return;
    }

    setBusy(true);
    try {
      pets = await _petRepository.getPets(userName: mobile);
      if (!isPetLocked) {
        selectedPet = null;
      }
      if (pets.isEmpty) {
        _showError("No pets found for this number.");
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) {
        _showError("No pets found.");
      } else if (status == 400) {
        _showError("Invalid mobile number format.");
      } else {
        _showError(e.message ?? "Failed to fetch pets.");
      }
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> submit(BuildContext context) async {
    final dewormerName = dewormerNameController.text.trim();
    if (dewormerName.isEmpty) {
      _showError("Enter dewormer name");
      return;
    }
    if (selectedPet == null || !isPetLocked) {
      _showError("Select and confirm pet");
      return;
    }
    if (selectedReminderDate == null) {
      _showError("Please select the next deworming reminder date");
      return;
    }
    if (frontPhoto == null || backPhoto == null) {
      _showError("Please upload both front and back photos of the dewormer");
      return;
    }

    setBusy(true);
    try {
      final reminderData = {
        "petUuid": selectedPet!.uuid,
        "medicineName": dewormerName,
        "dewormingDate": DateTime.now().toIso8601String(),
        "nextDueDate": formattedReminderDate,
        "notes": "Deworming added via app",
      };
      
      final created = await _dewormingRepository.createDeworming(reminderData);

      // Upload photos sequentially
      if (frontPhoto != null) {
        final bytes = await frontPhoto!.readAsBytes();
        await _dewormingRepository.uploadPhoto(created.uuid, bytes, 'front_photo.jpg', 'FRONT');
      }
      if (backPhoto != null) {
        final bytes = await backPhoto!.readAsBytes();
        await _dewormingRepository.uploadPhoto(created.uuid, bytes, 'back_photo.jpg', 'BACK');
      }

      // ── Success snackbar → then navigate home ─────────────────────
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Deworming added successfully!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      await Future.delayed(const Duration(seconds: 2));
      _navigationService.clearStackAndShow(Routes.homePetOwnerAssociate);

    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 422) {
        _showError("Invalid input data provided.");
      } else if (status == 409) {
        _showError("Duplicate record found.");
      } else if (status == 503) {
        _showError("Server is temporarily busy. Please try again later.");
      } else {
        _showError(e.message ?? "Failed to add deworming details.");
      }
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      setBusy(false);
    }
  }

  void _showError(String msg) {
    _dialogService.showDialog(title: 'Oops!', description: msg);
  }

  Future<void> scanQr(BuildContext context) async {
    final scannedString = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (scannedString == null || scannedString.trim().isEmpty) return;
    if (!context.mounted) return;

    final id = scannedString.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFEDC93A)),
      ),
    );

    try {
      final pet = await _petRepository.getPet(id);
      if (!context.mounted) return;
      Navigator.of(context).pop();

      final role = await _storage.getCustomData('user_role');
      if (role == 'ASSOCIATE' || role == 'ASSOCIATE_PARTNER') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PetDetailsAssociateView(pet: pet),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PetFullReportScreen(pet: pet),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      
      String msg = 'Failed to fetch data';
      if (e.toString().contains('404')) msg = 'No record found';
      if (e.toString().contains('403')) msg = 'Not authorized';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFF452B14),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    dewormerNameController.dispose();
    mobileController.dispose();
    super.dispose();
  }
}
