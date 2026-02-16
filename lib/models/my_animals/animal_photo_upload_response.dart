class AnimalPhotoUploadResponse {
  final int photoId;
  final String photoUrl;

  AnimalPhotoUploadResponse({
    required this.photoId,
    required this.photoUrl,
  });

  factory AnimalPhotoUploadResponse.fromJson(Map<String, dynamic> json) {
    return AnimalPhotoUploadResponse(
      photoId: json['attachment_id'],
      photoUrl: json['url'],
    );
  }
}
