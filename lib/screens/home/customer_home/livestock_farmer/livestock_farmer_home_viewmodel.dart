import 'dart:typed_data';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/repository/dto/pashudhan_dtos.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/repository/user_repository.dart';
import 'package:pashudhan_qr/screens/profile/profile_view.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:pashudhan_qr/widgets/qr_scanner_screen.dart';
import 'package:pashudhan_qr/screens/reports/livestock_full_report_screen.dart';

class LivestockFarmerHomeViewModel extends BaseViewModel {
  final _logger = getLogger('LivestockFarmerHomeViewModel');
  final _pashudhanRepository = locator<PashudhanRepository>();
  final _userRepository = locator<UserRepository>();
  final _storage = locator<StorageService>();

  // ── State ──────────────────────────────────────────────
  String _userName = '';
  String get userName => _userName;

  Uint8List? _profilePicBytes;
  Uint8List? get profilePicBytes => _profilePicBytes;
  bool _isFetchingPic = false;
  bool get isFetchingPic => _isFetchingPic;

  final int _notificationCount = 0;
  int get notificationCount => _notificationCount;

  int _totalAnimals = 0;
  int get totalAnimals => _totalAnimals;

  // Category counts derived from summary
  final Map<String, int> _categoryCounts = {};

  int get cowCount => _categoryCounts['COW'] ?? 0;
  int get buffaloCount => _categoryCounts['BUFFALO'] ?? 0;
  int get goatCount => _categoryCounts['GOAT'] ?? 0;

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
    ]);

    setBusy(false);
  }

  Future<void> _loadUserName() async {
    try {
      final name = await _storage.getCustomData('user_name');
      _userName = name ?? 'User';
    } catch (e) {
      _logger.w('Could not load username: $e');
      _userName = 'User';
    }
  }

  Future<void> _loadSummary() async {
    try {
      final List<PashudhanAggregationResponseDto> summary =
          await _pashudhanRepository.getPashudhanSummary();

      _totalAnimals = 0;
      _categoryCounts.clear();

      for (final item in summary) {
        final type = item.type.toUpperCase();
        _categoryCounts[type] = item.count;
        _totalAnimals += item.count;
      }

      _logger.i('Summary loaded: total=$_totalAnimals, cats=$_categoryCounts');
    } catch (e) {
      _logger.e('Error loading Pashudhan summary: $e');
      _errorMessage = 'Failed to load livestock data.';
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
      final pashudhan = await _pashudhanRepository.getPashudhan(id);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LivestockFullReportScreen(pashudhan: pashudhan),
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
