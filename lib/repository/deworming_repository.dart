import 'package:dio/dio.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/models/deworming_model.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';

class DewormingRepository {
  final _logger = getLogger('DewormingRepository');
  final _client = locator<ApiClientService>().client;

  Never _handleError(dynamic e) {
    if (e is DioException) {
      if (e.error is Exception) {
        throw e.error!;
      }
    }
    throw e;
  }

  Future<List<Deworming>> getDewormings() async {
    try {
      final response = await _client.get('/v1/pet-deworming');
      final rawData = response.data;
      final List<dynamic> data = (rawData is Map && rawData.containsKey('content')) ? rawData['content'] : rawData;
      return data.map((json) => Deworming.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error fetching dewormings: $e');
      _handleError(e);
    }
  }

  Future<List<Deworming>> getDewormingsByPet(String petUuid) async {
    try {
      final response = await _client.get('/v1/pet-deworming/pet/$petUuid');
      final rawData = response.data;
      final List<dynamic> data = (rawData is Map && rawData.containsKey('content')) ? rawData['content'] : rawData;
      return data.map((json) => Deworming.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error fetching dewormings for pet $petUuid: $e');
      _handleError(e);
    }
  }

  Future<Deworming> createDeworming(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('/v1/pet-deworming', data: data);
      return Deworming.fromJson(response.data);
    } catch (e) {
      _logger.e('Error creating deworming: $e');
      _handleError(e);
    }
  }

  Future<void> uploadPhoto(
      String dewormingUuid, List<int> photoBytes, String filename, String photoType) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(photoBytes, filename: filename),
        'photoType': photoType,
      });

      await _client.post(
        '/v1/pet-deworming/$dewormingUuid/photos',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
    } catch (e) {
      _logger.e('Error uploading photo for deworming $dewormingUuid: $e');
      _handleError(e);
    }
  }
}
