import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/models/vaccination_model.dart';
import 'package:pashudhan_qr/repository/vaccination_repository.dart';
import 'package:stacked/stacked.dart';

class VaccinationDetailViewModel extends BaseViewModel {
  final _repository = locator<VaccinationRepository>();
  
  Vaccination? vaccination;
  String? errorMessage;

  Future<void> initialize(String uuid) async {
    setBusy(true);
    errorMessage = null;
    try {
      vaccination = await _repository.getVaccinationById(uuid);
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
