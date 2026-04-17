class AnimalPdfResponse {
  final String pdfUrl;
  final String aadharId;
  final String pdfPath;
  final bool success;

  AnimalPdfResponse({
    required this.pdfUrl,
    required this.aadharId,
    required this.pdfPath,
    required this.success,
  });

  factory AnimalPdfResponse.fromJson(Map<String, dynamic> json) {
    return AnimalPdfResponse(
      pdfUrl: json['download_url'] ?? '',
      aadharId: json['aadhar_id'] ?? '',
      pdfPath: json['pdf_path'] ?? '',
      success: json['success'] ?? false,
    );
  }
}
