class MyAnimalModel {
  // Animal information
  final String animalName;
  final String animalType;
  final String breed;
  final String dateOfBirth; // yyyy-MM-dd
  final String gender;
  final String color;
  final String uniqueFeatures;
  final String microchipNo;
  final String tattooMark;
  final String identificationMark;
  final String bloodGroup;
  final bool isDonor;

  // Location
  final String address;
  final String pincode;
  final String state;

  // Photo
  final int photoId;
  final String photoUrl;

  MyAnimalModel({
    required this.animalName,
    required this.animalType,
    required this.breed,
    required this.dateOfBirth,
    required this.gender,
    required this.color,
    required this.uniqueFeatures,
    required this.microchipNo,
    required this.tattooMark,
    required this.identificationMark,
    required this.bloodGroup,
    required this.isDonor,
    required this.address,
    required this.pincode,
    required this.state,
    required this.photoId,
    required this.photoUrl,
  });

  /// JSON → Model
  factory MyAnimalModel.fromJson(Map<String, dynamic> json) {
    return MyAnimalModel(
      animalName: json['animal_name'],
      animalType: json['animal_type'],
      breed: json['breed'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      color: json['color'],
      uniqueFeatures: json['unique_features'],
      microchipNo: json['microchip_no'],
      tattooMark: json['tattoo_mark'],
      identificationMark: json['identification_mark'] ?? '',
      bloodGroup: json['blood_group'],
      isDonor: json['is_donor'],
      address: json['address'],
      pincode: json['pincode'],
      state: json['state'],
      photoId: json['photo_id'],
      photoUrl: json['photo_url'],
    );
  }

  /// Model → JSON (for documentation / debugging)
  Map<String, dynamic> toJson() {
    return {
      'animal_name': animalName,
      'animal_type': animalType,
      'breed': breed,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'color': color,
      'unique_features': uniqueFeatures,
      'microchip_no': microchipNo,
      'tattoo_mark': tattooMark,
      'identification_mark': identificationMark,
      'blood_group': bloodGroup,
      'is_donor': isDonor,
      'address': address,
      'pincode': pincode,
      'state': state,
      'photo_id': photoId,
      'photo_url': photoUrl,
    };
  }
}
