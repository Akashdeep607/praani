import 'package:flutter/material.dart';

import '../../data/boxes.dart';
import '../../models/my_animals/all_animal_model.dart';
import '../index.dart';
import 'add_animal_screen.dart';
import 'my_animal_service.dart';
import 'view_animal_detail_screen.dart';

class MyAnimalsScreen extends StatefulWidget {
  const MyAnimalsScreen({super.key});

  @override
  State<MyAnimalsScreen> createState() => _MyAnimalsScreenState();
}

class _MyAnimalsScreenState extends State<MyAnimalsScreen> {
  late String cookieToken;
  late String ggToken;
  late Future<List<AllAnimalModel>> _animalsFuture;
  @override
  void initState() {
    super.initState();
    final user = UserBox().userInfo;
    cookieToken = user?.cookie ?? '';
    _loadAnimals();
  }

  void _loadAnimals() {
    _animalsFuture = AnimalService().getAllAnimals(token: cookieToken);
  }

  Future<void> _openAddEdit({AllAnimalModel? animal}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAnimalScreen(animal: animal),
      ),
    );

    if (result == true) {
      setState(_loadAnimals); // 🔥 refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: cookieToken.isEmpty
            ? const SizedBox()
            : FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () => _openAddEdit(),
                child: const Icon(Icons.add),
              ),
        appBar: AppBar(
          title: const Text('My Animals'),
        ),
        body: FutureBuilder<List<AllAnimalModel>>(
          future: _animalsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              if (cookieToken.isEmpty) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 5,
                  children: [
                    const Text('Please login to continue'),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text('Login')),
                  ],
                ));
              }
              return Center(
                child: Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final animals = snapshot.data ?? [];

            if (animals.isEmpty) {
              return const Center(child: Text('No animals found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: animals.length,
              itemBuilder: (context, index) {
                final animal = animals[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimalAvatar(
                          animalName: animal.animalName,
                          imageUrl: animal.photoUrl,
                          radius: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      animal.animalName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<_AnimalAction>(
                                    onSelected: (action) => _handleAction(action, animal),
                                    itemBuilder: (context) {
                                      final items = <PopupMenuEntry<_AnimalAction>>[
                                        const PopupMenuItem(
                                          value: _AnimalAction.view,
                                          child: Text('View'),
                                        ),
                                      ];

                                      // Show Edit only if status is NOT approved
                                      if (animal.status != 'approved') {
                                        items.add(
                                          const PopupMenuItem(
                                            value: _AnimalAction.edit,
                                            child: Text('Edit'),
                                          ),
                                        );
                                      }

                                      items.add(
                                        const PopupMenuItem(
                                          value: _AnimalAction.delete,
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      );

                                      return items;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${animal.breed} • ${animal.gender}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'DOB: ${animal.dateOfBirth}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: animal.status == 'pending'
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    label: Text(
                                      animal.status.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: animal.status == 'pending' ? Colors.orange : Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  if (animal.isDonor)
                                    const Chip(
                                      label: Text(
                                        'DONOR',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  if (animal.status == 'approved')
                                    TextButton(
                                        onPressed: () async {
                                          _showLoading();
                                          try {
                                            final file = await AnimalService().fetchAndDownloadAnimalPdf(
                                              animalId: animal.id,
                                              token: cookieToken,
                                            );
                                            await Future.delayed(const Duration(seconds: 2));
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Downloaded: ${file.path}')),
                                            );
                                          } catch (e) {
                                            Navigator.pop(context);
                                            print('ERROR - $e');
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Download failed')),
                                            );
                                          }
                                        },
                                        child: const Text('Download Adhaar'))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _handleAction(
    _AnimalAction action,
    AllAnimalModel animal,
  ) {
    switch (action) {
      case _AnimalAction.view:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewAnimalDetailScreen(animal: animal),
          ),
        );
        break;

      case _AnimalAction.edit:
        _openAddEdit(animal: animal);
        break;

      case _AnimalAction.delete:
        _confirmDelete(animal);
        break;
    }
  }

  void _confirmDelete(AllAnimalModel animal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Animal'),
        content: Text(
          'Are you sure you want to delete ${animal.animalName}?',
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
                await AnimalService().deleteAnimal(
                  jwtToken: cookieToken,
                  animalId: animal.id,
                );

                if (!mounted) return;

                // Close loading dialog
                Navigator.of(context, rootNavigator: true).pop();

                // Refresh list
                setState(_loadAnimals);
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
}

enum _AnimalAction { view, edit, delete }

class AnimalAvatar extends StatelessWidget {
  final String? imageUrl;
  final String animalName;
  final double radius;

  const AnimalAvatar({
    super.key,
    required this.animalName,
    this.imageUrl,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue.shade100,
        child: Text(
          animalName.isNotEmpty ? animalName[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: radius * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        imageUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: radius * 2,
            height: radius * 2,
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
        errorBuilder: (_, __, ___) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              animalName.isNotEmpty ? animalName[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
