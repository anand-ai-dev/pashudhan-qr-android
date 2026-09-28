import 'package:dio/dio.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/repository/dto/otp_dtos.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:pashudhan_qr/services/storage_service.dart';

class AuthRepository {
  final _logger = getLogger('AuthRepository');
  final _apiClient = locator<ApiClientService>().client;
  final StorageService _storageService = locator<StorageService>();

  bool _isLoggingOut = false;

  Never _handleError(dynamic e) {
    if (e is DioException) {
      if (e.error is Exception) {
         throw e.error!; // Unwraps UnauthenticatedException/ServerException
      }
    }
    throw e;
  }

  Future<GenerateOtpResponse?> generateOtp(String userName) async {
    try {
      final response = await _apiClient.get('/v1/otp/$userName');
      return GenerateOtpResponse.fromMap(response.data);
    } catch (e) {
      _logger.e('Error generating OTP for $userName: $e');
      _handleError(e);
    }
  }

  Future<VerifyOtpParsedResponse> verifyOtp(VerifyOtpRequest request, {bool isSubUserFlow = false}) async {
    try {
      final response = await _apiClient.post(
        '/v1/otp/verify',
        data: request.toMap(),
      );

print("OTP VERIFY RAW RESPONSE:");
print(response.data);

print("JWT HEADER:");
print(response.headers.value('jwt_header'));

print("userId field:");
print(response.data['userId']);

print("role field:");
print(response.data['role']);

print("Full response runtime type:");
print(response.data.runtimeType);

      // ── Extract token from response headers ──────────────────────────────
      final token = response.headers.value('jwt_header');

      final userId = response.data is Map ? response.data['userId'] : null;
      final role = response.data is Map ? response.data['role'] : null;

      if (token == null || token.isEmpty) {
        _logger.e('❌ jwt_header missing from /v1/otp/verify response.');
        throw Exception('OTP token missing from server response. Please try again.');
      }

      // ── Token routing ───────────────────────────────────────────────────
      final parsedUserId = userId is int ? userId : int.tryParse(userId?.toString() ?? '');

      if (isSubUserFlow) {
        // We are registering/verifying a third-party user on their behalf.
        // Save ONLY as otp_token so we don't overwrite the active agent's session.
        await _storageService.saveOtpToken(token);
        _logger.i('✅ otp_token saved (sub-user flow). role=$role');
      } else if (parsedUserId == null) {
        // New / unregistered user — save ONLY as otp_token
        await _storageService.saveOtpToken(token);
        _logger.i('✅ otp_token saved (new user). role=$role');
      } else {
        // Returning user with an existing account — full auth token
        await _storageService.saveToken(token);
        _logger.i('✅ auth_token saved (returning user). userId=$parsedUserId, role=$role');
      }

      return VerifyOtpParsedResponse(
        jwtToken: token,
        userId: parsedUserId,
        role: role?.toString(),
      );
    } catch (e) {
      _logger.e('Error verifying OTP: $e');
      _handleError(e);
    }
  }

  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      await _apiClient.post('/v1/logout');
    } finally {
      await _storageService.clearAll();
      _isLoggingOut = false;
    }
  }
}
