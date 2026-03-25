import 'package:flutter/material.dart';

import '../../data/boxes.dart';
import '../../models/appointments/doctor_appointment_response.dart';
import 'appointment_service.dart';
import 'working_hours_view.dart';

class DoctorAppointmentView extends StatefulWidget {
  const DoctorAppointmentView({super.key});

  @override
  State<DoctorAppointmentView> createState() => _DoctorAppointmentViewState();
}

class _DoctorAppointmentViewState extends State<DoctorAppointmentView> {
  late String cookieToken;
  late Future<List<DoctorAppointment>> doctorsAppointments;

  @override
  void initState() {
    super.initState();
    final user = UserBox().userInfo;
    cookieToken = user?.cookie ?? '';
    _loadAppointments();
  }

  void _loadAppointments() {
    doctorsAppointments = AppointmentService().getDoctorsAppointment(token: cookieToken);
  }

  Future<void> _updateStatus({
    required int appointmentId,
    required String status,
    required String successMessage,
  }) async {
    try {
      final success = await AppointmentService().updateAppointmentStatus(
        token: cookieToken,
        status: status,
        appointmentId: appointmentId,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
        setState(() => _loadAppointments());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkingHoursView(
                      token: cookieToken,
                    ),
                  ),
                );
              }
              // onPressed: () => setState(() => _loadAppointments()),
              ),
        ],
      ),
      body: FutureBuilder<List<DoctorAppointment>>(
        future: doctorsAppointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load appointments\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const Center(
              child: Text('No appointments found'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appt = appointments[index];
              final status = appt.status.toLowerCase();

              return DoctorsAppointmentCard(
                appointment: appt,
                onConfirm: status == 'pending'
                    ? () => _updateStatus(
                          appointmentId: appt.id,
                          status: 'confirmed',
                          successMessage: 'Appointment confirmed',
                        )
                    : null,
                onComplete: status == 'confirmed'
                    ? () => _updateStatus(
                          appointmentId: appt.id,
                          status: 'completed',
                          successMessage: 'Appointment completed',
                        )
                    : null,
                onCancel: status == 'pending'
                    ? () => _updateStatus(
                          appointmentId: appt.id,
                          status: 'cancelled',
                          successMessage: 'Appointment cancelled',
                        )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class DoctorsAppointmentCard extends StatelessWidget {
  final DoctorAppointment appointment;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const DoctorsAppointmentCard({
    super.key,
    required this.appointment,
    this.onConfirm,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final status = appointment.status.toLowerCase();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${appointment.pet.name} (${appointment.pet.type} - ${appointment.id})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _StatusChip(status: appointment.status),
              ],
            ),

            const SizedBox(height: 8),

            _InfoRow(
              icon: Icons.person,
              label: 'Customer',
              value: appointment.customer.name,
            ),
            _InfoRow(
              icon: Icons.email,
              label: 'Email',
              value: appointment.customer.email,
            ),
            _InfoRow(
              icon: Icons.local_hospital,
              label: 'Clinic',
              value: appointment.clinic.name,
            ),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: appointment.date,
            ),
            _InfoRow(
              icon: Icons.access_time,
              label: 'Time',
              value: appointment.timeDisplay,
            ),

            const Divider(height: 20),

            // Buttons
            Row(
              children: [
                // CONFIRM / COMPLETE / COMPLETED
                Expanded(
                  child: OutlinedButton(
                    onPressed: status == 'pending'
                        ? onConfirm
                        : status == 'confirmed'
                            ? onComplete
                            : null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: status == 'pending'
                            ? Colors.green
                            : status == 'confirmed'
                                ? Colors.blue
                                : Colors.grey,
                      ),
                      foregroundColor: status == 'pending'
                          ? Colors.green
                          : status == 'confirmed'
                              ? Colors.blue
                              : Colors.grey,
                    ),
                    child: Text(
                      status == 'pending'
                          ? 'Confirm'
                          : status == 'confirmed'
                              ? 'Complete'
                              : 'Completed',
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // CANCEL
                Expanded(
                  child: OutlinedButton(
                    onPressed: status == 'pending' ? onCancel : null,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      foregroundColor: Colors.redAccent,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
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
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
