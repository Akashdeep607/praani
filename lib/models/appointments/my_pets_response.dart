class MyPetsResponse {
  final bool success;
  final List<PetModel> data;

  MyPetsResponse({
    required this.success,
    required this.data,
  });

  factory MyPetsResponse.fromJson(Map<String, dynamic> json) {
    return MyPetsResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>? ?? []).map((e) => PetModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class PetModel {
  final int id;
  final String name;
  final String type;
  final String breed;
  final String gender;
  final String dateOfBirth;
  final String color;
  final String bloodGroup;
  final String photo;
  final String aadharId;
  final String aadharStatus;
  final bool hasAadhar;

  PetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.gender,
    required this.dateOfBirth,
    required this.color,
    required this.bloodGroup,
    required this.photo,
    required this.aadharId,
    required this.aadharStatus,
    required this.hasAadhar,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      breed: json['breed'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      color: json['color'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      photo: json['photo'] ?? '',
      aadharId: json['aadharId'] ?? '',
      aadharStatus: json['aadharStatus'] ?? '',
      hasAadhar: json['hasAadhar'] ?? false,
    );
  }
}
