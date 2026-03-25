class AllAnimalModel {
  final int id;
  final String aadharId;
  final int customerId;
  final String animalName;
  final String animalType;
  final String breed;
  final String dateOfBirth;
  final String gender;
  final String color;
  final String? identificationMark;
  final String? uniqueFeatures;
  final String? microchipNo;
  final String? tattooMark;
  final bool isDonor;
  final String address;
  final String pincode;
  final String bloodGroup;
  final int photoId;
  final String photoUrl;
  final String status;
  final String qrCode;
  final String pdfPath;
  final String createdAt;
  final String updatedAt;

  AllAnimalModel({
    required this.id,
    required this.aadharId,
    required this.customerId,
    required this.animalName,
    required this.animalType,
    required this.breed,
    required this.dateOfBirth,
    required this.gender,
    required this.color,
    this.identificationMark,
    this.uniqueFeatures,
    this.microchipNo,
    this.tattooMark,
    required this.isDonor,
    required this.address,
    required this.pincode,
    required this.bloodGroup,
    required this.photoId,
    required this.photoUrl,
    required this.status,
    required this.qrCode,
    required this.pdfPath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AllAnimalModel.fromJson(Map<String, dynamic> json) {
    return AllAnimalModel(
      id: json['id'],
      aadharId: json['aadhar_id'],
      customerId: json['customer_id'],
      animalName: json['animal_name'],
      animalType: json['animal_type'],
      breed: json['breed'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      color: json['color'],
      identificationMark: json['identification_mark'],
      uniqueFeatures: json['unique_features'],
      microchipNo: json['microchip_no'],
      tattooMark: json['tattoo_mark'],
      isDonor: json['is_donor'],
      address: json['address'],
      pincode: json['pincode'],
      bloodGroup: json['blood_group'],
      photoId: json['photo_id'],
      photoUrl: json['photo_url'],
      status: json['status'],
      qrCode: json['qr_code'],
      pdfPath: json['pdf_path'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aadhar_id': aadharId,
      'customer_id': customerId,
      'animal_name': animalName,
      'animal_type': animalType,
      'breed': breed,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'color': color,
      'identification_mark': identificationMark,
      'unique_features': uniqueFeatures,
      'microchip_no': microchipNo,
      'tattoo_mark': tattooMark,
      'is_donor': isDonor,
      'address': address,
      'pincode': pincode,
      'blood_group': bloodGroup,
      'photo_id': photoId,
      'photo_url': photoUrl,
      'status': status,
      'qr_code': qrCode,
      'pdf_path': pdfPath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
