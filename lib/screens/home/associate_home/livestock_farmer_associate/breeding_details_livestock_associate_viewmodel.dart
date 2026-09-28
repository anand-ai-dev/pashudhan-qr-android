import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/repository/breeding_repository.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:pashudhan_qr/widgets/qr_scanner_screen.dart';
import 'package:pashudhan_qr/screens/reports/livestock_details_associate_view.dart';
import 'package:pashudhan_qr/screens/reports/livestock_full_report_screen.dart';

class BreedingDetailsLivestockAssociateViewModel extends BaseViewModel {
  final _repository = locator<BreedingRepository>();
  final _livestockRepository = locator<PashudhanRepository>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _storage = locator<StorageService>();

  // ── Fields ──────────────────────────────────────────────────────────
  /// Selected insemination type — "AI" or "NATURAL"
  String inseminationType = "NATURAL";

  /// Bull breed (for NATURAL) — user input via text field
  String bullBreed = "";

  /// Straw no (for ARTIFICIAL) — user input via text field
  String strawNo = "";

  /// Date of insemination — picked via calendar
  String? dateOfInsemination;

  /// Date of calving — picked via calendar
  String? dateOfCalving;

  /// Number of calves — user input via text field
  final calvesController = TextEditingController();

  /// Bull breed controller
  final bullBreedController = TextEditingController();

  /// Straw no controller
  final strawNoController = TextEditingController();

  /// Mobile search controller
  final mobileController = TextEditingController();

  // ── Livestock selection ──────────────────────────────────────────────
  List<Pashudhan> livestocks = [];
  Pashudhan? selectedLivestock;
  bool isLivestockLocked = false;

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

  void setInseminationType(String type) {
    inseminationType = type;
    notifyListeners();
  }

  /// Called when user selects from the insemination type dropdown
  void onInseminationTypeChanged(String? value) {
    if (value != null) {
      inseminationType = value;
      notifyListeners();
    }
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
      livestocks = await _livestockRepository.getPashudhanList(userName: mobile);
      if (!isLivestockLocked) {
        selectedLivestock = null;
      }
      if (livestocks.isEmpty) {
        _showError("No livestock found for this number.");
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) {
        _showError("No livestock found.");
      } else if (status == 400) {
        _showError("Invalid mobile number format.");
      } else {
        _showError(e.message ?? "Failed to fetch livestock.");
      }
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // ── Date picker ──────────────────────────────────────────────────────
  Future<void> selectInseminationDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF452B14),
            onPrimary: Color(0xFFEDC93A),
            surface: Color(0xFFEDC93A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      dateOfInsemination = picked.toIso8601String();
      notifyListeners();
    }
  }

  String get inseminationDateLabel {
    if (dateOfInsemination == null) return 'DATE OF INSEMINATION';
    return dateOfInsemination!.substring(0, 10);
  }

  Future<void> selectCalvingDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF452B14),
            onPrimary: Color(0xFFEDC93A),
            surface: Color(0xFFEDC93A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      dateOfCalving = picked.toIso8601String();
      notifyListeners();
    }
  }

  String get calvingDateLabel {
    if (dateOfCalving == null) return 'DATE OF CALVING';
    return dateOfCalving!.substring(0, 10);
  }

  // ── Submit ───────────────────────────────────────────────────────────
  Future<void> submit(BuildContext context) async {
    if (selectedLivestock == null || !isLivestockLocked) {
      _showError("Select and confirm livestock");
      return;
    }

    final calves = int.tryParse(calvesController.text.trim()) ?? 0;
    if (calves <= 0) {
      _showError("Enter a valid number of calves (must be > 0)");
      return;
    }

    if (inseminationType == "NATURAL" && bullBreedController.text.trim().isEmpty) {
      _showError("Enter the bull breed for natural insemination");
      return;
    }

    if (inseminationType == "AI" && strawNoController.text.trim().isEmpty) {
      _showError("Enter the straw number for artificial insemination");
      return;
    }

    if (dateOfInsemination == null) {
      _showError("Please select the date of insemination");
      return;
    }

    setBusy(true);
    try {
      final data = {
        "pashudhanUuid": selectedLivestock!.uuid,
        "inseminationType": inseminationType == "AI" ? "ARTIFICIAL" : "NATURAL",
        "bullBreed": inseminationType == "NATURAL"
            ? bullBreedController.text.trim()
            : "N/A",
        "strawNo": inseminationType == "AI"
            ? strawNoController.text.trim()
            : "N/A",
        "numberOfCalves": calves,
        "dateOfInsemination": dateOfInsemination,
        "dateOfCalving": dateOfCalving,
      };

      await _repository.createBreedingReport(data);

      // ── 2-second success snackbar → then navigate home ───────────────
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Breeding details added successfully!',
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
    calvesController.dispose();
    bullBreedController.dispose();
    strawNoController.dispose();
    mobileController.dispose();
    super.dispose();
  }
}
