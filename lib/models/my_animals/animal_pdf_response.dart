class AnimalPdfResponse {
  final String pdfUrl;
  final String aadharId;
  final String animalName;

  AnimalPdfResponse({
    required this.pdfUrl,
    required this.aadharId,
    required this.animalName,
  });

  factory AnimalPdfResponse.fromJson(Map<String, dynamic> json) {
    return AnimalPdfResponse(
      pdfUrl: json['pdf_url'],
      aadharId: json['aadhar_id'],
      animalName: json['animal_name'],
    );
  }
}
