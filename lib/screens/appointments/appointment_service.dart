import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inspireui/utils/logs.dart';

import '../../models/appointments/doctor_appointment_response.dart';
import '../../models/appointments/doctor_model.dart';
import '../../models/appointments/doctor_profile_model.dart' as dp;
import '../../models/appointments/pet_appointment_response.dart';
import '../../models/appointments/services_response_model.dart';
import '../../models/appointments/working_hours_model.dart';

class AppointmentService {
  static const String baseUrl = 'https://praanisakha.com/wp-json';

  Future<bool> createAppointment({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse('$baseUrl/praani-pet-care/v1/appointments');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      printLog('Create Appointment Failed: ${response.body}');
      return false;
    }
  }

  Future<List<PetAppointmentModel>> getAllAppointments({required String token}) async {
    final uri = Uri.parse(
      '$baseUrl/praani-pet-care/v1/appointments',
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

      // Your API returns: { success: true, data: [...] }
      if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        final appointments = (decoded['data'] as List)
            .map<PetAppointmentModel>(
              (e) => PetAppointmentModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();

        printLog('SUCCESS: Loaded ${appointments.length} appointments');
        return appointments;
      }

      throw Exception('Unexpected response format for appointments');
    } else {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  //  Cancel Appointment
  Future<void> cancelAppointment({
    required String token,
    required int appointmentId,
    required String reason,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/praani-pet-care/v1/appointments/$appointmentId/cancel',
    );

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to cancel appointment: ${response.statusCode}',
      );
    }
  }

  // Reschedule Appointment
  Future<void> rescheduleAppointment({
    required String token,
    required int appointmentId,
    required String newDate, // yyyy-MM-dd
    required String newTime, // HH:mm
  }) async {
    final uri = Uri.parse(
      '$baseUrl/praani-pet-care/v1/appointments/$appointmentId/reschedule',
    );

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'appointmentDate': newDate,
        'appointmentTime': newTime,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to reschedule appointment: ${response.statusCode}',
      );
    }
  }

  Future<List<PetModel>> getMyPets({required String token}) async {
    final uri = Uri.parse(
      '$baseUrl/praani-pet-care/v1/pets',
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

      // Your API returns: { success: true, data: [...] }
      if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        final appointments = (decoded['data'] as List)
            .map<PetModel>(
              (e) => PetModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();

        printLog('SUCCESS: Loaded ${appointments.length} pets');
        return appointments;
      }

      throw Exception('Unexpected response format for pets');
    } else {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  Future<List<ClinicModel>> getAllClinics({required String token}) async {
    final uri = Uri.parse(
      '$baseUrl/praani-pet-care/v1/clinics',
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

      // API returns: { success: true, data: { clinics: [...] } }
      if (decoded is Map<String, dynamic> &&
          decoded['data'] is Map<String, dynamic> &&
          decoded['data']['clinics'] is List) {
        final clinics = (decoded['data']['clinics'] as List)
            .map<ClinicModel>(
              (e) => ClinicModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();

        printLog('SUCCESS: Loaded ${clinics.length} clinics');
        return clinics;
      }

      throw Exception('Unexpected response format for clinics');
    } else {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  Future<List<DoctorModelRes>> getAllDoctors({required String token}) async {
    final uri = Uri.parse(
      '$baseUrl/praani-pet-care/v1/doctors',
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
        final doctors = (decoded['data'] as List)
            .map<DoctorModelRes>(
              (e) => DoctorModelRes.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();

        printLog('SUCCESS: Loaded ${doctors.length} doctors');
        return doctors;
      }

      throw Exception('Unexpected response format for doctors');
    } else {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  Future<List<ServiceRes>> getAllServices({required String token}) async {
    final uri = Uri.parse(
      '$baseUrl/praani-pet-care/v1/services',
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

      // API returns: { success: true, data: { clinics: [...] } }
      if (decoded is Map<String, dynamic> &&
          decoded['data'] is Map<String, dynamic> &&
          decoded['data']['services'] is List) {
        final services = (decoded['data']['services'] as List)
            .map<ServiceRes>(
              (e) => ServiceRes.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();

        printLog('SUCCESS: Loaded ${services.length} services');
        return services;
      }

      throw Exception('Unexpected response format for services');
    } else {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  Future<List<DoctorAppointment>> getDoctorsAppointment({required String token}) async {
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

      // Your API returns: { success: true, data: [...] }
      if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        final appointments = (decoded['data'] as List)
            .map<DoctorAppointment>(
              (e) => DoctorAppointment.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();

        printLog('SUCCESS: Loaded doctors${appointments.length} appointments');
        return appointments;
      }

      throw Exception('Unexpected response format for appointments');
    } else {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  Future<bool> updateAppointmentStatus({
    required String token,
    required int appointmentId,
    required String status, // confirmed | cancelled
  }) async {
    final url = Uri.parse(
      '$baseUrl/praani-pet-care/v1/doctor/appointments/$appointmentId/status',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      } else {
        throw Exception(
          'Failed to update status: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DoctorWorkingHoursResponse?> fetchWorkingHours(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/praani-pet-care/v1/doctor/working-hours'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return DoctorWorkingHoursResponse.fromJson(decoded);
    } else {
      return null;
    }
  }

  Future<dp.DoctorProfileResponse?> fetchDoctorsProfile(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/praani-pet-care/v1/doctor/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return dp.DoctorProfileResponse.fromJson(decoded);
    } else {
      return null;
    }
  }

  Future<bool> updateDoctorsProfile(String token, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/praani-pet-care/v1/doctor/profile');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateWorkingHours(String token, Map<String, dynamic> workingHoursModel) async {
    final url = Uri.parse('$baseUrl/praani-pet-care/v1/doctor/working-hours');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(workingHoursModel),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
