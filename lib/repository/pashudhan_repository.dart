import 'package:dio/dio.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/repository/dto/pashudhan_dtos.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';

class PashudhanRepository {
  final _logger = getLogger('PashudhanRepository');
  final _apiClient = locator<ApiClientService>().client;

  Future<List<Pashudhan>> getPashudhanList({String? userName}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (userName != null) {
        queryParameters['userName'] = userName;
      }
      final response = await _apiClient.get(
        '/v1/pashudhan',
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is Map && data.containsKey('content')) {
        return (data['content'] as List)
            .map((e) => Pashudhan.fromMap(e))
            .toList();
      } else {
        return (data as List)
            .map((e) => Pashudhan.fromMap(e))
            .toList();
      }
    } catch (e) {
      _logger.e('Error fetching Pashudhan list: $e');
      rethrow;
    }
  }

  Future<Pashudhan> createPashudhan(CreatePashudhanRequest request) async {
    try {
      final response = await _apiClient.post(
        '/v1/pashudhan',
        data: request.toMap(),
      );
      return Pashudhan.fromMap(response.data);
    } catch (e) {
      _logger.e('Error creating Pashudhan: $e');
      rethrow;
    }
  }

  Future<Pashudhan> getPashudhan(String earTag) async {
    try {
      final response = await _apiClient.get('/v1/pashudhan/$earTag');
      return Pashudhan.fromMap(response.data);
    } catch (e) {
      _logger.e('Error fetching Pashudhan $earTag: $e');
      rethrow;
    }
  }

  Future<Pashudhan> updatePashudhan(
      String earTag, UpdatePashudhanRequest request) async {
    try {
      final response = await _apiClient.put(
        '/v1/pashudhan/$earTag',
        data: request.toMap(),
      );
      return Pashudhan.fromMap(response.data);
    } catch (e) {
      _logger.e('Error updating Pashudhan $earTag: $e');
      rethrow;
    }
  }

  Future<void> deletePashudhan(String earTag) async {
    try {
      await _apiClient.delete('/v1/pashudhan/$earTag');
    } catch (e) {
      _logger.e('Error deleting Pashudhan $earTag: $e');
      rethrow;
    }
  }

  Future<void> uploadVisual(String pashudhanUuid, List<int> fileBytes, String fileName) async {
    try {
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
        'fileType': 'IMAGE',
      });

      await _apiClient.post(
        '/v1/pashudhan/$pashudhanUuid/visuals',
        data: formData,
      );
    } catch (e) {
      _logger.e('Error uploading visual for Pashudhan $pashudhanUuid: $e');
      rethrow;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get('/v1/pashudhan/categories');
      return (response.data as List).map((e) => e.toString()).toList();
    } catch (e) {
      _logger.e('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<List<PashudhanAggregationResponseDto>> getPashudhanSummary() async {
    try {
      final response = await _apiClient.get('/v1/pashudhan/summary');
      return (response.data as List)
          .map((e) => PashudhanAggregationResponseDto.fromMap(e))
          .toList();
    } catch (e) {
      _logger.e('Error fetching Pashudhan summary: $e');
      rethrow;
    }
  }

  Future<MuzzleRegisterResponse> registerMuzzle(String pashudhanUuid, List<int> fileBytes, String fileName) async {
    try {
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });

      final response = await _apiClient.post(
        '/v1/muzzle/register/$pashudhanUuid',
        data: formData,
      );
      return MuzzleRegisterResponse.fromMap(response.data);
    } catch (e) {
      _logger.e('Error registering muzzle for Pashudhan $pashudhanUuid: $e');
      rethrow;
    }
  }

  Future<MuzzleIdentifyResponse> identifyMuzzle(List<int> fileBytes, String fileName) async {
    try {
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });

      final response = await _apiClient.post(
        '/v1/muzzle/identify',
        data: formData,
      );
      return MuzzleIdentifyResponse.fromMap(response.data);
    } catch (e) {
      _logger.e('Error identifying muzzle: $e');
      rethrow;
    }
  }
}
