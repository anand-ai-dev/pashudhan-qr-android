import 'package:flutter/foundation.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:stacked/stacked.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PashudhanCardLivestockViewModel extends BaseViewModel {
  final _logger = getLogger('PashudhanCardLivestockViewModel');
  final _pashudhanRepository = locator<PashudhanRepository>();
  final _baseUrl = locator<ApiClientService>().baseUrl;

  // ── State ──────────────────────────────────────────────
  List<Pashudhan> _pashudhanList = [];
  List<Pashudhan> get pashudhanList => _pashudhanList;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Init ───────────────────────────────────────────────
  Future<void> initialize() async {
    if (isBusy) return;
    setBusy(true);
    _errorMessage = null;
    try {
      _pashudhanList = await _pashudhanRepository.getPashudhanList();
      if (kDebugMode) _logger.i('Loaded ${_pashudhanList.length} Pashudhan records');
    } catch (e) {
      if (kDebugMode) _logger.e('Error loading Pashudhan list: $e');
      _errorMessage = 'Failed to load livestock. Please try again.';
    }
    setBusy(false);
  }

  Future<void> refresh() => initialize();

  // ── Fetch single animal by earTagId (called after QR scan) ─────────────
  /// Fetches livestock details using the scanned [earTagId].
  /// Returns the [Pashudhan] on success, or throws with a user-friendly message.
  Future<Pashudhan> fetchByEarTagId(String earTagId) async {
    final trimmed = earTagId.trim();
    if (trimmed.isEmpty) {
      throw Exception('Invalid QR code');
    }

    if (kDebugMode) _logger.i('Fetching pashudhan by earTagId: $trimmed');

    try {
      final result = await _pashudhanRepository.getPashudhan(trimmed);
      return result;
    } catch (e) {
      if (kDebugMode) _logger.e('fetchByEarTagId failed: $e');

      final msg = e.toString().toLowerCase();
      if (msg.contains('not found') || msg.contains('404')) {
        throw Exception('No record found for ear tag: $trimmed');
      }
      throw Exception('Failed to fetch livestock details. Please try again.');
    }
  }

  // ── Helpers ────────────────────────────────────────────
  String? getImageUrl(Pashudhan pashudhan) {
    if (pashudhan.visuals.isEmpty) return null;
    final visualId = pashudhan.visuals.first;
    return '$_baseUrl/v1/pashudhan/${pashudhan.uuid}/visuals/$visualId';
  }

  final Map<int, ScreenshotController> _screenshotControllers = {};

  ScreenshotController getScreenshotController(int index) {
    return _screenshotControllers.putIfAbsent(index, () => ScreenshotController());
  }

  Future<void> downloadQr(int index, BuildContext context) async {
    await _captureAndProcess(index, false, context);
  }

  Future<void> shareQr(int index, BuildContext context) async {
    await _captureAndProcess(index, true, context);
  }

  Future<void> _captureAndProcess(int index, bool isShare, BuildContext context) async {
    final controller = getScreenshotController(index);
    try {
      final image = await controller.capture(delay: const Duration(milliseconds: 50));
      if (image == null) throw Exception("Failed to capture QR Card");
      
      setBusy(true);

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      if (directory == null) throw Exception("Storage directory not accessible");

      final pashudhan = _pashudhanList[index];
      final filename = 'livestock_card_${pashudhan.earTagNumber.isNotEmpty ? pashudhan.earTagNumber : pashudhan.uuid}.png';
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(image);

      if (isShare) {
        await Share.shareXFiles([XFile(file.path)], text: 'PashuDhanQR Card for ${pashudhan.name}');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Card saved to: ${file.path}'),
              backgroundColor: const Color(0xFF452B14),
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('Error capturing card: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setBusy(false);
    }
  }

  void syncQr(int index) {
    if (isBusy) return;
    refresh();
  }
}
