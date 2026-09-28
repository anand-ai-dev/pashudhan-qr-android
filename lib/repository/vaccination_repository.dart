import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/models/vaccination_model.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:dio/dio.dart';

class VaccinationRepository {
  final _api = locator<ApiClientService>();

  Future<List<Vaccination>> getVaccinations() async {
    final response = await _api.client.get('/v1/vaccinations');
    if (response.statusCode == 200) {
      final rawData = response.data;
      final List data = (rawData is Map && rawData.containsKey('content')) ? rawData['content'] : rawData;
      return data.map((json) => Vaccination.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vaccinations: ${response.statusCode}');
    }
  }

  Future<Vaccination> getVaccinationById(String uuid) async {
    final response = await _api.client.get('/v1/vaccinations/$uuid');
    if (response.statusCode == 200) {
      return Vaccination.fromJson(response.data);
    } else {
      throw Exception('Failed to load vaccination: ${response.statusCode}');
    }
  }

  Future<Vaccination> createVaccination(Map<String, dynamic> data) async {
    final response = await _api.client.post('/v1/vaccinations', data: data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Vaccination.fromJson(response.data);
    } else {
      throw Exception('Failed to create vaccination: ${response.statusCode}');
    }
  }

  Future<void> uploadPhoto(String uuid, List<int> fileBytes, String fileName, String photoType) async {
    try {
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
        'photoType': photoType,
      });

      await _api.client.post(
        '/v1/vaccinations/$uuid/photos',
        data: formData,
      );
    } catch (e) {
      throw Exception('Failed to upload $photoType photo: $e');
    }
  }
}
