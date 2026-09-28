import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'dart:convert';
import 'package:pashudhan_qr/models/customer.dart';
import 'package:pashudhan_qr/repository/dto/user_dtos.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

class UserRepository {
  final _logger = getLogger('UserRepository');
  final _apiClient = locator<ApiClientService>();
  final _client = locator<ApiClientService>().client;

  Never _handleError(dynamic e) {
    if (e is DioException) {
      if (e.error is Exception) {
        throw e.error!;
      }
    }
    throw e;
  }

  Future<Uint8List?> getProfilePic() async {
    try {
      return await _apiClient.getProfileImage();
    } catch (e) {
      _logger.w('Profile pic fetch failed: $e');
      return null;
    }
  }

  Future<void> uploadProfilePic(ProfilePicUploadRequest request) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(request.filePath),
      });
      await _client.post(
        '/v1/user/profilePic',
        data: formData,
      );
    } catch (e) {
      _logger.e('Error uploading profile pic: $e');
      _handleError(e);
    }
  }

  Future<void> deleteProfilePic() async {
    try {
      await _client.delete('/v1/user/profilePic');
    } catch (e) {
      _logger.e('Error deleting profile pic: $e');
      _handleError(e);
    }
  }

  Future<void> refreshToken() async {
    try {
      await _client.get('/v1/user/refreshToken');
    } catch (e) {
      _logger.e('Error refreshing token: $e');
      _handleError(e);
    }
  }

  Future<CustomerRegistrationStatus> getCustomerRegistrationStatus(
      String userName) async {
    try {
      final response = await _client.get('/v1/users/customer-status/$userName');
      return CustomerRegistrationStatus.fromMap(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e) {
      _logger.e('Error checking customer registration status: $e');
      _handleError(e);
    }
  }

  Future<void> approveCustomer(int customerId, bool approved) async {
    try {
      await _client.put(
        '/v1/users/approve/$customerId',
        data: approved,
      );
    } catch (e) {
      _logger.e('Error approving customer $customerId: $e');
      _handleError(e);
    }
  }

  Future<Customer> createCustomer(
    CreateCustomerRequest request, {
    bool preserveExistingSession = false,
  }) async {
    try {
      _logger.d('📤 createCustomer request body: ${request.toMap()}');
      final previousToken =
          preserveExistingSession ? await _apiClient.getToken() : null;
      final response = await _client.post(
        '/v1/users/createCustomer',
        data: request.toMap(),
      );

      final headers = response.headers['jwt_header'];
      final newJwt =
          headers != null && headers.isNotEmpty ? headers.first : null;

      if (newJwt == null || newJwt.isEmpty) {
        _logger.e('❌ Missing jwt_header after registration. Clearing session.');
        await locator<StorageService>().clearAll();
        StackedService.navigatorKey?.currentState
            ?.pushNamedAndRemoveUntil(Routes.loginView, (route) => false);
        throw Exception("Missing auth token after registration");
      }

      if (preserveExistingSession &&
          previousToken != null &&
          previousToken.isNotEmpty) {
        await locator<StorageService>().saveToken(previousToken);
      } else {
        await locator<StorageService>().saveToken(newJwt);
      }
      await locator<StorageService>().deleteOtpToken();

      try {
        final parts = newJwt.split('.');
        if (parts.length != 3) {
          throw Exception("Invalid JWT format: ${parts.length} parts found");
        }

        final payloadStr =
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        final payload = jsonDecode(payloadStr);
        final role = payload['role']?.toString().toUpperCase();

        if (role != 'ADMIN' && role != 'ASSOCIATE' && role != 'CUSTOMER') {
          _logger.e('❌ Invalid role in new JWT: $role. Clearing session.');
          await locator<StorageService>().clearAll();
          StackedService.navigatorKey?.currentState
              ?.pushNamedAndRemoveUntil(Routes.loginView, (route) => false);
          throw Exception("Invalid role in JWT: $role");
        }
      } catch (e) {
        _logger.e('❌ JWT Decoding/Validation failed: $e. Clearing session.');
        await locator<StorageService>().clearAll();
        StackedService.navigatorKey?.currentState
            ?.pushNamedAndRemoveUntil(Routes.loginView, (route) => false);
        throw Exception("Failed to decode and validate JWT: $e");
      }

      return Customer.fromJson(response.data);
    } catch (e) {
      _logger.e('Error creating customer: $e');
      _handleError(e);
    }
  }

  Future<Customer> getCurrentUser() async {
    try {
      final response = await _client.get('/v1/user/me');
      return Customer.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching current user: $e');
      _handleError(e);
    }
  }

  Future<void> deleteCurrentUser() async {
    try {
      await _client.delete('/v1/user/me');
    } catch (e) {
      _logger.e('Error deleting current user: $e');
      _handleError(e);
    }
  }

  Future<void> getUserMe() async {
    try {
      await _client.get('/v1/user/me');
    } catch (e) {
      _logger.e('Error getting /v1/user/me: $e');
      _handleError(e);
    }
  }
}
