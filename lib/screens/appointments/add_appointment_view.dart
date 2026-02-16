import 'package:flutter/material.dart';
import '../../data/boxes.dart';
import '../../models/appointments/doctor_model.dart';
import '../../models/appointments/pet_appointment_response.dart';
import '../../models/appointments/services_response_model.dart';
import 'appointment_service.dart';

class AddAppointmentView extends StatefulWidget {
  const AddAppointmentView({super.key});

  @override
  State<AddAppointmentView> createState() => _AddAppointmentViewState();
}

class _AddAppointmentViewState extends State<AddAppointmentView> {
  late String cookieToken;

  late Future<List<PetModel>> myPetsFuture;
  late Future<List<ClinicModel>> clinicsFuture;
  late Future<List<DoctorModelRes>> doctorsFuture;
  late Future<List<ServiceRes>> serviceFuture;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController notesCtrl = TextEditingController();
  PetModel? selectedPet;
  ClinicModel? selectedClinic;
  DoctorModelRes? selectedDoctor;
  ServiceRes? selectedService;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedDuration = '30 min';
  String? dateError;
  String? timeError;

  @override
  void initState() {
    super.initState();
    final user = UserBox().userInfo;
    cookieToken = user?.cookie ?? '';
    _loadPets();
    _loadClinics();
    _loadDoctors();
    _loadServices();
  }

  @override
  void dispose() {
    super.dispose();
    notesCtrl.dispose();
  }

  void _loadPets() {
    myPetsFuture = AppointmentService().getMyPets(token: cookieToken);
  }

  void _loadClinics() {
    clinicsFuture = AppointmentService().getAllClinics(token: cookieToken);
  }

  void _loadDoctors() {
    doctorsFuture = AppointmentService().getAllDoctors(token: cookieToken);
  }

  void _loadServices() {
    serviceFuture = AppointmentService().getAllServices(token: cookieToken);
  }

  String formatApiDate(DateTime date) {
    // yyyy-MM-dd
    return date.toIso8601String().split('T').first;
  }

  Future<void> _submit() async {
    _showLoading();
    setState(() {
      dateError = selectedDate == null ? 'Please select a date' : null;
      timeError = selectedTime == null ? 'Please select a time' : null;
    });

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid || dateError != null || timeError != null) {
      return;
    }

    final body = {
      'petId': selectedPet!.id,
      'clinicId': selectedClinic!.id,
      'serviceId': selectedService!.id,
      'doctorId': selectedDoctor?.id,
      'appointmentDate': formatApiDate(selectedDate!),
      'appointmentTime': selectedTime!.format(context),
      'notes': notesCtrl.text.trim(),
      'price': (selectedService?.price ?? 0).toDouble(),
    };

    debugPrint('POST BODY => $body');

    final success = await AppointmentService().createAppointment(
      token: cookieToken,
      body: body,
    );

