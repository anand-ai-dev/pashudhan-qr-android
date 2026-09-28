import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/models/vaccination_model.dart';
import 'package:pashudhan_qr/repository/vaccination_repository.dart';
import 'package:pashudhan_qr/repository/pet_repository.dart';
import 'package:pashudhan_qr/models/pet_model.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:pashudhan_qr/repository/user_repository.dart';
import 'package:stacked/stacked.dart';

class VaccinationDetailsCustomerPetViewModel extends BaseViewModel {
  final _repository = locator<VaccinationRepository>();
  final _petRepository = locator<PetRepository>();
  final _apiClient = locator<ApiClientService>();
  final _userRepository = locator<UserRepository>();
  
  List<Vaccination> vaccinations = [];
  Map<String, Pet> petMap = {};
  String? errorMessage;
  String ownerName = 'Unknown';

  String get baseUrl => _apiClient.baseUrl;
  String? get token => _apiClient.token;

  void initialize() {
    fetchVaccinationData();
    fetchOwnerName();
  }

  Future<void> fetchOwnerName() async {
    try {
      final user = await _userRepository.getCurrentUser();
      ownerName = user.name;
      notifyListeners();
    } catch (e) {
      // Ignored
    }
  }

  Future<void> fetchVaccinationData() async {
    setBusy(true);
    errorMessage = null;
    try {
      final allVaccinations = await _repository.getVaccinations();
      vaccinations = allVaccinations.where((v) => v.animalType == 'PET').toList();
      
      final pets = await _petRepository.getPets();
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
