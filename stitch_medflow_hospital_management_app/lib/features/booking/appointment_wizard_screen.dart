import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme.dart';
import '../../core/state/medflow_state.dart';

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
  int _selectedDateIndex = 1; // Tue 22 Oct default
  String _selectedSlot = '10:15 AM';
  bool _isSelfBooking = true;
  final TextEditingController _complaintController =
      TextEditingController(text: 'Follow-up ECG review & mild exertion discomfort');
  final TextEditingController _patientNameController =
      TextEditingController(text: 'Rajesh Gupta');

  final List<Map<String, dynamic>> _dates = [
    {'day': 'Mon', 'date': '21', 'slots': 'Full', 'isFull': true},
    {'day': 'Tue', 'date': '22', 'slots': '4 Slots', 'isFull': false},
    {'day': 'Wed', 'date': '23', 'slots': '8 Slots', 'isFull': false},
    {'day': 'Thu', 'date': '24', 'slots': '6 Slots', 'isFull': false},
    {'day': 'Fri', 'date': '25', 'slots': '12 Slots', 'isFull': false},
    {'day': 'Sat', 'date': '26', 'slots': '3 Slots', 'isFull': false},
  ];

  final List<String> _morningSlots = ['09:00 AM', '09:30 AM', '10:15 AM', '11:00 AM'];
  final List<String> _afternoonSlots = ['02:00 PM', '02:45 PM', '03:30 PM'];
  final List<String> _eveningSlots = ['05:00 PM', '05:30 PM'];

  @override
  void dispose() {
    _complaintController.dispose();
    _patientNameController.dispose();
    super.dispose();
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
              'OPD PORTAL',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Book OPD Appointment',
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
        child: Column(
          children: [
            // 3-Step Wizard Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: AppColors.surfaceContainerLowest,
              child: Row(
                children: [
                  // Step 1: Doctor (Done)
                  Column(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryEmerald,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Doctor',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.secondaryEmerald,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.secondaryEmerald,
                      margin: const EdgeInsets.only(bottom: 18),
                    ),
                  ),
                  // Step 2: Slot (Active)
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            '2',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Slot',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.outlineVariant,
                      margin: const EdgeInsets.only(bottom: 18),
                    ),
                  ),
                  // Step 3: Patient
                  Column(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '3',
                            style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Patient',
                        style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selected Doctor Preview Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSubtle),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.outlineVariant),
                                ),
                                child: const Center(
                                  child: Text(
                                    'AS',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Dr. Arvind Sharma',
                                          style: AppTypography.labelLg.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'MD, DM',
                                            style: AppTypography.labelSm.copyWith(
                                              color: AppColors.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Senior Cardiologist • Cardiology Dept',
                                      style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.domain, size: 14, color: AppColors.tertiary),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Metro Heart Centre, New Delhi',
                                              style: AppTypography.bodySm.copyWith(fontSize: 11),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Fee ₹1,200',
                                          style: AppTypography.labelMd.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Date Carousel Header
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'October 2024',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.onSecondaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Horizontal Date Selector
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(_dates.length, (i) {
                              final d = _dates[i];
                              final isSelected = _selectedDateIndex == i;
                              final isFull = d['isFull'] as bool;

                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: InkWell(
                                  onTap: isFull
                                      ? null
                                      : () {
                                          setState(() => _selectedDateIndex = i);
                                        },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: 82,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.surfaceContainerLowest,
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
                                          d['day'],
                                          style: AppTypography.labelSm.copyWith(
                                            color: isSelected
                                                ? Colors.white.withValues(alpha: 0.85)
                                                : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          d['date'],
                                          style: AppTypography.headlineSm.copyWith(
                                            color: isSelected ? Colors.white : AppColors.onSurface,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white.withValues(alpha: 0.25)
                                                : isFull
                                                    ? AppColors.badgeRedBg
                                                    : AppColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            d['slots'],
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? Colors.white
                                                  : isFull
                                                      ? AppColors.badgeRedText
                                                      : AppColors.tertiary,
                                            ),
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

                        const SizedBox(height: 20),

                        // Time Slots Header
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Available Consultation Slots',
                              style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Morning Slots
                        _buildSlotSection('Morning OPD (09:00 - 12:00)', _morningSlots),
                        const SizedBox(height: 12),
                        // Afternoon Slots
                        _buildSlotSection('Afternoon OPD (14:00 - 16:30)', _afternoonSlots),
                        const SizedBox(height: 12),
                        // Evening Slots
                        _buildSlotSection('Evening OPD (17:00 - 19:00)', _eveningSlots),

                        const SizedBox(height: 20),

                        // Patient Details Card
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
                              Text(
                                'Patient Information',
                                style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              // Self vs Family Switch
                              Row(
                                children: [
                                  Expanded(
                                    child: ChoiceChip(
                                      label: const Text('Self (Rajesh Gupta)'),
                                      selected: _isSelfBooking,
                                      onSelected: (val) {
                                        setState(() {
                                          _isSelfBooking = true;
                                          _patientNameController.text = 'Rajesh Gupta';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ChoiceChip(
                                      label: const Text('Family Member'),
                                      selected: !_isSelfBooking,
                                      onSelected: (val) {
                                        setState(() {
                                          _isSelfBooking = false;
                                          _patientNameController.text = '';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _patientNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Patient Full Name',
                                  prefixIcon: Icon(Icons.person, color: AppColors.primary, size: 20),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _complaintController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Primary Clinical Complaint',
                                  hintText: 'e.g. Chest pain, breathlessness, routine review',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.verified, size: 14, color: AppColors.secondaryEmerald),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Linked to Health ID: 91-8273-1092-2341 (Auto-Verified)',
                                    style: AppTypography.bodySm.copyWith(
                                      fontSize: 10,
                                      color: AppColors.secondaryEmerald,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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

            // Sticky Bottom Payment & Confirmation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: const Border(top: BorderSide(color: AppColors.borderSubtle)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'TOTAL PAYABLE',
                              style: AppTypography.labelSm.copyWith(fontSize: 10, color: AppColors.tertiary),
                            ),
                            Text(
                              '₹1,200',
                              style: AppTypography.headlineSm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _confirmAndGenerateToken(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Confirm & Generate Token',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.confirmation_number, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotSection(String title, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final isSelected = _selectedSlot == slot;
            final isBooked = slot == '11:00 AM';

            return InkWell(
              onTap: isBooked ? null : () => setState(() => _selectedSlot = slot),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isBooked
                          ? AppColors.surfaceContainerHigh
                          : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : isBooked
                            ? Colors.transparent
                            : AppColors.borderSubtle,
                  ),
                ),
                child: Text(
                  isBooked ? '$slot (Booked)' : slot,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isBooked
                            ? AppColors.outline
                            : AppColors.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _confirmAndGenerateToken(BuildContext context) {
    final state = MedFlowScope.of(context);
    final patientName = _patientNameController.text.trim().isEmpty ? 'Rajesh Gupta' : _patientNameController.text.trim();
    final newTokenNum = state.queue.isNotEmpty ? state.queue.last.tokenNumber + 1 : 24;

    state.addPatientToken(
      PatientToken(
        tokenNumber: newTokenNum,
        name: patientName,
        age: 52,
        gender: 'Male',
        uhid: 'UHID-902$newTokenNum',
        complaint: _complaintController.text.trim(),
        waitingLocation: 'Scheduled: $_selectedSlot',
        arrivalTime: 'Slot Booked',
        isInClinic: false,
      ),
    );

    showDialog(
      context: context,
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
                'APPOINTMENT CONFIRMED',
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Digital OPD token generated and sent to patient registered WhatsApp & SMS.',
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
                        const Text('Token Number:'),
                        Text(
                          '#$newTokenNum',
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Doctor:'),
                        const Text('Dr. Arvind Sharma (Rm 204)', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Scheduled Slot:'),
                        Text('$_selectedSlot • Tue 22 Oct', style: const TextStyle(fontWeight: FontWeight.w600)),
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
}