    if (success && mounted) {
      Navigator.pop(context);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment created successfully')),
      );
    } else if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create appointment')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: FutureBuilder<List<PetModel>>(
            future: myPetsFuture,
            builder: (context, petSnapshot) {
              if (petSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (petSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading pets: ${petSnapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final pets = petSnapshot.data ?? [];

              if (pets.isEmpty) {
                return const Center(
                  child: Text('No pets found. Please add a pet first.'),
                );
              }

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- PET ----------
                    _label('Select Pet'),
                    DropdownButtonFormField<PetModel>(
                      value: selectedPet,
                      hint: const Text('--Select Pet--'),
                      isExpanded: true,
                      decoration: _inputDecoration(),
                      validator: (v) => v == null ? 'Please select a pet' : null,
                      items: pets.map((pet) {
                        return DropdownMenuItem<PetModel>(
                          value: pet,
                          child: Text('${pet.name} (${pet.type})'),
                        );
                      }).toList(),
                      onChanged: (pet) {
                        setState(() => selectedPet = pet);
                      },
                    ),

                    const SizedBox(height: 16),
                    Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      padding: const EdgeInsets.all(5),
                      width: double.infinity,
                      child: const Text(
                        'Appointment Details',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---------- CLINIC ----------
                    FutureBuilder<List<ClinicModel>>(
                      future: clinicsFuture,
                      builder: (context, clinicSnapshot) {
                        if (clinicSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (clinicSnapshot.hasError) {
                          return Text(
                            'Error loading clinics: ${clinicSnapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          );
                        }

                        final clinicList = clinicSnapshot.data ?? [];

                        if (clinicList.isEmpty) {
                          return const Text('No clinics available');
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Select Clinic'),
                            DropdownButtonFormField<ClinicModel>(
                              value: selectedClinic,
                              hint: const Text('--Select Clinic--'),
                              isExpanded: true,
                              decoration: _inputDecoration(),
                              validator: (v) => v == null ? 'Please select a clinic' : null,
                              items: clinicList.map((clinic) {
                                return DropdownMenuItem<ClinicModel>(
                                  value: clinic,
                                  child: Text(clinic.name),
                                );
                              }).toList(),
                              onChanged: (clinic) {
                                setState(() => selectedClinic = clinic);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---------- DOCTOR ----------
                    FutureBuilder<List<DoctorModelRes>>(
                      future: doctorsFuture,
                      builder: (context, clinicSnapshot) {
                        if (clinicSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (clinicSnapshot.hasError) {
                          return Text(
                            'Error loading doctors: ${clinicSnapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          );
                        }

                        final doctorList = clinicSnapshot.data ?? [];

                        if (doctorList.isEmpty) {
                          return const Text('No doctor available');
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Select Doctor'),
                            DropdownButtonFormField<DoctorModelRes>(
                              value: selectedDoctor,
                              hint: const Text('--Select Doctor--'),
                              isExpanded: true,
                              decoration: _inputDecoration(),
                              // validator: (v) => v == null ? 'Please select a doctor' : null,
                              items: [
                                // Add the default option first
                                const DropdownMenuItem<DoctorModelRes>(
                                  value: null, // Use null to represent "Any Available Doctor"
                                  child: Text(
                                    '--Any Available Doctor--',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                // Then add the actual doctors
                                ...doctorList.map((doctor) {
                                  return DropdownMenuItem<DoctorModelRes>(
                                    value: doctor,
                                    child: Text(doctor.name),
                                  );
                                }),
                              ],
                              onChanged: (doctor) {
                                setState(() => selectedDoctor = doctor);
                              },
                            )
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---------- SERVICES ----------
                    FutureBuilder<List<ServiceRes>>(
                      future: serviceFuture,
                      builder: (context, clinicSnapshot) {
                        if (clinicSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (clinicSnapshot.hasError) {
                          return Text(
                            'Error loading services: ${clinicSnapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          );
                        }

                        final serviceList = clinicSnapshot.data ?? [];

                        if (serviceList.isEmpty) {
                          return const Text('No service available');
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Select Service'),
                            DropdownButtonFormField<ServiceRes>(
                              value: selectedService,
                              hint: const Text('--Select Service--'),
                              isExpanded: true,
                              decoration: _inputDecoration(),
                              validator: (v) => v == null ? 'Please select a service' : null,
                              items: [
                                // Then add the actual doctors
                                ...serviceList.map((service) {
                                  return DropdownMenuItem<ServiceRes>(
                                    value: service,
                                    child: Text('${service.name} - ₹${service.price}'),
                                  );
                                }),
                              ],
                              onChanged: (service) {
                                setState(() => selectedService = service);
                              },
                            )
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Date *'),
                              _dateField(),
                              if (dateError != null) _errorText(dateError!),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Time *'),
                              _timeField(),
                              if (timeError != null) _errorText(timeError!),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _label('Duration (minutes)'),
                    DropdownButtonFormField<String>(
                      value: selectedDuration,
                      decoration: _inputDecoration(),
                      items: const [
                        DropdownMenuItem(value: '15 min', child: Text('15 min')),
                        DropdownMenuItem(value: '30 min', child: Text('30 min')),
                        DropdownMenuItem(value: '45 min', child: Text('45 min')),
                        DropdownMenuItem(value: '1 hr', child: Text('1 hr')),
                        DropdownMenuItem(value: '1.5 hr', child: Text('1.5 hr')),
                        DropdownMenuItem(value: '2 hr', child: Text('2 hr')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => selectedDuration = v);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    _label('Notes'),
                    TextFormField(
                      maxLines: 4,
                      controller: notesCtrl,
                      decoration: _inputDecoration(
                        hint: 'Notes about the appointment',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Create Appointment'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------- Helpers ----------

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _errorText(String text) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          text,
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(color: Colors.black),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  Widget _dateField() {
    return TextFormField(
      readOnly: true,
      decoration: _inputDecoration(
        hint:
            selectedDate == null ? 'Select Date' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          initialDate: selectedDate ?? DateTime.now(),
        );

        if (picked != null) {
          setState(() => selectedDate = picked);
        }
      },
    );
  }

  Widget _timeField() {
    return TextFormField(
      readOnly: true,
      decoration: _inputDecoration(
        hint: selectedTime == null ? 'Select Time' : selectedTime!.format(context),
        suffixIcon: const Icon(Icons.access_time),
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );

        if (picked != null) {
          setState(() {
            selectedTime = picked;
          });
        }
      },
    );
  }
}
