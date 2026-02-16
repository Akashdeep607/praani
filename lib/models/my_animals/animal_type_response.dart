class AnimalTypeResponse {
  final bool success;
  final List<AnimalType> data;

  AnimalTypeResponse({
    required this.success,
    required this.data,
  });

  factory AnimalTypeResponse.fromJson(Map<String, dynamic> json) {
    return AnimalTypeResponse(
      success: json['success'],
      data: List<AnimalType>.from(
        json['data'].map((x) => AnimalType.fromJson(x)),
      ),
    );
  }
}

class AnimalType {
  final String typeName;
  final List<BloodGroup> bloodGroups;

  AnimalType({
    required this.typeName,
    required this.bloodGroups,
  });

  factory AnimalType.fromJson(Map<String, dynamic> json) {
    return AnimalType(
      typeName: json['type_name'],
      bloodGroups: List<BloodGroup>.from(
        json['blood_groups'].map((x) => BloodGroup.fromJson(x)),
      ),
    );
  }
}

class BloodGroup {
  final String groupName;

  BloodGroup({required this.groupName});

  factory BloodGroup.fromJson(Map<String, dynamic> json) {
    return BloodGroup(
      groupName: json['group_name'],
    );
  }
}
