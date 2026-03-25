class HealthRecordsResponse {
  final bool success;
  final HealthRecordsData data;

  HealthRecordsResponse({
    required this.success,
    required this.data,
  });

  factory HealthRecordsResponse.fromJson(Map<String, dynamic> json) {
    return HealthRecordsResponse(
      success: json['success'],
      data: HealthRecordsData.fromJson(json['data']),
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

  factory HealthRecordsData.fromJson(Map<String, dynamic> json) {
    return HealthRecordsData(
      records: (json['records'] as List)
          .map((e) => HealthRecord.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
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
  final int? appointmentId;
  final String uploaderRole;
  final String uploaderName;
  final int? doctorId;
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
    this.appointmentId,
    required this.uploaderRole,
    required this.uploaderName,
    this.doctorId,
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

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      animalId: json['animalId'],
      animalName: json['animalName'] ?? '',
      aadharId: json['aadharId'] ?? '',
      appointmentId: json['appointmentId'],
      uploaderRole: json['uploaderRole'] ?? '',
      uploaderName: json['uploaderName'] ?? '',
      doctorId: json['doctorId'],
      doctorName: json['doctorName'] ?? '',
      category: json['category'] ?? '',
      categoryLabel: json['categoryLabel'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      isShared: json['isShared'] ?? false,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
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

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'],
      perPage: json['perPage'],
      total: json['total'],
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