class PetAppointmentResponse {
  final bool success;
  final List<PetAppointmentModel> data;

  PetAppointmentResponse({
    required this.success,
    required this.data,
  });

  factory PetAppointmentResponse.fromJson(Map<String, dynamic> json) {
    return PetAppointmentResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>? ?? []).map((e) => PetAppointmentModel.fromJson(e)).toList(),
    );
  }
}

class PetAppointmentModel {
  final int id;
  final String date;
  final String time;
  final String timeDisplay;
  final String dateDisplay;
  final String status;
  final String notes;
  final int? fee;

  final ClinicModel clinic;
  final DoctorModel doctor;
  final ServiceModel service;
  final PetModel pet;

  final bool canCancel;
  final bool canReschedule;

  PetAppointmentModel({
    required this.id,
    required this.date,
    required this.time,
    required this.timeDisplay,
    required this.dateDisplay,
    required this.status,
    required this.notes,
    required this.fee,
    required this.clinic,
    required this.doctor,
    required this.service,
    required this.pet,
    required this.canCancel,
    required this.canReschedule,
  });

  factory PetAppointmentModel.fromJson(Map<String, dynamic> json) {
    return PetAppointmentModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      timeDisplay: json['timeDisplay'] ?? '',
      dateDisplay: json['dateDisplay'] ?? '',
      status: json['status'] ?? '',
      notes: json['notes'] ?? '',
      fee: json['fee'],
      clinic: ClinicModel.fromJson(json['clinic'] ?? {}),
      doctor: DoctorModel.fromJson(json['doctor'] ?? {}),
      service: ServiceModel.fromJson(json['service'] ?? {}),
      pet: PetModel.fromJson(json['pet'] ?? {}),
      canCancel: json['canCancel'] ?? false,
      canReschedule: json['canReschedule'] ?? false,
    );
  }
}

class ClinicModel {
  final int id;
  final String name;
  final String phone;

  ClinicModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class DoctorModel {
  final int id;
  final String name;
  final String specialization;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
    );
  }
}

class ServiceModel {
  final int id;
  final String name;

  ServiceModel({
    required this.id,
    required this.name,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class PetModel {
  final int id;
  final String name;
  final String type;

  PetModel({
    required this.id,
    required this.name,
    required this.type,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
