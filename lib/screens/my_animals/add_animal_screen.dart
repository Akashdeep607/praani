import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common/constants.dart';
import '../../data/boxes.dart';
import '../../models/my_animals/all_animal_model.dart';
import '../../models/my_animals/my_animal_model.dart';
import 'my_animal_service.dart';

class AddAnimalScreen extends StatefulWidget {
  final AllAnimalModel? animal;

  const AddAnimalScreen({super.key, this.animal});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final animalNameCtrl = TextEditingController();
  final breedCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final uniqueFeaturesCtrl = TextEditingController();
  final microchipCtrl = TextEditingController();
  final tattooCtrl = TextEditingController();
  final identificationCtrl = TextEditingController();
  // final bloodGroupCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final stateCtrl = TextEditingController();

  // String? animalType;
  String? gender;
  bool isDonor = false;

  Map<String, List<String>> animalBloodGroups = {};
  String? selectedAnimal;
  String? selectedBloodGroup;
  bool isLoading = true;
  File? _pickedImage;
  String _existingImageUrl = '';

  final ImagePicker _picker = ImagePicker();

  bool get isEdit => widget.animal != null;

  // ---------------- LIFECYCLE ----------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (isEdit) {
      _prefillForm(widget.animal!);
    }
    loadAnimalTypes();
    _recoverLostImage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed');
    }
  }

  Future<void> loadAnimalTypes() async {
    final data = await AnimalService().fetchAnimalBloodGroups();
    setState(() {
      animalBloodGroups = data;
      isLoading = false;
    });
  }
  // ---------------- PERMISSIONS ----------------

  Future<bool> _ensurePermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final camera = await Permission.camera.request();
      return camera.isGranted;
    } else {
      final photos = await Permission.photos.request();
      return photos.isGranted;
    }
  }

  // ---------------- IMAGE RECOVERY ----------------

  Future<void> _recoverLostImage() async {
    final response = await _picker.retrieveLostData();

    if (response.isEmpty) return;

    if (response.file != null && mounted) {
      setState(() {
        _pickedImage = File(response.file!.path);
      });
    }
  }

  // ---------------- IMAGE PICKING ----------------

  Future<void> _pickImage() async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final granted = await _ensurePermission(source);
    if (!granted) return;

    try {
      final picked = await _picker.pickImage(
          source: source,
          imageQuality: 70,
          // maxWidth: 1024,
          // maxHeight: 1024,
          preferredCameraDevice: CameraDevice.rear);

      if (picked != null && mounted) {
        setState(() {
          _pickedImage = File(picked.path);
        });
      }
    } catch (e, st) {
      print('Image pick failed: $e\n$st');
    }
  }

  // ---------------- PREFILL ----------------

  void _prefillForm(AllAnimalModel animal) {
    animalNameCtrl.text = animal.animalName;
    breedCtrl.text = animal.breed;
    dobCtrl.text = animal.dateOfBirth;
    colorCtrl.text = animal.color;
    uniqueFeaturesCtrl.text = animal.uniqueFeatures;
    microchipCtrl.text = animal.microchipNo;
    tattooCtrl.text = animal.tattooMark;
    identificationCtrl.text = animal.identificationMark;
    // bloodGroupCtrl.text = animal.bloodGroup;
    addressCtrl.text = animal.address;
    pincodeCtrl.text = animal.pincode;
    stateCtrl.text = animal.state;

    selectedAnimal = animal.animalType;
    gender = animal.gender;
    isDonor = animal.isDonor;
    _existingImageUrl = animal.photoUrl ?? '';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Animal' : 'Register New Animal'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Animal Image'),
              _imagePicker(),
              const SizedBox(height: 24),
              _sectionTitle('Animal Information'),
              _textField('Animal Name *', animalNameCtrl, required: true),

              /// Animal Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  hint: const Text('Animal Type*'),
                  value: selectedAnimal,
                  decoration: const InputDecoration(labelText: 'Animal Type*', border: OutlineInputBorder()),
                  items: animalBloodGroups.keys.map((animal) {
                    return DropdownMenuItem(
                      value: animal,
                      child: Text(animal),
                    );
                  }).toList(),
                  validator: (v) => v == null ? 'Required field' : null,
                  onChanged: (value) {
                    setState(() {
                      selectedAnimal = value;
                      selectedBloodGroup = null;
                    });
                  },
                ),
              ),

              /// Blood Group Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  hint: const Text('Blood Group*'),
                  value: selectedBloodGroup,
                  decoration: const InputDecoration(labelText: 'Blood Group*', border: OutlineInputBorder()),
                  items: selectedAnimal == null
                      ? []
                      : animalBloodGroups[selectedAnimal]!.map((group) {
                          return DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          );
                        }).toList(),
                  onChanged: selectedAnimal == null
                      ? null
                      : (value) {
                          setState(() {
                            selectedBloodGroup = value;
                          });
                        },
                ),
              ),
              _textField('Breed', breedCtrl),
              _dateField('Date of Birth', dobCtrl),
              _dropdown(
                label: 'Gender',
                value: gender,
                items: const ['male', 'female'],
                onChanged: (v) => setState(() => gender = v),
              ),
              _textField('Color', colorCtrl),
              _textArea('Unique Features', uniqueFeaturesCtrl),
              _textField('Microchip Number', microchipCtrl),
              _textField('Tattoo Mark', tattooCtrl),
              _textArea('Identification Mark', identificationCtrl),
              const SizedBox(height: 12),
              const Text('Is this animal a donor?'),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: isDonor,
                    onChanged: (v) => setState(() => isDonor = v!),
                  ),
                  const Text('Yes'),
                  Radio<bool>(
                    value: false,
                    groupValue: isDonor,
                    onChanged: (v) => setState(() => isDonor = v!),
                  ),
                  const Text('No'),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle('Location Information'),
              _textArea('Address', addressCtrl),
              _textField('Pincode *', pincodeCtrl, required: true),
              _textField('State', stateCtrl),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEdit ? 'Update Animal' : 'Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- SUBMIT ----------------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cookieToken = UserBox().userInfo?.cookie ?? '';
    try {
      _showLoading();

      var photoId = widget.animal?.photoId ?? 0;
      var photoUrl = _existingImageUrl;

      // 🔹 Upload image first (if selected)
      if (_pickedImage != null) {
        final uploadResult = await AnimalService().uploadAnimalImage(
          token: cookieToken,
          imageFile: _pickedImage!,
        );
        photoId = uploadResult.photoId;
        photoUrl = uploadResult.photoUrl;
      }

      final payload = MyAnimalModel(
        animalName: animalNameCtrl.text,
        animalType: selectedAnimal.toString(),
        breed: breedCtrl.text,
        dateOfBirth: dobCtrl.text,
        gender: gender ?? '',
        color: colorCtrl.text,
        uniqueFeatures: uniqueFeaturesCtrl.text,
        microchipNo: microchipCtrl.text,
        tattooMark: tattooCtrl.text,
        identificationMark: identificationCtrl.text,
        bloodGroup: selectedBloodGroup.toString(),
        isDonor: isDonor,
        address: addressCtrl.text,
        pincode: pincodeCtrl.text,
        state: stateCtrl.text,
        photoId: photoId,
        photoUrl: photoUrl,
      );

      final success = isEdit
          ? await AnimalService().updateAnimal(
              animalId: widget.animal!.id,
              animal: payload,
              token: cookieToken,
            )
          : await AnimalService().addAnimal(
              animal: payload,
              token: cookieToken,
            );

      if (mounted && success == true) {
        Navigator.pop(context); // loader
        Navigator.pop(context, true);
      }
    } catch (e) {
      Navigator.pop(context);
      printError(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // ---------------- IMAGE UI ----------------

  Widget _imagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            ClipOval(
              child: _pickedImage != null
                  ? Image.file(
                      _pickedImage!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : (_existingImageUrl.isNotEmpty
                      ? Image.network(
                          _existingImageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 120,
                          height: 120,
                          color: Colors.blue.shade100,
                          alignment: Alignment.center,
                          child: const Icon(Icons.pets, size: 40),
                        )),
            ),
            const Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue,
                child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _textField(String label, TextEditingController controller, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: required ? (v) => v == null || v.isEmpty ? 'Required field' : null : null,
      ),
    );
  }

  Widget _textArea(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _dateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: _pickDate,
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.capitalize()))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Required field' : null,
      ),
    );
  }
}
