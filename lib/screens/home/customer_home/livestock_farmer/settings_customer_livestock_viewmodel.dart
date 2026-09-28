import 'package:flutter/material.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/repository/auth_repository.dart';
import 'package:pashudhan_qr/screens/profile/profile_view.dart';
import 'package:pashudhan_qr/screens/support/help_support_view.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SettingsCustomerLivestockViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authRepository = locator<AuthRepository>();
  final _storage = locator<StorageService>();

  // ── Profile State ──────────────────────────────────────
  String _userName = '';
  String get userName => _userName;

  String _userPhone = '';
  String get userPhone => _userPhone;

  String _userRole = '';
  String get userRole => _userRole;

  // ── Mode Toggle ────────────────────────────────────────
  bool _isModeEnabled = false; // false = livestock farmer mode
  bool get isModeEnabled => _isModeEnabled;

  // ── Init ───────────────────────────────────────────────
  Future<void> initialize() async {
    setBusy(true);
    try {
      _userName = await _storage.getCustomData('user_name') ?? 'User';
      _userPhone = await _storage.getCustomData('user_phone') ?? '';
      _userRole = await _storage.getCustomData('user_role') ?? 'CUSTOMER';
    } catch (e) {
      _userName = 'User';
      _userPhone = '';
      _userRole = '';
    }
    setBusy(false);
    notifyListeners();
  }

  // ── Mode Toggle ────────────────────────────────────────
  void toggleMode(bool value) {
    _isModeEnabled = value;
    notifyListeners();
    if (value) {
      _navigationService.clearStackAndShow(Routes.homeCustomerPet);
    }
  }

  void onUpdateProfileTapped() {
    final ctx = StackedService.navigatorKey?.currentContext;
    if (ctx != null) {
      Navigator.of(ctx).push(
        MaterialPageRoute(builder: (_) => const ProfileView()),
      );
    }
  }

  void onNotificationsTapped() {}

  void onHelpAndSupportTapped() {
    final ctx = StackedService.navigatorKey?.currentContext;
    if (ctx != null) {
      Navigator.of(ctx).push(
        MaterialPageRoute(builder: (_) => const HelpSupportView()),
      );
    }
  }


  // ── Logout ─────────────────────────────────────────────
  Future<void> onLogoutTapped() async {
    setBusy(true);
    try {
      await _authRepository.logout(); // calls POST /v1/logout + clearAuth()
    } catch (_) {}
    await _storage.clearAll(); // wipe everything
    _navigationService.clearStackAndShow(Routes.loginView);
  }
}
