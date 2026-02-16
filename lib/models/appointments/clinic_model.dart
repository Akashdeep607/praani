class ClinicModel {
  final int id;
  final String name;
  final String type;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final ClinicLocation location;
  final double rating;
  final String image;
  final bool isEmergency;
  final bool is24x7;
  final bool featured;
  final double? distance;
  final int doctorsCount;
  final int servicesCount;

  ClinicModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
    required this.location,
    required this.rating,
    required this.image,
    required this.isEmergency,
    required this.is24x7,
    required this.featured,
    required this.distance,
    required this.doctorsCount,
    required this.servicesCount,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      phone: json['phone'] ?? '',
      location: ClinicLocation.fromJson(json['location'] ?? {}),
      rating: (json['rating'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      isEmergency: json['isEmergency'] ?? false,
      is24x7: json['is24x7'] ?? false,
      featured: json['featured'] ?? false,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
      doctorsCount: json['doctorsCount'] ?? 0,
      servicesCount: json['servicesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'phone': phone,
      'location': location.toJson(),
      'rating': rating,
      'image': image,
      'isEmergency': isEmergency,
      'is24x7': is24x7,
      'featured': featured,
      'distance': distance,
      'doctorsCount': doctorsCount,
      'servicesCount': servicesCount,
    };
  }
}

class ClinicLocation {
  final double lat;
  final double lng;

  ClinicLocation({
    required this.lat,
    required this.lng,
  });

  factory ClinicLocation.fromJson(Map<String, dynamic> json) {
    return ClinicLocation(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}
