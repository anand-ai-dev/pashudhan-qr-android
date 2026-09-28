import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/models/breeding_model.dart';
import 'package:pashudhan_qr/repository/breeding_repository.dart';
import 'package:stacked/stacked.dart';

class BreedingDetailViewModel extends BaseViewModel {
  final _repository = locator<BreedingRepository>();
  
  BreedingReport? breedingReport;
  String? errorMessage;

  Future<void> initialize(String uuid) async {
    setBusy(true);
    errorMessage = null;
    try {
      breedingReport = await _repository.getBreedingById(uuid);
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
