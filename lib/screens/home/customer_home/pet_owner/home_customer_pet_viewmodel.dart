import 'dart:typed_data';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/repository/dto/pet_dtos.dart';
import 'package:pashudhan_qr/repository/pet_repository.dart';
import 'package:pashudhan_qr/repository/user_repository.dart';
import 'package:pashudhan_qr/screens/profile/profile_view.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:pashudhan_qr/widgets/qr_scanner_screen.dart';
import 'package:pashudhan_qr/screens/reports/pet_full_report_screen.dart';
import 'package:pashudhan_qr/repository/vaccination_repository.dart' as pashudhan_qr_vaccination;
import 'package:pashudhan_qr/repository/deworming_repository.dart' as pashudhan_qr_deworming;
import 'package:pashudhan_qr/repository/breeding_repository.dart' as pashudhan_qr_breeding;

class HomeCustomerPetViewModel extends BaseViewModel {
  final _logger = getLogger('HomeCustomerPetViewModel');
  final _petRepository = locator<PetRepository>();
  final _userRepository = locator<UserRepository>();
  final _storage = locator<StorageService>();

  // ── State ──────────────────────────────────────────────
  String _userName = '';
  String get userName => _userName;

  Uint8List? _profilePicBytes;
  Uint8List? get profilePicBytes => _profilePicBytes;
  bool _isFetchingPic = false;
  bool get isFetchingPic => _isFetchingPic;

  int _notificationCount = 0;
  int get notificationCount => _notificationCount;

  int _totalPets = 0;
  int get totalPets => _totalPets;

  // Pet category counts keyed by type from the summary API
  final Map<String, int> _categoryCounts = {};

  int get dogCount => _categoryCounts['DOG'] ?? 0;
  int get catCount => _categoryCounts['CAT'] ?? 0;
  // Legacy compatibility getters used by the view
  int get maleDogCount => dogCount;
  int get femaleDogCount => 0; // Summary doesn't split by gender; keep 0

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Init ───────────────────────────────────────────────
  Future<void> initialize() async {
    setBusy(true);
    _errorMessage = null;

    await Future.wait([
      _loadUserName(),
      _loadSummary(),
      _loadProfilePic(),
      _loadRemindersCount(),
    ]);

    setBusy(false);
    notifyListeners();
  }

  Future<void> _loadRemindersCount() async {
    try {
      final vaccinations = await locator<pashudhan_qr_vaccination.VaccinationRepository>().getVaccinations();
      final dewormings = await locator<pashudhan_qr_deworming.DewormingRepository>().getDewormings();
      final breedings = await locator<pashudhan_qr_breeding.BreedingRepository>().getBreedingReports();

      int count = 0;
      final now = DateTime.now().subtract(const Duration(days: 1));

      DateTime? parseDateSafe(String? dateStr) {
        if (dateStr == null || dateStr.isEmpty) return null;
        try {
          if (int.tryParse(dateStr) != null) {
            return DateTime.fromMillisecondsSinceEpoch(int.parse(dateStr));
          }
          return DateTime.parse(dateStr);
        } catch (_) {
          return null;
        }
      }

      final pets = await _petRepository.getPets();
      final petUuids = pets.map((p) => p.uuid).toSet();

      for (var v in vaccinations) {
        if (v.animalType != 'PET') continue;
        final due = parseDateSafe(v.nextDueDate);
        if (due != null && due.isAfter(now)) count++;
      }
      for (var d in dewormings) {
        final due = parseDateSafe(d.nextDueDate);
        if (due != null && due.isAfter(now)) count++;
      }
      for (var b in breedings) {
        if (!petUuids.contains(b.pashudhanUuid)) continue;
        final due = parseDateSafe(b.dateOfCalving);
        if (due != null && due.isAfter(now)) count++;
      }
      
      _notificationCount = count;
    } catch (e) {
      _logger.e('Error loading reminders count: $e');
    }
  }

  Future<void> _loadUserName() async {
    try {
      final name = await _storage.getCustomData('user_name');
      _userName = name ?? 'User';
      _logger.i('Username loaded: $_userName');
    } catch (e) {
      _logger.w('Could not load username: $e');
      _userName = 'User';
    }
  }

  Future<void> _loadSummary() async {
    try {
      final List<PetAggregationResponseDto> summary =
          await _petRepository.getPetSummary();

      _totalPets = 0;
      _categoryCounts.clear();

      for (final item in summary) {
        final type = item.type.toUpperCase();
        _categoryCounts[type] = item.count;
        _totalPets += item.count;
      }

      _logger.i('Pet summary loaded: total=$_totalPets, cats=$_categoryCounts');
    } catch (e) {
      _logger.e('Error loading Pet summary: $e');
      _errorMessage = 'Failed to load pet data.';
    }
  }

  Future<void> _loadProfilePic() async {
    _isFetchingPic = true;
    notifyListeners();
    try {
      _profilePicBytes = await _userRepository.getProfilePic();
    } catch (e) {
      _logger.w('Failed to load profile pic: $e');
    } finally {
      _isFetchingPic = false;
      notifyListeners();
    }
  }

  // ── Actions ────────────────────────────────────────────
  Future<void> refresh() => initialize();

  void onNotificationIconTapped() {}

  void onProfileIconTapped() {
    final ctx = StackedService.navigatorKey?.currentContext;
    if (ctx != null) {
      Navigator.of(ctx).push(
        MaterialPageRoute(builder: (_) => const ProfileView()),
      );
    }
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PetFullReportScreen(pet: pet),
        ),
      );
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
}
