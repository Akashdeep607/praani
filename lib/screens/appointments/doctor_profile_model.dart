import '../../models/appointments/working_hours_model.dart';

class DoctorProfileResponse {
  final bool success;
  final DoctorProfileData data;

  DoctorProfileResponse({
    required this.success,
    required this.data,
  });

  factory DoctorProfileResponse.fromJson(Map<String, dynamic> json) {
    return DoctorProfileResponse(
      success: json['success'] ?? false,
      data: DoctorProfileData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }

  DoctorProfileResponse copyWith({
    bool? success,
    DoctorProfileData? data,
  }) {
    return DoctorProfileResponse(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }
}

class DoctorProfileData {
  final int id;
  final String name;
  final String qualification;
  final String specialization;
  final int experienceYears;
  final String licenseNumber;
  final String bio;
  final String photo;
  final int consultationFee;
  final bool isAvailable;
  final WorkingHoursModel workingHours;
  final ClinicModel clinic;

  DoctorProfileData({
    required this.id,
    required this.name,
    required this.qualification,
    required this.specialization,
    required this.experienceYears,
    required this.licenseNumber,
    required this.bio,
    required this.photo,
    required this.consultationFee,
    required this.isAvailable,
    required this.workingHours,
    required this.clinic,
  });

  factory DoctorProfileData.fromJson(Map<String, dynamic> json) {
    return DoctorProfileData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      qualification: json['qualification'] ?? '',
      specialization: json['specialization'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      licenseNumber: json['licenseNumber'] ?? '',
      bio: json['bio'] ?? '',
      photo: json['photo'] ?? '',
      consultationFee: json['consultationFee'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      workingHours: WorkingHoursModel.fromJson({
        'workingHours': json['workingHours'] ?? {},
      }),
      clinic: ClinicModel.fromJson(json['clinic'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'qualification': qualification,
      'specialization': specialization,
      'experienceYears': experienceYears,
      'licenseNumber': licenseNumber,
      'bio': bio,
      'photo': photo,
      'consultationFee': consultationFee,
      'isAvailable': isAvailable,
      'workingHours': workingHours.workingHours.map((key, value) => MapEntry(key, value.toJson())),
      'clinic': clinic.toJson(),
    };
  }

  DoctorProfileData copyWith({
    int? id,
    String? name,
    String? qualification,
    String? specialization,
    int? experienceYears,
    String? licenseNumber,
    String? bio,
    String? photo,
    int? consultationFee,
    bool? isAvailable,
    WorkingHoursModel? workingHours,
    ClinicModel? clinic,
  }) {
    return DoctorProfileData(
      id: id ?? this.id,
      name: name ?? this.name,
      qualification: qualification ?? this.qualification,
      specialization: specialization ?? this.specialization,
      experienceYears: experienceYears ?? this.experienceYears,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      bio: bio ?? this.bio,
      photo: photo ?? this.photo,
      consultationFee: consultationFee ?? this.consultationFee,
      isAvailable: isAvailable ?? this.isAvailable,
      workingHours: workingHours ?? this.workingHours,
      clinic: clinic ?? this.clinic,
    );
  }
}

class ClinicModel {
  final int id;
  final String name;
  final String address;
  final String city;
  final String phone;

  ClinicModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'phone': phone,
    };
  }

  ClinicModel copyWith({
    int? id,
    String? name,
    String? address,
    String? city,
    String? phone,
  }) {
    return ClinicModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
    );
  }
}
