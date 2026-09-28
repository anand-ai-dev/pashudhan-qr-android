import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/models/vaccination_model.dart';
import 'package:pashudhan_qr/repository/vaccination_repository.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:stacked/stacked.dart';

class VaccinationCustomerViewModel extends BaseViewModel {
  final _repository = locator<VaccinationRepository>();
  final _pashudhanRepository = locator<PashudhanRepository>();
  final _apiClient = locator<ApiClientService>();
  
  List<Vaccination> vaccinations = [];
  Map<String, Pashudhan> pashudhanMap = {};
  String? errorMessage;

  String get baseUrl => _apiClient.baseUrl;
  String? get token => _apiClient.token;

  void initialize() {
    fetchVaccinationData();
  }

  Future<void> fetchVaccinationData() async {
    setBusy(true);
    errorMessage = null;
    try {
      final allVaccinations = await _repository.getVaccinations();
      vaccinations = allVaccinations.where((v) => v.animalType != 'PET').toList();
      
      final pashudhans = await _pashudhanRepository.getPashudhanList();
      pashudhanMap = {for (var p in pashudhans) p.uuid: p};
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
