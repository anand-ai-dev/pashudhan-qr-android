import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/models/deworming_model.dart';
import 'package:pashudhan_qr/repository/deworming_repository.dart';
import 'package:pashudhan_qr/repository/pet_repository.dart';
import 'package:pashudhan_qr/models/pet_model.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:pashudhan_qr/repository/user_repository.dart';

class DewormingDetailsCustomerPetViewModel extends BaseViewModel {
  final _repository = locator<DewormingRepository>();
  final _petRepository = locator<PetRepository>();
  final _apiClient = locator<ApiClientService>();
  final _userRepository = locator<UserRepository>();
  
  List<Deworming> dewormingRecords = [];
  Map<String, Pet> petMap = {};
  String? errorMessage;
  String ownerName = 'Unknown';

  String get baseUrl => _apiClient.baseUrl;
  String? get token => _apiClient.token;

  void initialize() {
    fetchDewormingData();
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

  Future<void> fetchDewormingData() async {
    setBusy(true);
    errorMessage = null;
    
    try {
      dewormingRecords = await _repository.getDewormings();
      
      final pets = await _petRepository.getPets();
      for (var pet in pets) {
        petMap[pet.uuid] = pet;
      }
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
      if (kDebugMode) debugPrint('Error fetching data: $e');
    } finally {
      setBusy(false);
    }
  }
}
