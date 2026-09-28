import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/repository/dto/admin_dtos.dart';
import 'package:pashudhan_qr/repository/dto/associate_dtos.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';

class AdminRepository {
  final _logger = getLogger('AdminRepository');
  final _apiClient = locator<ApiClientService>().client;

  Future<void> authorizeRole(AuthorizeRoleRequest request) async {
    try {
      await _apiClient.put(
        '/v1/admin/authorize',
        data: request.toMap(),
      );
    } catch (e) {
      _logger.e('Error authorizing role: $e');
      rethrow;
    }
  }

  Future<AssociatePartnerResponse> createAssociatePartner(AssociatePartnerRequest request) async {
    try {
      final response = await _apiClient.post(
        '/v1/admin/associate-partner',
        data: request.toMap(),
      );
      return AssociatePartnerResponse.fromMap(response.data);
    } catch (e) {
      _logger.e('Error creating associate partner from admin: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String username) async {
    try {
      await _apiClient.delete('/v1/admin/$username');
    } catch (e) {
      _logger.e('Error deleting user: $e');
      rethrow;
    }
  }
}
