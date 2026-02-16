class DoctorWorkingHoursResponse {
  final bool success;
  final DoctorWorkingHoursData data;

  DoctorWorkingHoursResponse({
    required this.success,
    required this.data,
  });

  factory DoctorWorkingHoursResponse.fromJson(Map<String, dynamic> json) {
    return DoctorWorkingHoursResponse(
      success: json['success'] ?? false,
      data: DoctorWorkingHoursData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }

  DoctorWorkingHoursResponse copyWith({
    bool? success,
    DoctorWorkingHoursData? data,
  }) {
    return DoctorWorkingHoursResponse(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }
}

class DoctorWorkingHoursData {
  final int doctorId;
  final String doctorName;
  final WorkingHoursModel workingHours;

  DoctorWorkingHoursData({
    required this.doctorId,
    required this.doctorName,
    required this.workingHours,
  });

  factory DoctorWorkingHoursData.fromJson(Map<String, dynamic> json) {
    return DoctorWorkingHoursData(
      doctorId: json['doctorId'] ?? 0,
      doctorName: json['doctorName'] ?? '',
      workingHours: WorkingHoursModel.fromJson({'workingHours': json['workingHours']}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'workingHours': workingHours.workingHours.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  DoctorWorkingHoursData copyWith({
    int? doctorId,
    String? doctorName,
    WorkingHoursModel? workingHours,
  }) {
    return DoctorWorkingHoursData(
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      workingHours: workingHours ?? this.workingHours,
    );
  }
}

//USE THIS TO UPDATE WORKING HOURS
class WorkingHoursModel {
  final Map<String, DayWorkingHours> workingHours;

  WorkingHoursModel({
    required this.workingHours,
  });

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    final parsedWorkingHours = <String, DayWorkingHours>{};

    json['workingHours'].forEach((key, value) {
      parsedWorkingHours[key] = DayWorkingHours.fromJson(value as Map<String, dynamic>);
    });

    return WorkingHoursModel(
      workingHours: parsedWorkingHours,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['workingHours'] = workingHours.map((key, value) => MapEntry(key, value.toJson()));

    return data;
  }

  WorkingHoursModel copyWith({
    Map<String, DayWorkingHours>? workingHours,
  }) {
    return WorkingHoursModel(
      workingHours: workingHours ?? this.workingHours,
    );
  }
}

class DayWorkingHours {
  final bool enabled;
  final List<TimeSlot> slots;

  DayWorkingHours({
    required this.enabled,
    required this.slots,
  });

  factory DayWorkingHours.fromJson(Map<String, dynamic> json) {
    return DayWorkingHours(
      enabled: json['enabled'] ?? false,
      slots: (json['slots'] as List<dynamic>).map((e) => TimeSlot.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'slots': slots.map((e) => e.toJson()).toList(),
    };
  }

  DayWorkingHours copyWith({
    bool? enabled,
    List<TimeSlot>? slots,
  }) {
    return DayWorkingHours(
      enabled: enabled ?? this.enabled,
      slots: slots ?? this.slots,
    );
  }
}

class TimeSlot {
  final String start;
  final String end;

  TimeSlot({
    required this.start,
    required this.end,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }

  TimeSlot copyWith({
    String? start,
    String? end,
  }) {
    return TimeSlot(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}
