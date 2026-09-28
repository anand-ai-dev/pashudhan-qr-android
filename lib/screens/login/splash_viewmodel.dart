import 'dart:convert';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:pashudhan_qr/repository/auth_repository.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:dio/dio.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SplashViewModel extends BaseViewModel {
  final _logger = getLogger('SplashViewModel');
  final _navigationService = locator<NavigationService>();
  final _storage = locator<StorageService>();

  bool _hasRouted = false;
  bool _hasNavigated = false;

  Future<void> init([bool skipDelay = false]) async {
    if (_hasRouted) return;
    _hasRouted = true;

    // Show splash for at least 2 seconds for branding
    if (!skipDelay) {
      await Future.delayed(const Duration(seconds: 2));
    }
    await _checkSession();
  }

  /// Routes an approved associate based on partnerType from the backend.
  String _routeByPartnerType(String? partnerType) {
    final type = partnerType?.toUpperCase() ?? "";

    if (type.contains("PET") ||
        type.contains("DOG") ||
        type.contains("DAIRY") ||
        type.contains("CLINIC")) {
      return Routes.homePetOwnerAssociate;
    } else {
      return Routes.homeLivestockAssociate;
    }
  }

  /// Decodes a JWT and returns the `role` claim (uppercase), or null if
  /// the token is malformed or the claim is absent.
  String? _extractRoleFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return payload['role']?.toString().toUpperCase();
    } catch (_) {
      return null;
    }
  }

  Future<void> _checkSession() async {
    if (_hasNavigated) return;

    try {
      final authToken = await _storage.getToken();
      final otpToken = await _storage.getOtpToken();

      // ── Step 1: No auth_token at all ────────────────────────────────────
      if (authToken == null || authToken.isEmpty) {
        if (otpToken != null && otpToken.isNotEmpty) {
          // OTP verified but not yet registered → go to role selection
          _logger.i('No auth_token, otp_token present → roleSelectionView');
          _hasNavigated = true;
          _navigationService.clearStackAndShow(Routes.roleSelectionView);
        } else {
          // Completely unauthenticated → login
          _logger.i('No tokens found → loginView');
          _hasNavigated = true;
          _navigationService.clearStackAndShow(Routes.loginView);
        }
        return;
      }

      // ── Step 2: auth_token exists — guard against stale OTP tokens ──────
      // Before our AuthRepository fix, OTP_VERIFIED_USER tokens could be
      // accidentally saved under the auth_token key. Calling /v1/user/me
      // with such a token returns 400 "Invalid Role". We decode the JWT
      // and reject it before the API call if it carries an OTP role.
      final tokenRole = _extractRoleFromJwt(authToken);
      final isOtpRole = tokenRole == 'OTP_VERIFIED_USER' ||
                        tokenRole == 'ROLE_OTP_VERIFIED_USER';

      if (isOtpRole) {
        _logger.w(
          'auth_token carries OTP role ($tokenRole) — stale token detected. '
          'Deleting and treating as OTP credential.',
        );
        await _storage.deleteToken(); // remove the mis-stored token
        _hasNavigated = true;
        if (otpToken != null && otpToken.isNotEmpty) {
          _navigationService.clearStackAndShow(Routes.roleSelectionView);
        } else {
          // Save it as otp_token so downstream screens can use it
          await _storage.saveOtpToken(authToken);
          _navigationService.clearStackAndShow(Routes.roleSelectionView);
        }
        return;
      }

      // ── Step 3: Valid auth_token confirmed → call /v1/user/me ───────────
      _logger.i('auth_token present (role=$tokenRole) → calling /v1/user/me');
      final client = locator<ApiClientService>().client;
      final response = await client.get('/v1/user/me');

      final dynamic apiData = response.data['data'] ?? response.data;
      if (apiData == null) throw Exception("Invalid API response structure");

      // Robust Role Extraction
      String role = '';
      final dynamic roleRaw = apiData['role'];
      if (roleRaw is List && roleRaw.isNotEmpty) {
        role = roleRaw.first.toString().toUpperCase().trim();
      } else {
        role = (roleRaw ?? '').toString().toUpperCase().trim();
      }

      // Remove any ROLE_ prefix if present (common in Spring Security)
      if (role.startsWith('ROLE_')) {
        role = role.replaceFirst('ROLE_', '');
      }

      final String? partnerType =
          apiData['partnerType']?.toString().toUpperCase().trim();
      final bool approved = apiData['approved'] ?? true;
      final String name =
          (apiData['fullName'] ?? apiData['name'] ?? apiData['userName'] ?? 'User').toString().trim();
      final String userName =
          (apiData['userName'] ?? '').toString().trim();

      // Persist for other screens to use without re-calling API
      await _storage.saveCustomData('user_role', role);
      await _storage.saveCustomData('user_name', name);
      await _storage.saveCustomData('user_phone', userName);
      if (partnerType != null) {
        await _storage.saveCustomData('partner_type', partnerType);
      }

      _logger.i(
        'Routing session: role=$role, partnerType=$partnerType, approved=$approved',
      );

      String targetRoute;

      // STRICT ROLE-BASED ROUTING
      if (role == 'ASSOCIATE') {
        if (!approved) {
          targetRoute = Routes.approvalPendingView;
        } else {
          targetRoute = _routeByPartnerType(partnerType);
        }
      } else if (role == 'ADMIN') {
        targetRoute = Routes.livestockFarmerHome;
      } else if (role == 'CUSTOMER') {
        targetRoute = Routes.livestockFarmerHome;
      } else {
        _logger.w('Unknown role: $role — Redirecting to login.');
        targetRoute = Routes.loginView;
      }

      if (!_hasNavigated) {
        _hasNavigated = true;
        _logger.i('NAVIGATING → role=$role, route=$targetRoute');
        _navigationService.clearStackAndShow(targetRoute);
      }
    } catch (e) {
      _logger.e('Session routing failed: $e');

      if (e is DioException && e.response?.statusCode == 401) {
        await locator<AuthRepository>().logout();
      }

      if (!_hasNavigated) {
        _hasNavigated = true;
        _navigationService.clearStackAndShow(Routes.loginView);
      }
    }
  }
}
