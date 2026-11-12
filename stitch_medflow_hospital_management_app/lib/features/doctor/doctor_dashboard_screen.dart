import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme.dart';
import '../../core/state/medflow_state.dart';
import '../booking/models/appointment.dart';
import '../patients/screens/patients_list_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final VoidCallback onOpenEhr;
  final VoidCallback onOpenNotifications;

  const DoctorDashboardScreen({
    super.key,
    required this.onOpenEhr,
    required this.onOpenNotifications,
  });

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = MedFlowScope.of(context);
      if (state.authToken != null) {
        state.fetchOpdQueueFromApi();
        state.fetchPatientsFromApi(state.authToken!);
      }
    });
  }

  Future<void> _handleCallNext(BuildContext context) async {
    final state = MedFlowScope.of(context);
    try {
      final appt = await state.callNextPatient();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Called patient: ${appt.patientName} (Token #${appt.tokenNumber ?? '-'})'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.errorCrimson,
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  Future<void> _handleCheckIn(BuildContext context, int appointmentId) async {
    final state = MedFlowScope.of(context);
    try {
      final appt = await state.checkInAppointment(appointmentId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.secondaryEmerald,
            content: Text('Patient ${appt.patientName} checked in. Token #${appt.tokenNumber} issued.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.errorCrimson,
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  Future<void> _showCompleteConsultationDialog(BuildContext context, Appointment appt) async {
    final notesController = TextEditingController();
    final state = MedFlowScope.of(context);
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.secondaryEmerald),
              const SizedBox(width: 8),
              Text('Complete Consultation', style: AppTypography.headlineSm),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient: ${appt.patientName} (${appt.patientMrn})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Clinical Notes / Rx Instructions',
                  hintText: 'Enter clinical findings, medicines prescribed, follow-up advice...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDialogState(() => isSubmitting = true);
                      try {
                        await state.completeAppointment(
                          appt.id,
                          notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                        );
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.secondaryEmerald,
                              content: Text('Consultation completed for ${appt.patientName}!'),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.errorCrimson,
                              content: Text(e.toString().replaceFirst('Exception: ', '')),
                            ),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save & Complete'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = MedFlowScope.of(context);
    final userRole = state.currentUser?.role ?? 'doctor';
    final isDoctor = userRole == 'doctor';
    final canCheckIn = userRole == 'duty_desk' || userRole == 'nurse' || userRole == 'admin';

    final currentAppt = state.currentInConsultation;
    final waitingAppts = state.waitingAppointments;
    final scheduledAppts = state.scheduledAppointments;
    final totalAppts = state.opdQueueData?.total ?? state.opdAppointments.length;
    final doneCount = state.completedAppointments.length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (state.authToken != null) {
              await Future.wait([
                state.fetchOpdQueueFromApi(),
                state.fetchPatientsFromApi(state.authToken!),
              ]);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Clinician Context & Status Card
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
                              Stack(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primary, width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getInitials(state.currentUser?.name),
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: state.doctorStatus == DoctorStatus.available
                                            ? AppColors.secondaryEmerald
                                            : state.doctorStatus == DoctorStatus.procedure
                                                ? AppColors.amberWarning
                                                : AppColors.outline,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          state.currentUser?.name ?? 'Dr. Arvind Sharma',
                                          style: AppTypography.headlineSm.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.verified, size: 18, color: AppColors.primary),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${state.currentUser?.department ?? 'Cardiology'} • Room 204 • Metro OPD',
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          const Divider(height: 1, color: AppColors.surfaceContainer),
                          const SizedBox(height: 12),

                          // Interactive 3-State Availability Switch
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatusTab(
                                    label: 'Available',
                                    status: DoctorStatus.available,
                                    isActive: state.doctorStatus == DoctorStatus.available,
                                    activeColor: AppColors.secondaryEmerald,
                                    onTap: () => state.setDoctorStatus(DoctorStatus.available),
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatusTab(
                                    label: 'Procedure',
                                    status: DoctorStatus.procedure,
                                    isActive: state.doctorStatus == DoctorStatus.procedure,
                                    activeColor: AppColors.amberWarning,
                                    onTap: () => state.setDoctorStatus(DoctorStatus.procedure),
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatusTab(
                                    label: 'Break',
                                    status: DoctorStatus.onBreak,
                                    isActive: state.doctorStatus == DoctorStatus.onBreak,
                                    activeColor: AppColors.outline,
                                    onTap: () => state.setDoctorStatus(DoctorStatus.onBreak),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 4-Stat Bento KPI Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Today',
                            value: '$totalAppts',
                            subtitle: 'Scheduled',
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Done',
                            value: '$doneCount',
                            subtitle: 'Seen (${totalAppts > 0 ? ((doneCount / totalAppts) * 100).toInt() : 0}%)',
                            color: AppColors.secondaryEmerald,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Waiting',
                            value: '${waitingAppts.length}',
                            subtitle: 'Checked In',
                            color: AppColors.primary,
                            isHighlight: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildKpiCard(
                            title: 'In Clinic',
                            value: '${currentAppt != null ? 1 : 0}',
                            subtitle: 'Active',
                            color: currentAppt != null ? AppColors.secondaryEmerald : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Patient Queue Header with Call Next Button for Doctor
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 20, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'OPD Queue',
                              style: AppTypography.headlineSm.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const PatientsListScreen()),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.people_outline, size: 14, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Patients (${state.apiPatients.length})',
                                      style: AppTypography.labelSm.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isDoctor) ...[
                              const SizedBox(width: 6),
                              ElevatedButton.icon(
                                onPressed: () => _handleCallNext(context),
                                icon: const Icon(Icons.campaign, size: 16),
                                label: const Text('Call Next', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Loading State
                    if (state.isLoadingOpd)
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Syncing live OPD queue from server...'),
                          ],
                        ),
                      ),

                    // Error State with Retry
                    if (state.opdError != null && !state.isLoadingOpd)
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.errorCrimson.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.errorCrimson.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.errorCrimson, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.opdError!,
                                style: AppTypography.bodySm.copyWith(color: AppColors.errorCrimson),
                              ),
                            ),
                            TextButton(
                              onPressed: () => state.fetchOpdQueueFromApi(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),

                    // Empty State
                    if (!state.isLoadingOpd && state.opdAppointments.isEmpty && state.opdError == null)
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: AppColors.tertiary.withValues(alpha: 0.6)),
                            const SizedBox(height: 12),
                            Text(
                              'No Patients in Consultation Queue Today',
                              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'When reception books slots or checks in patients, live queue tokens will appear here.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const PatientsListScreen()),
                                );
                              },
                              icon: const Icon(Icons.people_outline, size: 18),
                              label: const Text('Open Patient Directory'),
                            ),
                          ],
                        ),
                      ),

                    // CURRENT IN CLINIC (Active Focused Card)
                    if (currentAppt != null)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary, width: 2),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Ribbon Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              color: AppColors.primary,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.secondaryEmerald,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'CURRENT IN CLINIC',
                                        style: AppTypography.labelSm.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Room 204 • Consultation Active',
                                    style: AppTypography.labelSm.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContainer,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '#${currentAppt.tokenNumber ?? '-'}',
                                          style: AppTypography.headlineSm.copyWith(
                                            color: AppColors.onPrimaryContainer,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currentAppt.patientName,
                                              style: AppTypography.headlineSm.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                            Text(
                                              '${currentAppt.patientAge} Yrs • ${currentAppt.patientGender} • ${currentAppt.patientMrn}',
                                              style: AppTypography.bodySm.copyWith(
                                                color: AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Clinical Reason Box
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Reason for Visit',
                                          style: AppTypography.labelSm.copyWith(color: AppColors.tertiary),
                                        ),
                                        Flexible(
                                          child: Text(
                                            currentAppt.reason ?? 'General Consultation',
                                            style: AppTypography.bodySm.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.onSurface,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // Consultation Actions Bar
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: widget.onOpenEhr,
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: AppColors.surfaceContainerHigh,
                                            side: BorderSide.none,
                                            foregroundColor: AppColors.onSurface,
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.assignment, size: 16, color: AppColors.primary),
                                              SizedBox(width: 6),
                                              Text('Open EHR', style: TextStyle(fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isDoctor)
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _showCompleteConsultationDialog(context, currentAppt),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.secondaryEmerald,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.check_circle_outline, size: 16),
                                                SizedBox(width: 4),
                                                Text('Complete', style: TextStyle(fontSize: 13)),
                                              ],
                                            ),
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

                    const SizedBox(height: 16),

                    // WAITING QUEUE CARDS
                    if (waitingAppts.isNotEmpty) ...[
                      Text(
                        'WAITING IN LOUNGE (${waitingAppts.length})',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.tertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: waitingAppts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final appt = waitingAppts[index];
                          final isNext = index == 0;
                          final timeStr =
                              '${appt.scheduledAt.hour.toString().padLeft(2, '0')}:${appt.scheduledAt.minute.toString().padLeft(2, '0')}';

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isNext ? AppColors.primary.withValues(alpha: 0.4) : AppColors.borderSubtle,
                              ),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceContainer,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                                            ),
                                            child: Text(
                                              '#${appt.tokenNumber ?? '-'}',
                                              style: AppTypography.headlineSm.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        appt.patientName,
                                                        style: AppTypography.labelLg.copyWith(
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.secondaryEmerald.withValues(alpha: 0.12),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Text(
                                                        timeStr,
                                                        style: AppTypography.labelSm.copyWith(
                                                          color: AppColors.secondaryEmerald,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '${appt.patientAge} Yrs • ${appt.patientGender} • ${appt.reason ?? 'Consultation'}',
                                                  style: AppTypography.bodySm.copyWith(fontSize: 11),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isDoctor)
                                      ElevatedButton(
                                        onPressed: () {
                                          state.callNextPatient(appointmentId: appt.id);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('Call In', style: TextStyle(fontSize: 11)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // SCHEDULED APPOINTMENTS LIST (With Check-In Button for Nurse / Duty Desk / Admin)
                    if (scheduledAppts.isNotEmpty) ...[
                      Text(
                        'SCHEDULED TODAY (${scheduledAppts.length})',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.tertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: scheduledAppts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final appt = scheduledAppts[index];
                          final timeStr =
                              '${appt.scheduledAt.hour.toString().padLeft(2, '0')}:${appt.scheduledAt.minute.toString().padLeft(2, '0')}';

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderSubtle),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              appt.patientName,
                                              style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Scheduled: $timeStr • ${appt.patientMrn}',
                                              style: AppTypography.bodySm.copyWith(
                                                fontSize: 11,
                                                color: AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                            if (appt.reason != null)
                                              Text(
                                                appt.reason!,
                                                style: AppTypography.bodySm.copyWith(fontSize: 10, color: AppColors.tertiary),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (canCheckIn)
                                  ElevatedButton(
                                    onPressed: () => _handleCheckIn(context, appt.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Check In', style: TextStyle(fontSize: 12)),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '??';
    final titles = ['dr.', 'dr', 'mr.', 'mr', 'mrs.', 'mrs', 'ms.', 'ms'];
    final parts = name.trim().split(' ').where((p) => !titles.contains(p.toLowerCase())).toList();

    if (parts.isEmpty) return '??';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Widget _buildStatusTab({
    required String label,
    required DoctorStatus status,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive ? AppTheme.cardShadow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive ? activeColor : AppColors.outlineVariant,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    bool isHighlight = false,
  }) {
    Color bg = AppColors.surfaceContainerLowest;
    Color border = AppColors.borderSubtle;

    if (isHighlight) {
      bg = AppColors.primary.withValues(alpha: 0.08);
      border = AppColors.primary.withValues(alpha: 0.25);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.headlineMd.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: AppTypography.bodySm.copyWith(
              fontSize: 9,
              color: AppColors.tertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
