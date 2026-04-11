import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inspireui/utils/logs.dart';
import 'package:intl/intl.dart';

import '../../models/appointments/doctor_appointment_response.dart';
import '../../models/my_animals/all_animal_model.dart';
import 'health_record_response.dart';

class HealthRecordsService {
  static const String baseUrl = 'https://praanisakha.com/wp-json';
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
    int? appointmentId,
    required String title,
    required String recordCategory,
    required String description,
    String isShared = '1',
    bool isDoctor = false,
    required File healthRecordFile,
  }) async {

    /// Select API based on user type
    final uri = Uri.parse(
      isDoctor ? '$baseUrl/praani-pet-care/v1/doctor/health-records' : '$baseUrl/praani-pet-care/v1/health-records',
    );

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

      /// Only doctor can send share flag
      if (isDoctor) {
        request.fields['appointment_id'] = appointmentId.toString();
        request.fields['is_shared'] = isShared;
      }

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

  static Future<List<HealthRecord>> getDoctorsUploadedRecords({
    int page = 1,
    int perPage = 20,
    required String token,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/praani-pet-care/v1/doctor/health-records?page=$page&per_page=$perPage',
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
        throw Exception(
          'Failed to load health records. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching health records: $e');
    }
  }

  Future<List<DoctorAppointment>> getDoctorsCompletedAppointment({
    required String token,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/praani-pet-care/v1/doctor/appointments',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          final List appointmentsJson = decoded['data'];

          final appointments = appointmentsJson
              .map((e) => DoctorAppointment.fromJson(e as Map<String, dynamic>))
              .where((appointment) => appointment.status.toLowerCase() == 'completed')
              .toList();

          printLog(
            'SUCCESS: Loaded ${appointments.length} completed appointments',
          );

          return appointments;
        } else {
          throw Exception('Unexpected response format for appointments');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      printLog('ERROR fetching completed appointments: $e');
      rethrow;
    }
  }

  Future<List<DoctorAppointment>> getCompletedAppointmentsByDate({
    required String token,
    required String date,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/praani-pet-care/v1/doctor/appointments?date=$date',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          final List appointmentsJson = decoded['data'];

          final appointments = appointmentsJson
              .map((e) => DoctorAppointment.fromJson(e as Map<String, dynamic>))
              .where((appointment) => appointment.status.toLowerCase() == 'completed')
              .toList();

          printLog(
            'SUCCESS: Loaded ${appointments.length} completed appointments',
          );

          return appointments;
        } else {
          throw Exception('Unexpected response format for appointments');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      printLog('ERROR fetching completed appointments: $e');
      rethrow;
    }
  }
}
