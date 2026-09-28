import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/repository/vaccination_repository.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:pashudhan_qr/widgets/qr_scanner_screen.dart';
import 'package:pashudhan_qr/screens/reports/livestock_details_associate_view.dart';
import 'package:pashudhan_qr/screens/reports/livestock_full_report_screen.dart';

class VaccinationDetailsLivestockAssociateViewModel extends BaseViewModel {
  final _repository = locator<VaccinationRepository>();
  final _livestockRepository = locator<PashudhanRepository>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _storage = locator<StorageService>();

  // ── Fields ──────────────────────────────────────────────────────────
  /// Vaccine name — typed by user
  final vaccineNameController = TextEditingController();

  /// Mobile search controller
  final mobileController = TextEditingController();

  // ── Livestock selection ──────────────────────────────────────────────
  List<Pashudhan> livestocks = [];
  Pashudhan? selectedLivestock;
  bool isLivestockLocked = false;

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

  void initialize() {}

  void selectLivestock(Pashudhan item) {
    if (isLivestockLocked) return;
    selectedLivestock = item;
    notifyListeners();
  }

  void lockLivestock() {
    print("Locking livestock. Selected: $selectedLivestock");
    if (selectedLivestock == null) {
      _showError("Please select livestock");
      return;
    }
    isLivestockLocked = true;
    print("Locked: $isLivestockLocked");
    notifyListeners();
  }

  void resetLivestock() {
    isLivestockLocked = false;
    selectedLivestock = null;
    notifyListeners();
  }

  // ── Fetch livestock by mobile ────────────────────────────────────────
  Future<void> fetchLivestock() async {
    final mobile = mobileController.text.trim();
    if (mobile.length != 10) {
      _showError("Enter valid 10-digit mobile number");
      return;
    }

    setBusy(true);
    try {
      livestocks =
          await _livestockRepository.getPashudhanList(userName: mobile);
      if (!isLivestockLocked) {
        selectedLivestock = null;
      }
      if (livestocks.isEmpty) {
        _showError("No livestock found for this number.");
      }
    } on DioException catch (e) {
      _showError(_friendlyError(e));
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  DateTime? selectedDate;

  String get formattedSelectedDate {
    if (selectedDate == null) return '';
    final year = selectedDate!.year;
    final month = selectedDate!.month.toString().padLeft(2, '0');
    final day = selectedDate!.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
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
      selectedDate = picked;
      notifyListeners();
    }
  }

  // ── Submit ───────────────────────────────────────────────────────────
  Future<void> submit(BuildContext context) async {
    final vaccineName = vaccineNameController.text.trim();

    if (selectedLivestock == null || !isLivestockLocked) {
      _showError("Select and confirm livestock");
      return;
    }
    if (vaccineName.isEmpty) {
      _showError("Enter the vaccine name");
      return;
    }
    if (selectedDate == null) {
      _showError("Please select the next vaccination reminder date");
      return;
    }
    if (frontPhoto == null || backPhoto == null) {
      _showError("Please upload both front and back photos of the vaccine");
      return;
    }

    setBusy(true);
    try {
      final data = {
        "animalUuid": selectedLivestock!.uuid,
        "animalType": "CATTLE",
        "vaccineName": vaccineName,
        "nextDueDate": formattedSelectedDate,
        "notes": "Added via Pashudhan QR app",
      };

      final created = await _repository.createVaccination(data);

      // Upload photos sequentially
      if (frontPhoto != null) {
        final bytes = await frontPhoto!.readAsBytes();
        await _repository.uploadPhoto(created.uuid, bytes, 'front_photo.jpg', 'FRONT');
      }
      if (backPhoto != null) {
        final bytes = await backPhoto!.readAsBytes();
        await _repository.uploadPhoto(created.uuid, bytes, 'back_photo.jpg', 'BACK');
      }

      // ── 2-second success snackbar → then navigate home ───────────────
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Vaccination added successfully!',
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
      _navigationService.clearStackAndShow(Routes.homeLivestockAssociate);
    } on DioException catch (e) {
      _showError(_friendlyError(e));
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      setBusy(false);
    }
  }

  // ── Error helpers ────────────────────────────────────────────────────
  String _friendlyError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    // Try to get server message first
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    switch (status) {
      case 400:
        return 'Invalid data submitted. Please check your inputs.';
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Resource not found. Please try again.';
      case 409:
        return 'A duplicate record already exists.';
      case 422:
        return 'Some fields have invalid values. Please review and try again.';
      case 500:
        return 'Server error. Please try again in a moment.';
      case 503:
        return 'Service is temporarily unavailable. Please try again shortly.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
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
      final pashudhan = await _livestockRepository.getPashudhan(id);
      if (!context.mounted) return;
      Navigator.of(context).pop();

      final role = await _storage.getCustomData('user_role');
      if (role == 'ASSOCIATE' || role == 'ASSOCIATE_PARTNER') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LivestockDetailsAssociateView(pashudhan: pashudhan),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LivestockFullReportScreen(pashudhan: pashudhan),
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
    vaccineNameController.dispose();
    mobileController.dispose();
    super.dispose();
  }
}
