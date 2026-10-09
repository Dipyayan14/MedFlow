import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme.dart';
import '../../core/state/medflow_state.dart';

class DoctorDashboardScreen extends StatelessWidget {
  final VoidCallback onOpenEhr;
  final VoidCallback onOpenNotifications;

  const DoctorDashboardScreen({
    super.key,
    required this.onOpenEhr,
    required this.onOpenNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final state = MedFlowScope.of(context);
    final currentPatient = state.currentInClinic;
    final waitingList = state.waitingList;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
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
                          value: '34',
                          subtitle: 'Tokens',
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Done',
                          value: '${state.tokensDoneToday}',
                          subtitle: 'Seen (${((state.tokensDoneToday / 34) * 100).toInt()}%)',
                          color: AppColors.secondaryEmerald,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Waiting',
                          value: '${waitingList.length}',
                          subtitle: 'In Clinic',
                          color: AppColors.primary,
                          isHighlight: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildKpiCard(
                          title: 'SOS',
                          value: '1',
                          subtitle: 'Triage Red',
                          color: AppColors.errorCrimson,
                          isError: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Patient Queue Timeline Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 20, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Patient Queue',
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Live Telemetry',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // CURRENT IN CLINIC (Active Focused Card)
                  if (currentPatient != null)
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
                                  currentPatient.waitingLocation,
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
                                        '#${currentPatient.tokenNumber}',
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
                                            currentPatient.name,
                                            style: AppTypography.headlineSm.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                          Text(
                                            '${currentPatient.age} Yrs • ${currentPatient.gender} • ${currentPatient.uhid}',
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
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Reason for Visit',
                                            style: AppTypography.labelSm.copyWith(color: AppColors.tertiary),
                                          ),
                                          Text(
                                            currentPatient.complaint,
                                            style: AppTypography.bodySm.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (currentPatient.hasBpAlert) ...[
                                        const SizedBox(height: 8),
                                        const Divider(height: 1, color: AppColors.borderSubtle),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.error, size: 16, color: AppColors.errorCrimson),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'High BP Alert',
                                                  style: AppTypography.labelSm.copyWith(
                                                    color: AppColors.errorCrimson,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.errorContainer,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                currentPatient.bp ?? '145 / 95 mmHg',
                                                style: AppTypography.labelMd.copyWith(
                                                  color: AppColors.onErrorContainer,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Consultation Actions Bar (3 Buttons)
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: onOpenEhr,
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
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('e-Prescription Pad opened')),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: AppColors.surfaceContainerHigh,
                                          side: BorderSide.none,
                                          foregroundColor: AppColors.onSurface,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.medication, size: 16, color: AppColors.primary),
                                            SizedBox(width: 6),
                                            Text('Prescribe Rx', style: TextStyle(fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          state.advanceNextToken();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: AppColors.primary,
                                              content: Text('Consultation completed. Next token called!'),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Next Token', style: TextStyle(fontSize: 13)),
                                            SizedBox(width: 4),
                                            Icon(Icons.arrow_forward, size: 16),
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

                  // Waiting Queue Cards
                  Text(
                    'WAITING IN LOUNGE (${waitingList.length})',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.tertiary,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: waitingList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final p = waitingList[index];
                      final isNext = index == 0;

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
                                          '#${p.tokenNumber}',
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
                                                    p.name,
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
                                                    p.arrivalTime,
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
                                              '${p.age} Yrs • ${p.gender} • ${p.complaint}',
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
                                if (isNext)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'NEXT IN LINE',
                                      style: AppTypography.labelSm.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            if (p.spo2 != null || p.pulse != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    if (p.spo2 != null)
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.air, size: 16, color: AppColors.primary),
                                            const SizedBox(width: 6),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'SpO2 Vitals',
                                                  style: AppTypography.bodySm.copyWith(fontSize: 9),
                                                ),
                                                Text(
                                                  '${p.spo2}% Room Air',
                                                  style: AppTypography.labelSm.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.onSurface,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (p.pulse != null)
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.favorite, size: 16, color: AppColors.errorCrimson),
                                            const SizedBox(width: 6),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Resting Pulse',
                                                  style: AppTypography.bodySm.copyWith(fontSize: 9),
                                                ),
                                                Text(
                                                  '${p.pulse} bpm (Regular)',
                                                  style: AppTypography.labelSm.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.onSurface,
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
                            ],

                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  p.waitingLocation,
                                  style: AppTypography.bodySm.copyWith(fontSize: 11),
                                ),
                                InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Paging ${p.name} to Room 204')),
                                    );
                                  },
                                  child: Text(
                                    'Page Patient',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '??';
    // Skip common titles like Dr., Mr., Mrs., Ms.
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
    bool isError = false,
  }) {
    Color bg = AppColors.surfaceContainerLowest;
    Color border = AppColors.borderSubtle;

    if (isHighlight) {
      bg = AppColors.primary.withValues(alpha: 0.08);
      border = AppColors.primary.withValues(alpha: 0.25);
    } else if (isError) {
      bg = AppColors.errorContainer.withValues(alpha: 0.35);
      border = AppColors.errorCrimson.withValues(alpha: 0.2);
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
              color: isError ? AppColors.errorCrimson : AppColors.onSurfaceVariant,
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
              color: isError ? AppColors.errorCrimson : AppColors.tertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
