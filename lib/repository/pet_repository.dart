import 'package:dio/dio.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/models/pet_model.dart';
import 'package:pashudhan_qr/repository/dto/pet_dtos.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';

class PetRepository {
  final _logger = getLogger('PetRepository');
  final _apiClient = locator<ApiClientService>().client;

  Future<List<Pet>> getPets({String? userName}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (userName != null) {
        queryParameters['userName'] = userName;
      }
      final response = await _apiClient.get(
        '/v1/pets',
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is Map && data.containsKey('content')) {
        return (data['content'] as List)
            .map((e) => Pet.fromMap(e))
            .toList();
      } else {
        return (data as List)
            .map((e) => Pet.fromMap(e))
            .toList();
      }
    } catch (e) {
      _logger.e('Error fetching Pets list: $e');
      rethrow;
    }
  }

  Future<Pet> createPet(CreatePetRequest request) async {
    try {
      final response = await _apiClient.post(
        '/v1/pets',
        data: request.toMap(),
      );
      return Pet.fromMap(response.data);
    } catch (e) {
      _logger.e('Error creating Pet: $e');
      rethrow;
    }
  }

  Future<Pet> getPet(String petIdNumber) async {
    try {
      final response = await _apiClient.get('/v1/pets/$petIdNumber');
      return Pet.fromMap(response.data);
    } catch (e) {
      _logger.e('Error fetching Pet $petIdNumber: $e');
      rethrow;
    }
  }

  Future<void> updatePet(
      String petIdNumber, UpdatePetRequest request) async {
    try {
      await _apiClient.put(
        '/v1/pets/$petIdNumber',
        data: request.toMap(),
      );
    } catch (e) {
      _logger.e('Error updating Pet $petIdNumber: $e');
      rethrow;
    }
  }

  Future<void> deletePet(String petIdNumber) async {
    try {
      await _apiClient.delete('/v1/pets/$petIdNumber');
    } catch (e) {
      _logger.e('Error deleting Pet $petIdNumber: $e');
      rethrow;
    }
  }

  Future<void> uploadVisual(String petUuid, List<int> fileBytes, String fileName) async {
    try {
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
        'fileType': 'IMAGE',
      });

      await _apiClient.post(
        '/v1/pets/$petUuid/visuals',
        data: formData,
      );
    } catch (e) {
      _logger.e('Error uploading visual for Pet $petUuid: $e');
      rethrow;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get('/v1/pets/categories');
      return (response.data as List).map((e) => e.toString()).toList();
    } catch (e) {
      _logger.e('Error fetching pet categories: $e');
      rethrow;
    }
  }

  Future<List<PetAggregationResponseDto>> getPetSummary() async {
    try {
      final response = await _apiClient.get('/v1/pets/summary');
      return (response.data as List)
          .map((e) => PetAggregationResponseDto.fromMap(e))
          .toList();
    } catch (e) {
      _logger.e('Error fetching Pet summary: $e');
      rethrow;
    }
  }
}
