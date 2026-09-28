import 'package:dio/dio.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/repository/dto/associate_dtos.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';

class AssociatePartnerRepository {
  final _logger = getLogger('AssociatePartnerRepository');
  final _apiClient = locator<ApiClientService>().client;

  Never _handleError(dynamic e) {
    if (e is DioException) {
      if (e.error is Exception) {
         throw e.error!;
      }
    }
    throw e;
  }

  Future<List<AssociatePartnerResponse>> getAssociatePartners() async {
    try {
      final response = await _apiClient.get('/v1/associate-partner');
      // The backend API was recently updated to return a paginated response (PageResponse).
      // The actual list of partners is inside the 'content' field.
      final List dataList = response.data is List ? response.data : (response.data['content'] ?? []);
      return dataList
          .map((e) => AssociatePartnerResponse.fromMap(e))
          .toList();
    } catch (e) {
      _logger.e('Error fetching associate partners: $e');
      _handleError(e);
    }
  }

  Future<AssociatePartnerResponse> signUp(AssociatePartnerRequest request) async {
    try {
      final response = await _apiClient.post(
        '/v1/associate-partner/sign-up',
        data: request.toMap(),
      );
      return AssociatePartnerResponse.fromMap(response.data);
    } catch (e) {
      _logger.e('Error signing up associate partner: $e');
      _handleError(e);
    }
  }

  Future<AssociatePartnerResponse> getPartner(int id) async {
    try {
      final response = await _apiClient.get('/v1/associate-partner/$id');
      return AssociatePartnerResponse.fromMap(response.data);
    } catch (e) {
      _logger.e('Error fetching associate partner by id: $e');
      _handleError(e);
    }
  }

  Future<void> updateProfile(AssociatePartnerRequest request) async {
    try {
      await _apiClient.put(
        '/v1/associate-partner/profile',
        data: request.toMap(),
      );
    } catch (e) {
      _logger.e('Error updating associate partner profile: $e');
      _handleError(e);
    }
  }

  Future<void> deletePartner(int userId) async {
    try {
      await _apiClient.delete('/v1/associate-partner/$userId');
    } catch (e) {
      _logger.e('Error deleting partner: $e');
      _handleError(e);
    }
  }
}
