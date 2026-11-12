import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme.dart';
import '../../core/state/medflow_state.dart';
import '../../services/api_service.dart';
import '../patients/models/patient.dart';
import 'models/appointment.dart';

class AppointmentWizardScreen extends StatefulWidget {
  final VoidCallback onBookingComplete;

  const AppointmentWizardScreen({
    super.key,
    required this.onBookingComplete,
  });

  @override
  State<AppointmentWizardScreen> createState() => _AppointmentWizardScreenState();
}

class _AppointmentWizardScreenState extends State<AppointmentWizardScreen> {
  int _selectedDateIndex = 0;
  String _selectedSlot = '10:00 AM';
  final TextEditingController _complaintController =
      TextEditingController(text: 'Routine cardiology consultation and follow-up review');

  List<Patient> _patients = [];
  Patient? _selectedPatient;
  bool _isLoadingPatients = false;

  List<DoctorInfo> _doctors = [];
  DoctorInfo? _selectedDoctor;
  bool _isLoadingDoctors = false;

  bool _isSubmitting = false;
  String? _bookingError;

  late final List<DateTime> _availableDates;

  final List<String> _morningSlots = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM'];
  final List<String> _afternoonSlots = ['02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM'];
  final List<String> _eveningSlots = ['04:30 PM', '05:00 PM', '05:30 PM'];

