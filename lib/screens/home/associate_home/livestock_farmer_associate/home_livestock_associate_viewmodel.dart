import 'dart:typed_data';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/repository/dto/pashudhan_dtos.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/repository/user_repository.dart';
import 'package:pashudhan_qr/screens/profile/profile_view.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:pashudhan_qr/widgets/qr_scanner_screen.dart';
import 'package:pashudhan_qr/screens/reports/livestock_full_report_screen.dart';
import 'package:pashudhan_qr/screens/reports/livestock_details_associate_view.dart';
import 'package:pashudhan_qr/screens/home/customer_home/livestock_farmer/routes/scan_muzzle_screen.dart';
import 'dart:io';

import 'livestock_customer_details_screen.dart';

class HomeLivestockAssociateViewModel extends BaseViewModel {
  final _logger = getLogger('HomeLivestockAssociateViewModel');
  final _pashudhanRepository = locator<PashudhanRepository>();
  final _userRepository = locator<UserRepository>();
  final _storage = locator<StorageService>();

  final searchController = TextEditingController();

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
      _userName = name ?? 'Associate';
    } catch (e) {
      _logger.w('Could not load username: $e');
      _userName = 'Associate';
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

  Future<void> scanMuzzle(BuildContext context) async {
    final file = await Navigator.push<File?>(
      context,
      MaterialPageRoute(builder: (_) => const ScanMuzzleScreen()),
    );

    if (file == null) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFEDC93A)),
      ),
    );

    try {
      final bytes = await file.readAsBytes();
      final response = await _pashudhanRepository.identifyMuzzle(bytes, 'muzzle.jpg');
      
      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (response.match != null && response.match!.pashudhan != null) {
        final pashudhan = response.match!.pashudhan!;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LivestockDetailsAssociateView(pashudhan: pashudhan),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No match found for this muzzle.'),
            backgroundColor: Color(0xFF452B14),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      
      String msg = 'Failed to identify muzzle.';
      if (e.toString().contains('404')) msg = 'No matching muzzle found';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFF452B14),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> searchCustomer(BuildContext context) async {
    final mobile = searchController.text.trim();
    if (mobile.length != 10 || int.tryParse(mobile) == null) {
      locator<DialogService>().showDialog(
        title: 'Invalid Number',
        description: 'Please enter a valid 10-digit mobile number.',
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFEDC93A)),
      ),
    );

    try {
      final pashudhanList = await _pashudhanRepository.getPashudhanList(userName: mobile);
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading indicator

      if (pashudhanList.isEmpty) {
        locator<DialogService>().showDialog(
          title: 'Not Found',
          description: 'No registered customer or livestock found for this number.',
        );
        return;
      }

      // Show matching customer popup dialog
      _showCustomerPopup(context, mobile, pashudhanList);

    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading indicator
      
      locator<DialogService>().showDialog(
        title: 'Error',
        description: 'Failed to search customer: ${e.toString()}',
      );
    }
  }

  void _showCustomerPopup(BuildContext context, String mobile, List<Pashudhan> pashudhans) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFA1BC2A), // primaryGreen
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF452B14), width: 3.5),
          ),
          title: const Text(
            'Matching Customer',
            style: TextStyle(
              color: Color(0xFF452B14),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LivestockCustomerDetailsScreen(mobileNumber: mobile, pashudhans: pashudhans),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDC93A), // primaryYellow
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF452B14), width: 3.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xFF452B14), size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Owner: $mobile',
                              style: const TextStyle(
                                color: Color(0xFF452B14),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Animals Registered: ${pashudhans.length}',
                              style: const TextStyle(
                                color: Color(0xFF452B14),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Color(0xFF452B14), size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF452B14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
