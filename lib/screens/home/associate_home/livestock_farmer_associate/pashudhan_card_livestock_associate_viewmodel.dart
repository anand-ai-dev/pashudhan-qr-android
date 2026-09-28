import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:pashudhan_qr/repository/dto/pashudhan_dtos.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PashudhanCardLivestockAssociateViewModel extends BaseViewModel {
  final _logger = getLogger('PashudhanCardLivestockAssociateViewModel');
  final _pashudhanRepository = locator<PashudhanRepository>();
  final _dialogService = locator<DialogService>();
  final _baseUrl = locator<ApiClientService>().baseUrl;

  // ── State ──────────────────────────────────────────────
  List<Pashudhan> _pashudhanList = [];
  List<Pashudhan> get pashudhanList => _pashudhanList;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Screenshot Controllers ───────────────────────────────
  final Map<String, ScreenshotController> _screenshotControllers = {};

  ScreenshotController getScreenshotController(String id) {
    if (!_screenshotControllers.containsKey(id)) {
      _screenshotControllers[id] = ScreenshotController();
    }
    return _screenshotControllers[id]!;
  }

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

  // ── Actions ────────────────────────────────────────────
  
  Future<void> deleteLivestock(String earTag) async {
    final confirm = await _dialogService.showConfirmationDialog(
      title: 'Delete Livestock',
      description: 'Are you sure you want to delete this livestock record? This action cannot be undone.',
      confirmationTitle: 'Delete',
      cancelTitle: 'Cancel',
    );

    if (confirm?.confirmed == true) {
      setBusy(true);
      try {
        await _pashudhanRepository.deletePashudhan(earTag);
        await refresh();
      } catch (e) {
        _logger.e('Delete failed: $e');
        _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to delete livestock. Please try again.',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  Future<void> editLivestock(Pashudhan pashudhan, BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final ownerUserNameController = TextEditingController();
    final nameController = TextEditingController(text: pashudhan.name);
    final categoryController = TextEditingController(text: pashudhan.category);
    final breedController = TextEditingController(text: pashudhan.breed);
    final lactationController = TextEditingController(text: pashudhan.lactationNumber.toString());
    final milkYieldController = TextEditingController(text: pashudhan.milkYield.toString());
    final weightController = TextEditingController(text: pashudhan.weight.toString());
    final heightController = TextEditingController(text: pashudhan.heightInCms.toString());
    final calvesController = TextEditingController(text: pashudhan.numCalves.toString());
    final ageController = TextEditingController(text: pashudhan.ageInMonths.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFA1BC2A), // matches primaryGreen
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF452B14), width: 2.5),
          ),
          title: const Text(
            'Edit Livestock Details',
            style: TextStyle(color: Color(0xFF452B14), fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(ownerUserNameController, 'Owner Mobile (Required)', isNumeric: true, validator: (v) {
                    if (v == null || v.trim().isEmpty || v.trim().length != 10) {
                      return 'Enter 10-digit mobile';
                    }
                    return null;
                  }),
                  _buildTextField(nameController, 'Livestock Name', validator: (v) => v!.isEmpty ? 'Required' : null),
                  _buildTextField(categoryController, 'Category (e.g. COW, BUFFALO)', validator: (v) => v!.isEmpty ? 'Required' : null),
                  _buildTextField(breedController, 'Breed', validator: (v) => v!.isEmpty ? 'Required' : null),
                  _buildTextField(lactationController, 'Lactation Number', isNumeric: true, validator: (v) => int.tryParse(v ?? '') == null ? 'Enter valid number' : null),
                  _buildTextField(milkYieldController, 'Milk Yield (liters)', isNumeric: true, validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid yield' : null),
                  _buildTextField(weightController, 'Weight (kg)', isNumeric: true, validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid weight' : null),
                  _buildTextField(heightController, 'Height (cm)', isNumeric: true, validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid height' : null),
                  _buildTextField(calvesController, 'Number of Calves', isNumeric: true, validator: (v) => int.tryParse(v ?? '') == null ? 'Enter valid number' : null),
                  _buildTextField(ageController, 'Age in Months', isNumeric: true, validator: (v) => int.tryParse(v ?? '') == null ? 'Enter valid age' : null),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF452B14), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF452B14),
                foregroundColor: const Color(0xFFEDC93A),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  setBusy(true);
                  try {
                    final updateRequest = UpdatePashudhanRequest(
                      category: categoryController.text.trim().toUpperCase(),
                      name: nameController.text.trim(),
                      breed: breedController.text.trim(),
                      lactationNumber: int.parse(lactationController.text.trim()),
                      milkYield: double.parse(milkYieldController.text.trim()),
                      weight: double.parse(weightController.text.trim()),
                      heightInCms: double.parse(heightController.text.trim()),
                      numCalves: int.parse(calvesController.text.trim()),
                      ageInMonths: int.parse(ageController.text.trim()),
                      ownerUserName: ownerUserNameController.text.trim(),
                    );
                    await _pashudhanRepository.updatePashudhan(pashudhan.earTagNumber, updateRequest);
                    await refresh();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Livestock details updated successfully!'),
                        backgroundColor: Color(0xFF452B14),
                      ),
                    );
                  } catch (e) {
                    _logger.e('Failed to update livestock: $e');
                    _dialogService.showDialog(
                      title: 'Error',
                      description: 'Failed to update livestock details. Owner may not be registered/verified, or data is invalid.',
                    );
                  } finally {
                    setBusy(false);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumeric = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF452B14), fontWeight: FontWeight.bold),
          filled: true,
          fillColor: const Color(0xFFEDC93A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF452B14), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF452B14), width: 2.5),
          ),
        ),
        validator: validator,
      ),
    );
  }

  String? getImageUrl(Pashudhan pashudhan) {
    if (pashudhan.visuals.isEmpty) return null;
    final visualId = pashudhan.visuals.first;
    return '$_baseUrl/v1/pashudhan/${pashudhan.uuid}/visuals/$visualId';
  }



  Future<void> downloadQr(String id, BuildContext context) async {
    await _captureAndProcess(id, false, context);
  }

  Future<void> shareQr(String id, BuildContext context) async {
    await _captureAndProcess(id, true, context);
  }

  Future<void> _captureAndProcess(String id, bool isShare, BuildContext context) async {
    final controller = getScreenshotController(id);
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

      final pashudhan = _pashudhanList.firstWhere(
        (p) => p.earTagNumber == id || p.uuid == id,
        orElse: () => throw Exception("Livestock not found"),
      );
      final filename = 'livestock_card_${pashudhan.earTagNumber.isNotEmpty ? pashudhan.earTagNumber : pashudhan.uuid}.png';
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(image);

      if (isShare) {
        await Share.shareXFiles([XFile(file.path)], text: 'PashuDhanQR Card for ${pashudhan.name}');
      } else {
        await Gal.putImage(file.path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card saved to gallery!'),
              backgroundColor: Color(0xFF452B14),
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
