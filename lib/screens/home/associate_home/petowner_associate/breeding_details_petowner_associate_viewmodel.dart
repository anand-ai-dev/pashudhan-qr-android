import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/models/pet_model.dart';
import 'package:pashudhan_qr/repository/breeding_repository.dart';
import 'package:pashudhan_qr/repository/pet_repository.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:pashudhan_qr/widgets/qr_scanner_screen.dart';
import 'package:pashudhan_qr/screens/reports/pet_details_associate_view.dart';
import 'package:pashudhan_qr/screens/reports/pet_full_report_screen.dart';
import 'package:pashudhan_qr/repository/vaccination_repository.dart';

class BreedingDetailsPetOwnerAssociateViewModel extends BaseViewModel {
  final _repository = locator<BreedingRepository>();
  final _petRepository = locator<PetRepository>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _storage = locator<StorageService>();
  
  String inseminationType = "NATURAL";
  String bullBreed = "HF_CROSS";

  String? matingDate;
  String? whelpingDate;

  final pupsController = TextEditingController();
  final mobileController = TextEditingController();

  List<Pet> pets = [];
  Pet? selectedPet;
  bool isPetLocked = false;

  void initialize() {}

  void selectPet(Pet pet) {
    if (isPetLocked) return;
    selectedPet = pet;
    notifyListeners();
  }

  void lockPet() {
    print("Locking pet. Selected: $selectedPet");
    if (selectedPet == null) {
      _showError("Please select a pet");
      return;
    }
    isPetLocked = true;
    print("Locked: $isPetLocked");
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

  Future<void> selectMatingDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      matingDate = picked.toIso8601String();
      notifyListeners();
    }
  }

  Future<void> selectWhelpingDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      whelpingDate = picked.toIso8601String();
      notifyListeners();
    }
  }

  Future<void> submit() async {
    final pups = int.tryParse(pupsController.text.trim()) ?? 0;
    
    if (pups <= 0) {
      _showError("Number of pups must be greater than 0");
      return;
    }
    if (matingDate == null || whelpingDate == null) {
      _showError("Please select both dates");
      return;
    }
    if (selectedPet == null || !isPetLocked) {
      _showError("Select and confirm pet");
      return;
    }

    setBusy(true);
    try {
      final data = {
        "pashudhanUuid": selectedPet!.uuid,
        "inseminationType": inseminationType,
        "bullBreed": bullBreed,
        "strawNo": "N/A",
        "numberOfCalves": pups,
        "dateOfCalving": whelpingDate,
      };
      
      await _repository.createBreedingReport(data);

      _dialogService.showDialog(
        title: 'Success!',
        description: 'Breeding details and reminder added successfully',
      );

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
        _showError(e.message ?? "Failed to add breeding details.");
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
    pupsController.dispose();
    mobileController.dispose();
    super.dispose();
  }
}
