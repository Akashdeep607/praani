class HealthRecordsResponse {
  final bool success;
  final HealthRecordsData data;

  HealthRecordsResponse({
    required this.success,
    required this.data,
  });

  factory HealthRecordsResponse.fromJson(Map<String, dynamic>? json) {
    return HealthRecordsResponse(
      success: json?['success'] as bool? ?? false,
      data: HealthRecordsData.fromJson(json?['data'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class HealthRecordsData {
  final List<HealthRecord> records;
  final Pagination pagination;

  HealthRecordsData({
    required this.records,
    required this.pagination,
  });

  factory HealthRecordsData.fromJson(Map<String, dynamic>? json) {
    final recordsList = json?['records'] as List? ?? [];

    return HealthRecordsData(
      records: recordsList.map((e) => HealthRecord.fromJson(e as Map<String, dynamic>?))
          .toList(),
      pagination: Pagination.fromJson(json?['pagination'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'records': records.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class HealthRecord {
  final int id;
  final int animalId;
  final String animalName;
  final String aadharId;
  final int appointmentId;
  final String uploaderRole;
  final String uploaderName;
  final int doctorId;
  final String doctorName;
  final String category;
  final String categoryLabel;
  final String title;
  final String description;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSize;
  final bool isShared;
  final String status;
  final String createdAt;
  final String updatedAt;

  HealthRecord({
    required this.id,
    required this.animalId,
    required this.animalName,
    required this.aadharId,
    required this.appointmentId,
    required this.uploaderRole,
    required this.uploaderName,
    required this.doctorId,
    required this.doctorName,
    required this.category,
    required this.categoryLabel,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.isShared,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic>? json) {
    return HealthRecord(
      id: json?['id'] as int? ?? 0,
      animalId: json?['animalId'] as int? ?? 0,
      animalName: json?['animalName'] as String? ?? '',
      aadharId: json?['aadharId'] as String? ?? '',
      appointmentId: json?['appointmentId'] as int? ?? 0,
      uploaderRole: json?['uploaderRole'] as String? ?? '',
      uploaderName: json?['uploaderName'] as String? ?? '',
      doctorId: json?['doctorId'] as int? ?? 0,
      doctorName: json?['doctorName'] as String? ?? '',
      category: json?['category'] as String? ?? '',
      categoryLabel: json?['categoryLabel'] as String? ?? '',
      title: json?['title'] as String? ?? '',
      description: json?['description'] as String? ?? '',
      fileUrl: json?['fileUrl'] as String? ?? '',
      fileName: json?['fileName'] as String? ?? '',
      fileType: json?['fileType'] as String? ?? '',
      fileSize: json?['fileSize'] as int? ?? 0,
      isShared: json?['isShared'] as bool? ?? false,
      status: json?['status'] as String? ?? '',
      createdAt: json?['createdAt'] as String? ?? '',
      updatedAt: json?['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animalId': animalId,
      'animalName': animalName,
      'aadharId': aadharId,
      'appointmentId': appointmentId,
      'uploaderRole': uploaderRole,
      'uploaderName': uploaderName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'category': category,
      'categoryLabel': categoryLabel,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'isShared': isShared,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Pagination {
  final int page;
  final int perPage;
  final int total;

  Pagination({
    required this.page,
    required this.perPage,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic>? json) {
    return Pagination(
      page: json?['page'] as int? ?? 1,
      perPage: json?['perPage'] as int? ?? 20,
      total: json?['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'perPage': perPage,
      'total': total,
    };
  }
}