import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inspireui/utils/logs.dart';

import '../../models/my_animals/all_animal_model.dart';
import 'health_record_response.dart';

class HealthRecordsService {
  static const String baseUrl = 'https://agratix.com/psdemo/wp-json';
  Future<List<AllAnimalModel>> getApprovedAnimals({
    required String token,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/praani-aadhar/v1/animals',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch animals (${response.statusCode}) ${response.reasonPhrase}',
        );
      }

      final decoded = jsonDecode(response.body);

      List<dynamic> dataList;

      if (decoded is List) {
        dataList = decoded;
      } else if (decoded is Map && decoded['data'] != null) {
        dataList = decoded['data'];
      } else {
        throw Exception('Invalid API response format');
      }

      /// Convert JSON → Model
      final animals = dataList.map((e) => AllAnimalModel.fromJson(e as Map<String, dynamic>)).toList();

      /// Filter approved animals
      final approvedAnimals = animals.where((animal) => animal.status == 'approved').toList();

      printLog('SUCCESS: Loaded ${approvedAnimals.length} approved animals');

      return approvedAnimals;
    } catch (e, stackTrace) {
      printLog('ERROR: getApprovedAnimals -> $e');
      print(stackTrace);
      rethrow;
    }
  }

  Future<bool> submitHealthRecord({
    required String token,
    required int animalId,
    required String title,
    required String recordCategory,
    required String description,
    required File healthRecordFile,
  }) async {
    final uri = Uri.parse('$baseUrl/praani-pet-care/v1/health-records');

    try {
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      /// Text Fields
      request.fields['animal_id'] = animalId.toString();
      request.fields['title'] = title;
      request.fields['record_category'] = recordCategory;
      request.fields['description'] = description;

      /// File Upload
      request.files.add(
        await http.MultipartFile.fromPath(
          'health_record_file',
          healthRecordFile.path,
        ),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        printLog('SUCCESS: Health record submitted');
        printLog(decoded.toString());

        return true;
      } else {
        printLog('FAILED: ${response.statusCode}');
        printLog(response.body);

        return false;
      }
    } catch (e) {
      printLog('ERROR submitHealthRecord: $e');
      return false;
    }
  }

  static Future<List<HealthRecord>> fetchHealthRecords({
    int page = 1,
    int perPage = 20,
    required int id,
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/praani-pet-care/v1/health-records?animal_id=$id&page=$page&per_page=$perPage',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final healthResponse = HealthRecordsResponse.fromJson(jsonData);
      return healthResponse.data.records;
    } else {
      throw Exception('Failed to load health records');
    }
  }

    Future<void> deleteHealthRecord({
    required String token,
    required int recordId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/praani-pet-care/v1/health-records/$recordId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete record');
    }
  }
}
