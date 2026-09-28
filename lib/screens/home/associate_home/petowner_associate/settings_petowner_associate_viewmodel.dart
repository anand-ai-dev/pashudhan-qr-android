import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/repository/auth_repository.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/material.dart';
import 'package:pashudhan_qr/screens/profile/profile_view.dart';
import 'package:pashudhan_qr/screens/support/help_support_view.dart';

class SettingsPetOwnerAssociateViewModel extends BaseViewModel {
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

  // ── Init ───────────────────────────────────────────────
  Future<void> initialize() async {
    setBusy(true);
    try {
      _userName = await _storage.getCustomData('user_name') ?? 'Associate';
      _userPhone = await _storage.getCustomData('user_phone') ?? '';
      _userRole = await _storage.getCustomData('user_role') ?? 'PET_ASSOCIATE';
    } catch (e) {
      _userName = 'Associate';
      _userPhone = '';
      _userRole = '';
    }
    setBusy(false);
    notifyListeners();
  }

  // ── Stub actions ───────────────────────────────────────
  void updateProfile() {
    final ctx = StackedService.navigatorKey?.currentContext;
    if (ctx != null) {
      Navigator.of(ctx).push(
        MaterialPageRoute(builder: (_) => const ProfileView()),
      );
    }
  }

  void notifications() {}

  void helpAndSupport() {
    final ctx = StackedService.navigatorKey?.currentContext;
    if (ctx != null) {
      Navigator.of(ctx).push(
        MaterialPageRoute(builder: (_) => const HelpSupportView()),
      );
    }
  }

  // ── Logout ─────────────────────────────────────────────
  Future<void> logout() async {
    setBusy(true);
    try {
      await _authRepository.logout();
    } catch (_) {}
    await _storage.clearAll();
    _navigationService.clearStackAndShow(Routes.loginView);
  }
}
