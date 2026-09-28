import 'package:flutter/foundation.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/models/pet_model.dart';
import 'package:pashudhan_qr/repository/pet_repository.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:stacked/stacked.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PashudhanCardCustomerPetViewModel extends BaseViewModel {
  final _logger = getLogger('PashudhanCardCustomerPetViewModel');
  final _petRepository = locator<PetRepository>();
  final _baseUrl = locator<ApiClientService>().baseUrl;

  // ── State ──────────────────────────────────────────────
  List<Pet> _petList = [];
  List<Pet> get petList => _petList;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Init ───────────────────────────────────────────────
  Future<void> initialize() async {
    if (isBusy) return;
    setBusy(true);
    _errorMessage = null;
    try {
      _petList = await _petRepository.getPets();
      if (kDebugMode) _logger.i('Loaded ${_petList.length} Pet records');
    } catch (e) {
      if (kDebugMode) _logger.e('Error loading Pet list: $e');
      _errorMessage = 'Failed to load pets. Please try again.';
    }
    setBusy(false);
  }

  Future<void> refresh() => initialize();

  // ── Fetch single pet by petIdNumber (called after QR scan) ─────────────
  /// Fetches pet details using the scanned [petIdNumber].
  Future<Pet> fetchByPetId(String petIdNumber) async {
    final trimmed = petIdNumber.trim();
    if (trimmed.isEmpty) {
      throw Exception('Invalid QR code');
    }

    if (kDebugMode) _logger.i('Fetching pet by petIdNumber: $trimmed');

    try {
      final result = await _petRepository.getPet(trimmed);
      return result;
    } catch (e) {
      if (kDebugMode) _logger.e('fetchByPetId failed: $e');

      final msg = e.toString().toLowerCase();
      if (msg.contains('not found') || msg.contains('404')) {
        throw Exception('No record found for pet ID: $trimmed');
      }
      throw Exception('Failed to fetch pet details. Please try again.');
    }
  }

  // ── Helpers ────────────────────────────────────────────
  String? getImageUrl(Pet pet) {
    if (pet.visuals.isEmpty) return null;
    final visualId = pet.visuals.first;
    return '$_baseUrl/v1/pets/${pet.uuid}/visuals/$visualId';
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

      final pet = _petList[index];
      final filename = 'pet_card_${pet.petIdNumber.isNotEmpty ? pet.petIdNumber : pet.uuid}.png';
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(image);

      if (isShare) {
        await Share.shareXFiles([XFile(file.path)], text: 'PashuDhanQR Card for ${pet.name}');
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