  @override
  void initState() {
    super.initState();
    // Generate next 7 days
    final now = DateTime.now();
    _availableDates = List.generate(7, (i) => now.add(Duration(days: i)));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final state = MedFlowScope.of(context);
    final token = state.authToken;
    if (token == null) return;

    setState(() {
      _isLoadingPatients = true;
      _isLoadingDoctors = true;
      _bookingError = null;
    });

    try {
      final patientsRes = await ApiService.getPatients(token: token, perPage: 100);
      final doctorsRes = await ApiService.getDoctors(token: token);

      if (mounted) {
        setState(() {
          _patients = patientsRes.data;
          if (_patients.isNotEmpty) {
            _selectedPatient = _patients.first;
          }

          _doctors = doctorsRes;
          if (_doctors.isNotEmpty) {
            // Default to currently logged-in doctor if role is doctor, else first doctor
            if (state.currentUser?.role == 'doctor') {
              _selectedDoctor = _doctors.firstWhere(
                (d) => d.id == state.currentUser!.id,
                orElse: () => _doctors.first,
              );
            } else {
              _selectedDoctor = _doctors.first;
            }
          }

          _isLoadingPatients = false;
          _isLoadingDoctors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPatients = false;
          _isLoadingDoctors = false;
          _bookingError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  String _formatSlotToDateTime(DateTime date, String slotStr) {
    // Parse e.g. "10:30 AM" or "02:30 PM"
    final parts = slotStr.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPm = parts.length > 1 && parts[1].toUpperCase() == 'PM';

    if (isPm && hour < 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = hour.toString().padLeft(2, '0');
    final min = minute.toString().padLeft(2, '0');

    return '$y-$m-$d $h:$min:00';
  }

  Future<void> _handleConfirmBooking() async {
    final state = MedFlowScope.of(context);
    final token = state.authToken;
    if (token == null) return;

    if (_selectedPatient == null) {
      setState(() => _bookingError = 'Please select a registered patient.');
      return;
    }

    if (_selectedDoctor == null) {
      setState(() => _bookingError = 'Please select an attending doctor.');
      return;
    }

    final selectedDate = _availableDates[_selectedDateIndex];
    final scheduledAt = _formatSlotToDateTime(selectedDate, _selectedSlot);

    setState(() {
      _isSubmitting = true;
      _bookingError = null;
    });

    try {
      final appointment = await ApiService.bookAppointment(
        token: token,
        patientId: _selectedPatient!.id,
        doctorId: _selectedDoctor!.id,
        scheduledAt: scheduledAt,
        reason: _complaintController.text.trim(),
      );

      await state.fetchOpdQueueFromApi();

      if (mounted) {
        setState(() => _isSubmitting = false);
        _showConfirmationDialog(appointment);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _bookingError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _showConfirmationDialog(Appointment appointment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.secondaryEmerald.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 36, color: AppColors.secondaryEmerald),
              ),
              const SizedBox(height: 14),
              Text(
                'APPOINTMENT BOOKED',
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'OPD slot reserved successfully. Patient record is linked in queue.',
                style: AppTypography.bodySm,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Patient:'),
                        Text(
                          appointment.patientName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Doctor:'),
                        Text(
                          appointment.doctorDisplayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Scheduled:'),
                        Text(
                          '${appointment.scheduledAt.day}/${appointment.scheduledAt.month}/${appointment.scheduledAt.year} • $_selectedSlot',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status:'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            appointment.status.toUpperCase(),
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onBookingComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text('View in OPD Queue'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OPD BOOKING',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Schedule Appointment',
              style: AppTypography.headlineSm.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Server Validation Error Banner
                  if (_bookingError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorCrimson.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.errorCrimson.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.errorCrimson, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _bookingError!,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.errorCrimson,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: AppColors.errorCrimson),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() => _bookingError = null),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 1. SELECT PATIENT CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_search_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Select Registered Patient',
                              style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingPatients)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        else if (_patients.isEmpty)
                          Text(
                            'No patients found in directory. Please register a patient first.',
                            style: AppTypography.bodySm.copyWith(color: AppColors.errorCrimson),
                          )
                        else
                          DropdownButtonFormField<int>(
                            initialValue: _selectedPatient?.id,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Patient (Name & MRN)',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            items: _patients.map((p) {
                              return DropdownMenuItem<int>(
                                value: p.id,
                                child: Text('${p.name} (${p.mrn}) • ${p.calculatedAge}y ${p.gender}'),
                              );
                            }).toList(),
                            onChanged: (id) {
                              if (id != null) {
                                setState(() {
                                  _selectedPatient = _patients.firstWhere((p) => p.id == id);
                                });
                              }
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2. SELECT ATTENDING DOCTOR CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.medical_services_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Select Attending Doctor',
                              style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingDoctors)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        else if (_doctors.isEmpty)
                          Text(
                            'No doctors available.',
                            style: AppTypography.bodySm.copyWith(color: AppColors.errorCrimson),
                          )
                        else
                          DropdownButtonFormField<int>(
                            initialValue: _selectedDoctor?.id,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Doctor & Department',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            items: _doctors.map((d) {
                              final dept = d.department ?? d.specialization ?? 'General';
                              return DropdownMenuItem<int>(
                                value: d.id,
                                child: Text('${d.name} ($dept)'),
                              );
                            }).toList(),
                            onChanged: (id) {
                              if (id != null) {
                                setState(() {
                                  _selectedDoctor = _doctors.firstWhere((d) => d.id == id);
                                });
                              }
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 3. DATE SELECTOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Select Appointment Date',
                            style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Text(
                        'Asia/Kolkata IST',
                        style: AppTypography.labelSm.copyWith(color: AppColors.tertiary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_availableDates.length, (i) {
                        final date = _availableDates[i];
                        final isSelected = _selectedDateIndex == i;
                        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final dayStr = dayNames[date.weekday - 1];
                        final isToday = i == 0;

                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () => setState(() => _selectedDateIndex = i),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 84,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected ? AppTheme.cardShadow : null,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    isToday ? 'Today' : dayStr,
                                    style: AppTypography.labelSm.copyWith(
                                      color: isSelected ? Colors.white.withValues(alpha: 0.9) : AppColors.tertiary,
                                      fontWeight: isToday ? FontWeight.w800 : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${date.day}',
                                    style: AppTypography.headlineSm.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? Colors.white : AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${date.month}/${date.year}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. TIME SLOT PICKER
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Select Time Slot',
                        style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _buildSlotCategory('Morning OPD', _morningSlots),
                  const SizedBox(height: 8),
                  _buildSlotCategory('Afternoon OPD', _afternoonSlots),
                  const SizedBox(height: 8),
                  _buildSlotCategory('Evening OPD', _eveningSlots),

                  const SizedBox(height: 16),

                  // 5. REASON FOR VISIT
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chief Complaint / Clinical Reason',
                          style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _complaintController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Chest pain follow-up, ECG review, routine checkup...',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SUBMIT BUTTON
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleConfirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                              SizedBox(width: 10),
                              Text('Saving Appointment...', style: TextStyle(color: Colors.white)),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Confirm & Book Appointment',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotCategory(String title, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.tertiary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((s) {
            final isSelected = _selectedSlot == s;
            return ChoiceChip(
              label: Text(s),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceContainerLowest,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
              onSelected: (_) => setState(() => _selectedSlot = s),
            );
          }).toList(),
        ),
      ],
    );
  }
}
