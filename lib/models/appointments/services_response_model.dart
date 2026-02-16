// Service model
class ServiceRes {
  final int id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int duration; // in minutes
  final bool isGlobal;

  ServiceRes({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.duration,
    required this.isGlobal,
  });

  // JSON deserialization
  factory ServiceRes.fromJson(Map<String, dynamic> json) {
    return ServiceRes(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      duration: json['duration'],
      isGlobal: json['isGlobal'],
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'duration': duration,
      'isGlobal': isGlobal,
    };
  }
}

// Wrapper for services API response
class ServiceResponse {
  final bool success;
  final List<ServiceRes> services;

  ServiceResponse({required this.success, required this.services});

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      success: json['success'],
      services: (json['data']['services'] as List).map((serviceJson) => ServiceRes.fromJson(serviceJson)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        'services': services.map((service) => service.toJson()).toList(),
      },
    };
  }
}
