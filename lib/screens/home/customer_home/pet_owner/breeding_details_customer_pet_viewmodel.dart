import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/models/breeding_model.dart';
import 'package:pashudhan_qr/repository/breeding_repository.dart';
import 'package:pashudhan_qr/repository/pet_repository.dart';
import 'package:pashudhan_qr/models/pet_model.dart';
import 'package:stacked/stacked.dart';

class BreedingDetailsCustomerPetViewModel extends BaseViewModel {
  final _repository = locator<BreedingRepository>();
  final _petRepository = locator<PetRepository>();
  
  List<BreedingReport> breedingReports = [];
  Map<String, Pet> petMap = {};
  String? errorMessage;

  void initialize() {
    fetchBreedingData();
  }

  Future<void> fetchBreedingData() async {
    setBusy(true);
    errorMessage = null;
    try {
      final allReports = await _repository.getBreedingReports();
      final pets = await _petRepository.getPets();
      final petUuids = pets.map((p) => p.uuid).toSet();
      breedingReports = allReports.where((r) => petUuids.contains(r.pashudhanUuid)).toList();
      
      petMap = {for (var p in pets) p.uuid: p};
    } catch (e) {
      errorMessage = e.toString().toLowerCase();
      if (errorMessage!.contains('404')) {
        errorMessage = 'No data found';
      } else if (errorMessage!.contains('401')) {
        errorMessage = 'Session expired. Please log in again.';
      } else if (errorMessage!.contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage = 'Check internet connection or try again later.';
      }
    } finally {
      setBusy(false);
    }
  }
}
