import 'package:flutter/material.dart';

import '../../models/appointments/working_hours_model.dart';
import 'appointment_service.dart';

class WorkingHoursView extends StatefulWidget {
  final WorkingHoursModel? initialData;
  final String token;

  const WorkingHoursView({
    super.key,
    this.initialData,
    required this.token,
  });

  @override
  State<WorkingHoursView> createState() => _WorkingHoursViewState();
}

class _WorkingHoursViewState extends State<WorkingHoursView> {
  final List<String> days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  late WorkingHoursModel workingHoursModel;
  bool isLoading = false;
  bool isDataUpdated = false;
  bool isAvailable = false;
  bool initialIsAvailable = false;
  @override
  void initState() {
    super.initState();

    /// Default empty model
    workingHoursModel = WorkingHoursModel(
      workingHours: {
        for (var day in days) day: DayWorkingHours(enabled: false, slots: []),
      },
    );

    /// If passed manually
    if (widget.initialData != null) {
      workingHoursModel = widget.initialData!;
    } else {
      loadWorkingHours();
    }
  }

  bool get isAvailabilityChanged => isAvailable != initialIsAvailable;

  /// 🔥 Load and update screen
  Future<void> loadWorkingHours() async {
    setState(() => isLoading = true);

    // final response = await AppointmentService().fetchWorkingHours(widget.token);
    final docProfile = await AppointmentService().fetchDoctorsProfile(widget.token);

    if (docProfile != null && docProfile.success) {
      final fetchedModel = docProfile.data.workingHours;

      /// Ensure all 7 days exist
      for (var day in days) {
        fetchedModel.workingHours.putIfAbsent(
          day,
          () => DayWorkingHours(enabled: false, slots: []),
        );
      }

      setState(() {
        workingHoursModel = fetchedModel;
        isAvailable = docProfile.data.isAvailable;
        initialIsAvailable = docProfile.data.isAvailable;
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> pickTime(String day, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked == null) return;

    final formatted = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

    final currentDay = workingHoursModel.workingHours[day]!;

    TimeSlot slot;

    if (currentDay.slots.isNotEmpty) {
      slot = currentDay.slots.first;
    } else {
      slot = TimeSlot(start: '', end: '');
    }

    final updatedSlot = isStart ? slot.copyWith(start: formatted) : slot.copyWith(end: formatted);

    setState(() {
      workingHoursModel = workingHoursModel.copyWith(
        workingHours: {
          ...workingHoursModel.workingHours,
          day: currentDay.copyWith(
            slots: [updatedSlot],
          ),
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Working Hours')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                      Switch(
                        value: isAvailable,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            // initialIsAvailable = value;
                            isAvailable = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final data = workingHoursModel.workingHours[day]!;

                        final start = data.slots.isNotEmpty ? data.slots.first.start : '';
                        final end = data.slots.isNotEmpty ? data.slots.first.end : '';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                /// Checkbox
                                Checkbox(
                                  value: data.enabled,
                                  activeColor: Colors.green,
                                  onChanged: (value) {
                                    setState(() {
                                      workingHoursModel = workingHoursModel.copyWith(
                                        workingHours: {
                                          ...workingHoursModel.workingHours,
                                          day: data.copyWith(
                                            enabled: value ?? false,
                                            slots: value == true ? data.slots : [],
                                          ),
                                        },
                                      );
                                    });
                                  },
                                ),

                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    day[0].toUpperCase() + day.substring(1),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                /// Start Time
                                Expanded(
                                  child: GestureDetector(
                                    onTap: data.enabled ? () => pickTime(day, true) : null,
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        enabled: data.enabled,
                                        decoration: const InputDecoration(
                                          labelText: 'Start',
                                          border: OutlineInputBorder(),
                                        ),
                                        controller: TextEditingController(text: start),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                /// End Time
                                Expanded(
                                  child: GestureDetector(
                                    onTap: data.enabled ? () => pickTime(day, false) : null,
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        enabled: data.enabled,
                                        decoration: const InputDecoration(
                                          labelText: 'End',
                                          border: OutlineInputBorder(),
                                        ),
                                        controller: TextEditingController(text: end),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  /// Save Button
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isDataUpdated
                          ? null
                          : () async {
                              final json = workingHoursModel.toJson();
                              debugPrint(json.toString());

                              setState(() => isDataUpdated = true);

                              try {
                                final service = AppointmentService();

                                // 1️⃣ Update Working Hours
                                final workingHoursSuccess = await service.updateWorkingHours(
                                  widget.token,
                                  json,
                                );

                                // 2️⃣ Update Availability ONLY if changed
                                var availabilitySuccess = true;

                                if (isAvailabilityChanged) {
                                  availabilitySuccess = await service.updateDoctorsProfile(
                                    widget.token,
                                    {
                                      'isAvailable': isAvailable,
                                    },
                                  );
                                } 

                                final isSuccess = workingHoursSuccess && availabilitySuccess;

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isSuccess ? 'Updated successfully' : 'Failed to update',
                                    ),
                                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Something went wrong'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => isDataUpdated = false);
                                }
                              }
                            },
                      child: isDataUpdated
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
