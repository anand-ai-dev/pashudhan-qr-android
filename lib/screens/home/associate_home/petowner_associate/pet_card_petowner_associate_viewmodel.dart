import 'package:flutter/foundation.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/models/pet_model.dart';
import 'package:pashudhan_qr/repository/pet_repository.dart';
import 'package:pashudhan_qr/repository/dto/pet_dtos.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PetCardPetOwnerAssociateViewModel extends BaseViewModel {
  final _logger = getLogger('PetCardPetOwnerAssociateViewModel');
  final _petRepository = locator<PetRepository>();
  final _dialogService = locator<DialogService>();
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

  // ── Actions ────────────────────────────────────────────
  
  Future<void> deletePet(String petIdNumber) async {
    final confirm = await _dialogService.showConfirmationDialog(
      title: 'Delete Pet',
      description: 'Are you sure you want to delete this pet record? This action cannot be undone.',
      confirmationTitle: 'Delete',
      cancelTitle: 'Cancel',
    );

    if (confirm?.confirmed == true) {
      setBusy(true);
      try {
        await _petRepository.deletePet(petIdNumber);
        await refresh();
      } catch (e) {
        _logger.e('Delete failed: $e');
        _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to delete pet. Please try again.',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  Future<void> editPet(Pet pet, BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final ownerUserNameController = TextEditingController();
    final nameController = TextEditingController(text: pet.name);
    final categoryController = TextEditingController(text: pet.category);
    final breedController = TextEditingController(text: pet.breed);
    final weightController = TextEditingController(text: pet.weight.toString());
    final heightController = TextEditingController(text: pet.heightInCms.toString());
    final offspringController = TextEditingController(text: '0');
    final ageController = TextEditingController(text: '12');

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
            'Edit Pet Details',
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
                  _buildTextField(nameController, 'Pet Name', validator: (v) => v!.isEmpty ? 'Required' : null),
                  _buildTextField(categoryController, 'Category (e.g. DOG, CAT)', validator: (v) => v!.isEmpty ? 'Required' : null),
                  _buildTextField(breedController, 'Breed', validator: (v) => v!.isEmpty ? 'Required' : null),
                  _buildTextField(weightController, 'Weight (kg)', isNumeric: true, validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid weight' : null),
                  _buildTextField(heightController, 'Height (cm)', isNumeric: true, validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid height' : null),
                  _buildTextField(offspringController, 'Number of Offspring', isNumeric: true, validator: (v) => int.tryParse(v ?? '') == null ? 'Enter valid number' : null),
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
                    final updateRequest = UpdatePetRequest(
                      ownerUserName: ownerUserNameController.text.trim(),
                      category: categoryController.text.trim().toUpperCase(),
                      name: nameController.text.trim(),
                      breed: breedController.text.trim(),
                      weight: double.parse(weightController.text.trim()),
                      heightInCms: double.parse(heightController.text.trim()),
                      numberOfOffspring: int.parse(offspringController.text.trim()),
                      petIdNumber: pet.petIdNumber,
                      ageMonthsAtRecord: int.parse(ageController.text.trim()),
                      ageRecordedAt: DateTime.now().toIso8601String(),
                    );
                    await _petRepository.updatePet(pet.petIdNumber, updateRequest);
                    await refresh();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pet details updated successfully!'),
                        backgroundColor: Color(0xFF452B14),
                      ),
                    );
                  } catch (e) {
                    _logger.e('Failed to update pet: $e');
                    _dialogService.showDialog(
                      title: 'Error',
                      description: 'Failed to update pet details. Owner may not be registered/verified, or data is invalid.',
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

  String? getImageUrl(Pet pet) {
    if (pet.visuals.isEmpty) return null;
    final visualId = pet.visuals.first;
    return '$_baseUrl/v1/pets/${pet.uuid}/visual/$visualId';
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
