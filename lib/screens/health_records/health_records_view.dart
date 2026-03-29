import 'package:flutter/material.dart';
import '../../data/boxes.dart';

import '../../models/entities/user.dart';
import '../../models/my_animals/all_animal_model.dart';
import 'add_health_records_view.dart';
import 'health_record_response.dart';
import 'health_records_service.dart';

class HealthRecordsView extends StatefulWidget {
  const HealthRecordsView({super.key});

  @override
  State<HealthRecordsView> createState() => _HealthRecordsViewState();
}

class _HealthRecordsViewState extends State<HealthRecordsView> {
  late String cookieToken;
  List<AllAnimalModel> animals = [];
  bool isLoading = true;
  List<HealthRecord> records = [];
  AllAnimalModel? selectedAnimal;
  late User user;
  @override
  void initState() {
    super.initState();

    user = UserBox().userInfo ?? User();
    cookieToken = user.cookie ?? '';
    loadAnimals();
  }

  Future<void> loadAnimals() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await HealthRecordsService().getApprovedAnimals(token: cookieToken);

      animals = result;

      if (animals.isNotEmpty) {
        selectedAnimal = animals.first;

        /// Fetch records for first animal
        await _fetchHealthRecords(selectedAnimal?.id ?? 0);
      } else {
        selectedAnimal = null;
        records = [];
      }
    } catch (e) {
      debugPrint('Load animals error: $e');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchHealthRecords(int id, {bool fromDropdown = false}) async {
    if (fromDropdown) {
      setState(() {
        isLoading = true;
      });
    }
    try {
      final data = await HealthRecordsService.fetchHealthRecords(
        id: id,
        token: cookieToken,
      );

      if (mounted) {
        setState(() {
          records = data;
        });
      }
      if (fromDropdown) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (fromDropdown) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint('Health records error: $e');
    }
  }

  Future<void> _goToAddHealthRecords() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddHealthRecordsView(),
      ),
    );

    if (result == true) {
      setState(() async {
        await _fetchHealthRecords(selectedAnimal?.id ?? 0);
      }); // refresh list
    }
  }

  Widget _buildRecordCard(HealthRecord record) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImageView(imageUrl: record.fileUrl),
              ),
            );
          },
          child: Row(
            children: [
              /// Image Preview
              Hero(
                tag: record.fileUrl,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    record.fileUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// Record Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        record.categoryLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    /// Description
                    Text(
                      record.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),

                    /// Uploader
                    Text(
                      'Uploaded by ${user.fullName == record.uploaderName ? "You" : record.uploaderName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 2),

                    /// Date
                    Text(
                      record.createdAt.split(' ').first,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              /// File Icon
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _confirmDelete(record);
                
                },
                color: Colors.red,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(HealthRecord record) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete record'),
        content: Text(
          'Are you sure you want to delete ${record.title}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close confirmation dialog
              Navigator.of(context).pop();

              // Show loading dialog (ROOT navigator)
              showDialog(
                context: context,
                barrierDismissible: false,
                useRootNavigator: true,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                await HealthRecordsService().deleteHealthRecord(
                  token: cookieToken,
                  recordId: record.id,
                );

                if (!mounted) return;

                // Close loading dialog
                Navigator.of(context, rootNavigator: true).pop();

                // Refresh list
               await _fetchHealthRecords(selectedAnimal?.id ?? 0);
              } catch (e) {
                if (!mounted) return;

                // Ensure loader is closed
                Navigator.of(context, rootNavigator: true).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: cookieToken.isEmpty
          ? const SizedBox()
          : FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: _goToAddHealthRecords,
              child: const Icon(Icons.add),
            ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : animals.isEmpty
              ? const Center(child: Text('No Health Records Found'))
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      /// Animal Dropdown
                      DropdownButtonFormField<AllAnimalModel>(
                        decoration: const InputDecoration(
                          labelText: 'Select Animal',
                          border: OutlineInputBorder(),
                        ),
                        items: animals.map((animal) {
                          return DropdownMenuItem(
                            value: animal,
                            child: Text(animal.animalName),
                          );
                        }).toList(),
                        value: animals.isNotEmpty ? selectedAnimal : null,
                        onChanged: (value) {
                          setState(() {
                            selectedAnimal = value;
                            _fetchHealthRecords(selectedAnimal?.id ?? 0, fromDropdown: true);
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      /// Health Records List
                      records.isEmpty
                          ? const Center(child: Text('No Health Records Found'))
                          : Expanded(
                              child: ListView.builder(
                                itemCount: records.length,
                                itemBuilder: (context, index) {
                                  final record = records[index];
                                  return _buildRecordCard(record);
                                },
                              ),
                            ),
                    ],
                  ),
                ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
