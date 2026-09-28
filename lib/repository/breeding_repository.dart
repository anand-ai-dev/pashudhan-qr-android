import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/models/breeding_model.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';

class BreedingRepository {
  final _api = locator<ApiClientService>();

  Future<List<BreedingReport>> getBreedingReports() async {
    final response = await _api.client.get('/v1/breeding-reports');
    if (response.statusCode == 200) {
      final rawData = response.data;
      final List data = (rawData is Map && rawData.containsKey('content')) ? rawData['content'] : rawData;
      return data.map((json) => BreedingReport.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load breeding reports: ${response.statusCode}');
    }
  }

  Future<BreedingReport> getBreedingById(String uuid) async {
    final response = await _api.client.get('/v1/breeding-reports/$uuid');
    if (response.statusCode == 200) {
      return BreedingReport.fromJson(response.data);
    } else {
      throw Exception('Failed to load breeding report: ${response.statusCode}');
    }
  }

  Future<BreedingReport> createBreedingReport(Map<String, dynamic> data) async {
    final response = await _api.client.post('/v1/breeding-reports', data: data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return BreedingReport.fromJson(response.data);
    } else {
      throw Exception('Failed to create breeding report: ${response.statusCode}');
    }
  }
}
