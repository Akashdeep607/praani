class DoctorModelRes {
  final int id;
  final String name;
  final String qualification;
  final String specialization;
  final int experienceYears;
  final String phone;
  final String bio;
  final String photo;
  final int clinicId;
  final String clinicName;
  final double consultationFee;

  DoctorModelRes({
    required this.id,
    required this.name,
    required this.qualification,
    required this.specialization,
    required this.experienceYears,
    required this.phone,
    required this.bio,
    required this.photo,
    required this.clinicId,
    required this.clinicName,
    required this.consultationFee,
  });

  // JSON deserialization
  factory DoctorModelRes.fromJson(Map<String, dynamic> json) {
    return DoctorModelRes(
      id: json['id'],
      name: json['name'],
      qualification: json['qualification'],
      specialization: json['specialization'],
      experienceYears: json['experienceYears'],
      phone: json['phone'],
      bio: json['bio'],
      photo: json['photo'],
      clinicId: json['clinicId'],
      clinicName: json['clinicName'],
      consultationFee: (json['consultationFee'] as num).toDouble(),
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'qualification': qualification,
      'specialization': specialization,
      'experienceYears': experienceYears,
      'phone': phone,
      'bio': bio,
      'photo': photo,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'consultationFee': consultationFee,
    };
  }
}

// Optional: Wrapper for API response
class DoctorResponse {
  final bool success;
  final List<DoctorModelRes> data;

  DoctorResponse({required this.success, required this.data});

  factory DoctorResponse.fromJson(Map<String, dynamic> json) {
    return DoctorResponse(
      success: json['success'],
      data: (json['data'] as List).map((doctorJson) => DoctorModelRes.fromJson(doctorJson)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((doctor) => doctor.toJson()).toList(),
    };
  }
}
