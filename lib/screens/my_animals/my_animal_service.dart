import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:inspireui/utils/logs.dart';
import 'package:intl/intl.dart';
import '../../models/my_animals/all_animal_model.dart';
import '../../models/my_animals/animal_pdf_response.dart';
import '../../models/my_animals/animal_photo_upload_response.dart';
import '../../models/my_animals/animal_type_response.dart';
import '../../models/my_animals/my_animal_model.dart';

class AnimalService {
  static const String baseUrl = 'https://praanisakha.com/wp-json';

  Future<bool> addAnimal({
    required String token,
    required MyAnimalModel animal,
  }) async {
    final url = Uri.parse(
      '$baseUrl/praani-aadhar/v1/animals',
    );
    final payload = jsonEncode({
      'animal_name': animal.animalName,
      'animal_type': animal.animalType,
      'breed': animal.breed,
      'date_of_birth': animal.dateOfBirth,
      'gender': animal.gender,
      'color': animal.color,
      'identification_mark': animal.identificationMark,
      'unique_features': animal.uniqueFeatures,
      'microchip_no': animal.microchipNo,
      'tattoo_mark': animal.tattooMark,
      'is_donor': animal.isDonor,
      'address': animal.address,
      'pincode': animal.pincode,
      'blood_group': animal.bloodGroup,
      'photo_id': animal.photoId,
      'photo_url': animal.photoUrl,
    });
    final response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payload);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(
        'Failed to add animal: ${response.statusCode} ${response.request}',
      );
    }
  }

  Future<List<AllAnimalModel>> getAllAnimals({
    required String token,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/praani-aadhar/v1/animals?page=1&per_page=10',
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

      final animals = dataList.map((e) => AllAnimalModel.fromJson(e as Map<String, dynamic>)).toList();

      printLog('SUCCESS: Loaded ${animals.length} animals');

      return animals;
    } catch (e, stackTrace) {
      printLog('ERROR: getAllAnimals -> $e');
      print(stackTrace);
      rethrow;
    }
  }

  Future<Map<String, List<String>>> fetchAnimalBloodGroups() async {
    final response = await http.get(
      Uri.parse(
        'https://praanisakha.com/wp-json/praanisakha/v1/animal-types',
      ),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final animalResponse = AnimalTypeResponse.fromJson(decoded);

      var result = <String, List<String>>{};

      for (var animal in animalResponse.data) {
        result[animal.typeName] = animal.bloodGroups.map((e) => e.groupName).toList();
      }

      return result;
    } else {
      throw Exception('Failed to load animal types');
    }
  }

  Future<bool> updateAnimal({
    required int animalId,
    required MyAnimalModel animal,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/praani-aadhar/v1/animals/$animalId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(animal.toJson()),
    );

    return response.statusCode == 200;
  }

  Future<void> deleteAnimal({
    required String jwtToken,
    required int animalId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/praani-aadhar/v1/animals/$animalId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete animal');
    }
  }
Future<AnimalPhotoUploadResponse> uploadAnimalImage({
    required String token,
    required File imageFile,
  }) async {
    try {
    final uri = Uri.parse('$baseUrl/praani-aadhar/v1/upload-photo');

    // Generate random string
    String randomString(int length) {
      const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      final rand = Random();
      return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
    }

      // Generate filename
    final extension = imageFile.path.split('.').last;
    final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    final filename = 'Photo_${randomString(10)}_$timestamp.$extension';

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
            filename: filename,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

      // Status check
      //   if (response.statusCode != 200 || response.statusCode != 201) {
      //     throw HttpException(
      //       'Photo upload failed with status: ${response.statusCode}',
      //     );
      // }

    final decoded = jsonDecode(response.body);

      // Business logic validation
    if (decoded['success'] != true || decoded['attachment_id'] == null) {
        throw FormatException(
          decoded['message'] ?? 'Invalid response format',
        );
    }

    return AnimalPhotoUploadResponse.fromJson(decoded);

    } on SocketException catch (e) {
      // Network issue
      throw Exception('No Internet connection: ${e.message}');
    } on HttpException catch (e) {
      // Server returned error status
      throw Exception(e.message);
    } on FormatException catch (e) {
      // Invalid JSON / API contract issue
      throw Exception('Response parsing error: ${e.message}');
    } catch (e, stackTrace) {
      // Unknown error (log this in production)
      // ignore: avoid_print
      print('Upload Error: $e');
      // ignore: avoid_print
      print(stackTrace);

      throw Exception('Something went wrong while uploading photo');
    }
}

  Future<File> downloadPdfFromUrl({
    required String pdfUrl,
    required String fileName,
  }) async {
    final response = await http.get(Uri.parse(pdfUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF');
    }

    final downloadsDir = Directory('/storage/emulated/0/Download');
    final file = File('${downloadsDir.path}/$fileName.pdf');

    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<AnimalPdfResponse> fetchAnimalPdfMeta({
    required int animalId,
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/praani-aadhar/v1/animals/$animalId/download',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch PDF metadata');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AnimalPdfResponse.fromJson(data);
  }

  Future<File> fetchAndDownloadAnimalPdf({
    required int animalId,
    required String token,
  }) async {
    // Step 1: Get PDF metadata
    final meta = await fetchAnimalPdfMeta(
      animalId: animalId,
      token: token,
    );

    // Step 2: Download PDF using pdf_url
    return downloadPdfFromUrl(
      pdfUrl: meta.pdfUrl,
      fileName: meta.aadharId.replaceAll(' ', '_'),
    );
  }

  Future<String?> fetchStateName(String pincode) async {
    final url = Uri.parse('https://praanisakha.com/wp-json/praani-aadhar/v1/pincode/$pincode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract only state_name
        return data['state_name'];
      }
    } catch (e) {
      throw Exception('Failed to fetch state name : $e');
    }
    return null;
  }
}
