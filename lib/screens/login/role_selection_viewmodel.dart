import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/models/role.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class RoleSelectionViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  void onRoleSelected(UserRole role) {
    _navigationService.navigateToRegistrationView(
      type: role,
    );
  }
}