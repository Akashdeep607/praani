import 'package:flutter/material.dart';

import '../../data/boxes.dart';
import '../../models/appointments/pet_appointment_response.dart';
import 'add_appointment_view.dart';
import 'appointment_service.dart';

class MyAppointmentsView extends StatefulWidget {
  const MyAppointmentsView({super.key});

  @override
  State<MyAppointmentsView> createState() => _MyAppointmentsViewState();
}

class _MyAppointmentsViewState extends State<MyAppointmentsView> {
  late String cookieToken;
  late Future<List<PetAppointmentModel>> myAppointments;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  @override
  void initState() {
    super.initState();
    final user = UserBox().userInfo;
    cookieToken = user?.cookie ?? '';
    _loadAppointments();
  }

  void _loadAppointments() {
    myAppointments = AppointmentService().getAllAppointments(token: cookieToken);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadAppointments();
    });
    await myAppointments;
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  String formatApiDate(DateTime date) {
    // yyyy-MM-dd
    return date.toIso8601String().split('T').first;
  }

  Future<void> _goToAppointmentScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAppointmentView(),
      ),
    );

    if (result == true) {
      setState(() {
        _loadAppointments();
      }); // 🔥 refresh list
    }
  }

  Future<void> _confirmAndCancel(PetAppointmentModel appt) async {
    String? reason;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to cancel the appointment for ${appt.pet.name} on ${appt.dateDisplay} at ${appt.timeDisplay}?',
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => reason = value,
                decoration: const InputDecoration(
                  labelText: 'Reason for cancellation',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (reason == null || reason!.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide a reason')),
        );
        return;
      }

      try {
        await AppointmentService().cancelAppointment(
          token: cookieToken,
          appointmentId: appt.id,
          reason: reason!.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment cancelled')),
        );

        await _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: $e')),
        );
      }
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showRescheduleDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        var tempDate = selectedDate;
        var tempTime = selectedTime;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Date & Time'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date Field
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText:
                          tempDate == null ? 'Select Date' : '${tempDate?.day}/${tempDate?.month}/${tempDate?.year}',
                      hintStyle: const TextStyle(color: Colors.black),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        initialDate: tempDate ?? DateTime.now(),
                      );

                      if (picked != null) {
                        setState(() => tempDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Time Field
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: tempTime == null ? 'Select Time' : tempTime?.format(context),
                      hintStyle: const TextStyle(color: Colors.black),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: tempTime ?? TimeOfDay.now(),
                      );

                      if (picked != null) {
                        setState(() => tempTime = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (tempDate != null && tempTime != null)
                      ? () async {
                          try {
                            _showLoading();
                            // Update local state
                            setState(() {
                              selectedDate = tempDate;
                              selectedTime = tempTime;
                            });

                            // Call the service to reschedule appointment
                            await AppointmentService().rescheduleAppointment(
                              token: cookieToken,
                              appointmentId: id,
                              newDate: formatApiDate(selectedDate!),
                              newTime: selectedTime!.format(context),
                            );

                            // Close the dialog
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Appointment rescheduled successfully'),
                              ),
                            );

                            // Refresh the UI
                            await _refresh();
                          } catch (e) {
                            // Show error message
                            Navigator.of(context).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to reschedule appointment: $e'),
                              ),
                            );
                          }
                        }
                      : null,
                  child: const Text('Reschedule'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: cookieToken.isEmpty
          ? const SizedBox()
          : FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () => _goToAppointmentScreen(),
              child: const Icon(Icons.add),
            ),
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      body: FutureBuilder<List<PetAppointmentModel>>(
        future: myAppointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const Center(
              child: Text('No appointments found'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appt = appointments[index];

                return AppointmentCard(
                  appointment: appt,
                  onTap: () {
                    // TODO: Navigate to details screen
                  },
                  onCancel: appt.canCancel
                      ? () {
                          _confirmAndCancel(appt);
                        }
                      : null,
                  onReschedule: appt.canReschedule
                      ? () {
                          _showRescheduleDialog(appt.id);
                        }
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final PetAppointmentModel appointment;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onCancel,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Pet + Status
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    child: Icon(Icons.pets),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appointment.pet.name.isNotEmpty ? appointment.pet.name : 'Unknown Pet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _StatusChip(status: appointment.status),
                ],
              ),

              const SizedBox(height: 12),

              // Date & Time
              _InfoRow(
                icon: Icons.calendar_today,
                text: '${appointment.dateDisplay} • ${appointment.timeDisplay}',
              ),

              // Clinic
              if (appointment.clinic.name.isNotEmpty)
                _InfoRow(
                  icon: Icons.local_hospital,
                  text: appointment.clinic.name,
                ),

              // Doctor
              if (appointment.doctor.name.isNotEmpty)
                _InfoRow(
                  icon: Icons.person,
                  text: 'Dr. ${appointment.doctor.name} (${appointment.doctor.specialization})',
                ),

              // Service
              if (appointment.service.name.isNotEmpty)
                _InfoRow(
                  icon: Icons.medical_services,
                  text: appointment.service.name,
                ),

              // Notes
              if (appointment.notes.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  appointment.notes,
                  style: theme.textTheme.bodySmall,
                ),
              ],

              const SizedBox(height: 10),

              // Footer: Fee + Actions
              Row(
                children: [
                  if (appointment.fee != null)
                    Text(
                      'Fee: ₹${appointment.fee}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const Spacer(),
                  if (appointment.canReschedule)
                    TextButton(
                      onPressed: onReschedule,
                      child: const Text('Reschedule'),
                    ),
                  if (appointment.canCancel)
                    TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Cancel'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
