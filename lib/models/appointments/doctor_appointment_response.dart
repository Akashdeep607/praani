class DoctorAppointmentResponse {
  final bool success;
  final List<DoctorAppointment> data;

  DoctorAppointmentResponse({
    required this.success,
    required this.data,
  });

  factory DoctorAppointmentResponse.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>? ?? []).map((e) => DoctorAppointment.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class DoctorAppointment {
  final int id;
  final String date;
  final String time;
  final String timeDisplay;
  final String status;
  final String notes;
  final Customer customer;
  final Pet pet;
  final Clinic clinic;

  DoctorAppointment({
    required this.id,
    required this.date,
    required this.time,
    required this.timeDisplay,
    required this.status,
    required this.notes,
    required this.customer,
    required this.pet,
    required this.clinic,
  });

  factory DoctorAppointment.fromJson(Map<String, dynamic> json) {
    return DoctorAppointment(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      timeDisplay: json['timeDisplay'] ?? '',
      status: json['status'] ?? '',
      notes: json['notes'] ?? '',
      customer: Customer.fromJson(json['customer'] ?? {}),
      pet: Pet.fromJson(json['pet'] ?? {}),
      clinic: Clinic.fromJson(json['clinic'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'timeDisplay': timeDisplay,
      'status': status,
      'notes': notes,
      'customer': customer.toJson(),
      'pet': pet.toJson(),
      'clinic': clinic.toJson(),
    };
  }
}

class Customer {
  final String name;
  final String email;

  Customer({
    required this.name,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
    };
  }
}

class Pet {
  final String name;
  final String type;
  final int id;

  Pet({
    required this.name,
    required this.type,
    required this.id,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'id': id,
    };
  }
}

class Clinic {
  final String name;

  Clinic({
    required this.name,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
