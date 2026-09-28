import 'package:dio/dio.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'dart:convert';
import 'package:pashudhan_qr/models/associate.dart';
import 'package:pashudhan_qr/repository/dto/associate_dtos.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:pashudhan_qr/services/storage_service.dart';

class AssociateRepository {
  final _logger = getLogger('AssociateRepository');
  final _apiClient = locator<ApiClientService>().client;

  Never _handleError(dynamic e) {
    if (e is DioException) {
      if (e.error is Exception) {
         throw e.error!;
      }
    }
    throw e;
  }

  Future<Associate> createAssociate(CreateAssociateRequest request) async {
    try {
      // Create request map
      // NOTE: Adjusting keys if necessary. Previous implementation used 'partnerId'.
      // User showed response has 'associatePartnerId'.
      // I'll stick to 'partnerId' in request for now as previously implemented unless instructed.
      final response = await _apiClient.post(
        '/v1/associate',
        data: request.toMap(),
      );

      final headers = response.headers['jwt_header'];
      final newJwt = headers != null && headers.isNotEmpty ? headers.first : null;

      if (newJwt == null || newJwt.isEmpty) {
        // ⚠️ No new JWT returned — log but do NOT wipe session.
        // OTP token remains valid for this step; navigation is handled by the ViewModel.
        _logger.w('⚠️ No jwt_header in createAssociate response. Proceeding without token refresh.');
        return Associate.fromJson(response.data);
      }

      await locator<StorageService>().saveToken(newJwt);
      await locator<StorageService>().deleteOtpToken();

      try {
        final parts = newJwt.split('.');
        if (parts.length == 3) {
          final payloadStr = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final payload = jsonDecode(payloadStr);
          final role = payload['role']?.toString().toUpperCase();
          if (role != 'ADMIN' && role != 'ASSOCIATE' && role != 'CUSTOMER') {
            _logger.w('⚠️ Unexpected role in JWT: $role. Token saved but role may be invalid.');
          }
        } else {
          _logger.w('⚠️ JWT from createAssociate has unexpected format (${parts.length} parts).');
        }
      } catch (e) {
        _logger.w('⚠️ JWT decode error after associate creation: $e. Token still saved.');
      }

      return Associate.fromJson(response.data);
    } catch (e) {
      _logger.e('Error creating associate: $e');
      _handleError(e);
    }
  }

  Future<Associate> getAssociate(String userId) async {
    try {
      final response = await _apiClient.get('/v1/associate/$userId');
      return Associate.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching associate: $e');
      _handleError(e);
    }
  }

  Future<List<Associate>> getAllAssociates() async {
    try {
      final response = await _apiClient.get('/v1/associate');
      final data = response.data;
      if (data is Map && data.containsKey('content')) {
        return (data['content'] as List)
            .map((item) => Associate.fromJson(item))
            .toList();
      } else {
        return (data as List)
            .map((item) => Associate.fromJson(item))
            .toList();
      }
    } catch (e) {
      _logger.e('Error fetching all associates: $e');
      _handleError(e);
    }
  }

  Future<void> updateAssociate(int id, AssociateRequest request) async {
    try {
      await _apiClient.put(
        '/v1/associate/$id',
        data: request.toMap(),
      );
    } catch (e) {
      _logger.e('Error updating associate: $e');
      _handleError(e);
    }
  }

  Future<void> deleteAssociate(int userId) async {
    try {
      await _apiClient.delete('/v1/associate/$userId');
    } catch (e) {
      _logger.e('Error deleting associate: $e');
      _handleError(e);
    }
  }

  Future<List<RequestAssociateViewDto>> getAssociateRequests(
      {String? status}) async {
    try {
      final response = await _apiClient.get(
        '/v1/associate/requests',
        queryParameters: status != null ? {'status': status} : null,
      );
      return (response.data as List)
          .map((item) => RequestAssociateViewDto.fromMap(item))
          .toList();
    } catch (e) {
      _logger.e('Error fetching associate requests: $e');
      _handleError(e);
    }
  }
}
