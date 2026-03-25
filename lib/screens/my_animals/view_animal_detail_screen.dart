import 'package:flutter/material.dart';
import '../../models/my_animals/all_animal_model.dart';

class ViewAnimalDetailScreen extends StatelessWidget {
  final AllAnimalModel animal;

  const ViewAnimalDetailScreen({
    super.key,
    required this.animal,
  });

  String get _imageUrl {
    if (animal.photoUrl.isNotEmpty) {
      return animal.photoUrl;
    }
    if (animal.photoUrl.isNotEmpty) {
      return animal.photoUrl;
    }
    if (animal.photoUrl.isNotEmpty) {
      return animal.photoUrl;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animal.animalName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildHeader(context),
            animal.photoUrl.isNotEmpty ? _buildAnimalImage(width: 400, height: 200) : const SizedBox(),
            const SizedBox(height: 24),

            _section('Basic Information', [
              _info('Animal Name', animal.animalName),
              _info('Animal Type', animal.animalType),
              _info('Breed', animal.breed),
              _info('Gender', animal.gender),
              _info('Date of Birth', animal.dateOfBirth),
              _info('Color', animal.color),
            ]),
            _section('Identification', [
              _info('Aadhar ID', animal.aadharId),
              _info('Microchip No', animal.microchipNo ?? ''),
              _info('Tattoo Mark', _nullable(animal.tattooMark)),
              _info('Identification Mark', animal.identificationMark ?? ''),
              _info('Unique Features', animal.uniqueFeatures ?? ''),
            ]),
            _section('Health & Donor', [
              _info('Blood Group', animal.bloodGroup),
              _info('Is Donor', animal.isDonor ? 'Yes' : 'No'),
            ]),
            _section('Address', [
              _info('Address', animal.address),
              _info('Pincode', animal.pincode),
              // _info('State', animal.state),
              _info('State Code', animal.pincode),
            ]),
            _section('Status & Approval', [
              _info('Status', animal.status.toUpperCase()),
              // _info('Rejection Reason', _nullable(animal.rejectionReason)),
              // _info('Approved At', _nullable(animal.approvedAt)),
              // _info('Rejected At', _nullable(animal.rejectedAt)),
            ]),
            _section('System Info', [
              _info('Created At', animal.createdAt),
              _info('Updated At', animal.updatedAt),
              _info('QR Code', _nullable(animal.qrCode)),
              _info('PDF Path', _nullable(animal.pdfPath)),
            ]),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI Components
  // ---------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildAnimalImage(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.animalName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${animal.breed} • ${animal.gender}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          animal.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: animal.status == 'pending' ? Colors.orange : Colors.green,
                      ),
                      if (animal.isDonor)
                        const Chip(
                          label: Text(
                            'DONOR',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalImage({double? width, double? height}) {
    if (_imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.blue.shade100,
        child: Text(
          animal.animalName.isNotEmpty ? animal.animalName[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Image.network(
        _imageUrl,
        width: width ?? 80,
        height: height ?? 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.pets, size: 32),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: 80,
            height: 80,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _nullable(String? value) {
    if (value == null || value.isEmpty) return '-';
    return value;
  }
}
