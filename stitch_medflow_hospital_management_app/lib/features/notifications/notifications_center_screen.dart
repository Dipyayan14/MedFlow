import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme.dart';
import '../../core/state/medflow_state.dart';

class NotificationsCenterScreen extends StatefulWidget {
  final VoidCallback onOpenQueue;

  const NotificationsCenterScreen({
    super.key,
    required this.onOpenQueue,
  });

  @override
  State<NotificationsCenterScreen> createState() => _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final state = MedFlowScope.of(context);
    final alerts = state.alerts.where((a) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Critical Alerts') return a.severity == AlertSeverity.critical;
      if (_selectedFilter == 'Availability') return a.tag.contains('AVAILABLE');
      if (_selectedFilter == 'OPD Queue') return a.tag.contains('QUEUE') || a.tag.contains('WARNING');
      return true;
    }).toList();

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
                  // Title & Live Telemetry Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clinical Notifications',
                              style: AppTypography.headlineLgMobile.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
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
                                Expanded(
                                  child: Text(
                                    'LIVE HOSPITAL TELEMETRY • CENTRAL WING',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.secondaryEmerald,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          state.markAllAlertsRead();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All notifications marked as read')),
                          );
                        },
                        child: Text(
                          'Mark all as read',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Filter Pills Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill('All', '${state.alerts.length}'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Availability', '4'),
                        const SizedBox(width: 8),
                        _buildFilterPill('OPD Queue', '5'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Critical Alerts', '3', isCritical: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Quick Stats Bento Strip (3 cols)
                  Row(
                    children: [
                      Expanded(
                        child: _buildBentoStat(
                          label: 'RESPONSE TIME',
                          value: '< 2.4m',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildBentoStat(
                          label: 'ACTIVE QUEUE',
                          value: '38 Pts',
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildBentoStat(
                          label: 'TRAUMA ESC',
                          value: 'Level 1',
                          color: AppColors.errorCrimson,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Chronological Alert Stream
                  Text(
                    'TELEMETRY STREAM',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.tertiary,
                      letterSpacing: 0.6,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: alerts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final a = alerts[i];
                      final isCritical = a.severity == AlertSeverity.critical;
                      final isWarning = a.severity == AlertSeverity.warning;

                      Color bg = AppColors.surfaceContainerLowest;
                      Color border = AppColors.borderSubtle;
                      Color tagBg = AppColors.primary.withValues(alpha: 0.1);
                      Color tagColor = AppColors.primary;

                      if (isCritical) {
                        bg = AppColors.errorContainer.withValues(alpha: 0.35);
                        border = AppColors.errorCrimson.withValues(alpha: 0.4);
                        tagBg = AppColors.errorCrimson;
                        tagColor = Colors.white;
                      } else if (isWarning) {
                        bg = AppColors.amberContainer.withValues(alpha: 0.35);
                        border = AppColors.amberWarning.withValues(alpha: 0.3);
                        tagBg = AppColors.amberWarning;
                        tagColor = Colors.white;
                      }

                      return Dismissible(
                        key: Key(a.id),
                        onDismissed: (_) => state.dismissAlert(a.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.errorCrimson,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: tagBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        if (isCritical)
                                          Container(
                                            width: 6,
                                            height: 6,
                                            margin: const EdgeInsets.only(right: 4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        Text(
                                          a.tag,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: tagColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, size: 12, color: AppColors.tertiary),
                                      const SizedBox(width: 4),
                                      Text(
                                        a.timeAgo,
                                        style: AppTypography.bodySm.copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                a.title,
                                style: AppTypography.labelLg.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                a.subtitle,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (isCritical) ...[
                                    OutlinedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Alert acknowledged')),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text('Acknowledge', style: TextStyle(fontSize: 12)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: AppColors.errorCrimson,
                                            content: Text('Rapid Trauma Team dispatched to Bed #12'),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.errorCrimson,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text('Dispatch Team', style: TextStyle(fontSize: 12)),
                                    ),
                                  ] else ...[
                                    TextButton(
                                      onPressed: widget.onOpenQueue,
                                      child: const Text('View in Queue', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
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

  Widget _buildFilterPill(String label, String count, {bool isCritical = false}) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isCritical ? AppColors.errorCrimson : AppColors.primary)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isCritical ? AppColors.errorCrimson.withValues(alpha: 0.4) : AppColors.borderSubtle),
          ),
        ),
        child: Row(
          children: [
            if (isCritical && !isSelected) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.errorCrimson,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isCritical ? AppColors.errorCrimson : AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.tertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.tertiary,
              fontSize: 9,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.headlineSm.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
