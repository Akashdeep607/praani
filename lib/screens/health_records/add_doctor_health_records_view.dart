import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/boxes.dart';
import '../../models/appointments/doctor_appointment_response.dart';
import '../../models/my_animals/all_animal_model.dart';
import 'health_records_service.dart';

class AddDoctorHealthRecordsView extends StatefulWidget {
  const AddDoctorHealthRecordsView({super.key});

  @override
  State<AddDoctorHealthRecordsView> createState() => _AddDoctorHealthRecordsViewState();
}

class _AddDoctorHealthRecordsViewState extends State<AddDoctorHealthRecordsView> {
  bool isCustomer = false;
  late String cookieToken;
  List<AllAnimalModel> animals = [];
  AllAnimalModel? selectedAnimal;
TextEditingController petController = TextEditingController();

  List<DoctorAppointment> appointments = [];
  DoctorAppointment? selectedAppointment;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String recordCategory = 'lab_report';

  File? selectedFile;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final user = UserBox().userInfo;
    isCustomer = user?.role == 'customer';
    cookieToken = user?.cookie ?? '';

    loadCompletedAppointments();
  }

  Future<void> loadCompletedAppointments() async {
    final result = await HealthRecordsService().getDoctorsCompletedAppointment(token: cookieToken);

    setState(() {
      appointments = result;
      isLoading = false;
    });
  }


  /// File Picker
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> submitHealthRecord() async {
    if (selectedAppointment == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select animal')));
      return;
    }

    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload file')));
      return;
    }
    _showLoading();

    final success = await HealthRecordsService().submitHealthRecord(
      token: cookieToken,
        animalId: selectedAppointment!.pet.id,
        appointmentId: selectedAppointment?.id,
      title: titleController.text,
      recordCategory: recordCategory,
      description: descriptionController.text,
      healthRecordFile: selectedFile!,
        isDoctor: true
    );

    if (mounted && success == true) {
      Navigator.pop(context);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health Record Submitted')),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission Failed')),
      );
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Animal Dropdown
                    DropdownButtonFormField<DoctorAppointment>(
                      decoration: const InputDecoration(
                        labelText: 'Select Appointment',
                        border: OutlineInputBorder(),
                      ),
                      items: appointments.map((appointment) {
                        return DropdownMenuItem<DoctorAppointment>(
                          value: appointment,
                          child: Text(
                            'Appointment No. ${appointment.id} - ${formatDate(appointment.date)}',
                          ),
                        );
                      }).toList(),
                      value: selectedAppointment,
                      onChanged: (value) {
                        setState(() {
                          selectedAppointment = value;

                          if (value != null) {
                            petController.text = '${value.pet.name} (${value.pet.type})';
                          } else {
                            petController.clear();
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    /// Pet Field
                    TextFormField(
                      controller: petController,
                      enabled: false,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Pet',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Title
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Category
                    DropdownButtonFormField<String>(
                      value: recordCategory,
                      decoration: const InputDecoration(
                        labelText: 'Record Category',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'lab_report',
                          child: Text('Lab Report'),
                        ),
                        DropdownMenuItem(
                          value: 'prescription',
                          child: Text('Prescription'),
                        ),
                        DropdownMenuItem(
                          value: 'xray_imaging',
                          child: Text('X-Ray / Imaging'),
                        ),
                        DropdownMenuItem(
                          value: 'vaccination_certificate',
                          child: Text('Vaccination Certificate'),
                        ),
                        DropdownMenuItem(
                          value: 'surgery_report',
                          child: Text('Surgery Report'),
                        ),
                        DropdownMenuItem(
                          value: 'consultation_notes',
                          child: Text('Consultation Notes'),
                        ),
                        DropdownMenuItem(
                          value: 'general_record',
                          child: Text('General Record'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          recordCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    /// Description
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// File Picker
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: pickFile,
                          child: const Text('Upload File'),
                        ),
                        const SizedBox(width: 12),
                        if (selectedFile != null)
                          Expanded(
                            child: Text(
                              selectedFile!.path.split('/').last,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// Submit
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: submitHealthRecord,
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
