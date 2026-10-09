import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  // Operations Hub Header
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'OPERATIONS HUB',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondaryEmerald,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Updated 2m ago',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Hospital Admin Command',
                          style: AppTypography.headlineLgMobile.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.domain, size: 16, color: AppColors.tertiary),
                            const SizedBox(width: 6),
                            Text(
                              'Demo Hospital Central • OPD & IPD Wing',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(Icons.expand_more, size: 16, color: AppColors.outline),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Date Filter & Quick Switch Bar
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Today, 21 Oct',
                                style: AppTypography.labelMd.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.tune, size: 16, color: AppColors.tertiary),
                              label: Text(
                                'Filter',
                                style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2x2 Bento KPI Grid
                  Row(
                    children: [
                      // KPI 1: OPD Footfall
                      Expanded(
                        child: _buildBentoMetric(
                          title: 'OPD Footfall',
                          icon: Icons.group,
                          value: '1,420',
                          unit: 'Patients',
                          bottomWidget: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.arrow_upward, size: 14, color: AppColors.secondaryEmerald),
                                  Text(
                                    '12%',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.secondaryEmerald,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              CustomPaint(
                                size: const Size(54, 18),
                                painter: SparklinePainter(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // KPI 2: Doc Utilization
                      Expanded(
                        child: _buildBentoMetric(
                          title: 'Doc Utilization',
                          icon: Icons.medical_services_outlined,
                          value: '88.4%',
                          unit: '42/48 on duty',
                          bottomWidget: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Optimal load',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                              SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  value: 0.88,
                                  strokeWidth: 3.5,
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // KPI 3: Avg Wait Time
                      Expanded(
                        child: _buildBentoMetric(
                          title: 'Avg Wait Time',
                          icon: Icons.hourglass_top,
                          value: '18 mins',
                          unit: 'Triage to consult',
                          bottomWidget: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.amberContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.amberOnContainer,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '-8m vs Target',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.amberOnContainer,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // KPI 4: Today's Revenue
                      Expanded(
                        child: _buildBentoMetric(
                          title: "Today's Rev",
                          icon: Icons.payments,
                          value: '₹14.8 L',
                          unit: 'OPD & Labs',
                          bottomWidget: Row(
                            children: [
                              const Icon(Icons.trending_up, size: 14, color: AppColors.secondaryEmerald),
                              const SizedBox(width: 4),
                              Text(
                                'Target ₹16.0 L',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.secondaryEmerald,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // OPD Hourly Flow Bar Chart
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hourly Check-ins',
                                    style: AppTypography.headlineSm.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Real-time OPD patient surge (08:00 - 18:00)',
                                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Peak 11 AM',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.onPrimaryFixed,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Bar Chart Visualization
                        SizedBox(
                          height: 120,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildHourlyBar('8A', 0.35),
                              _buildHourlyBar('9A', 0.55),
                              _buildHourlyBar('10A', 0.75),
                              _buildHourlyBar('11A', 1.0, isPeak: true, peakValue: '184'),
                              _buildHourlyBar('12P', 0.80),
                              _buildHourlyBar('1P', 0.40),
                              _buildHourlyBar('2P', 0.50),
                              _buildHourlyBar('3P', 0.68),
                              _buildHourlyBar('4P', 0.60),
                              _buildHourlyBar('5P', 0.45),
                              _buildHourlyBar('6P', 0.30),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Department Load Progress Bars
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Department Load',
                              style: AppTypography.headlineSm.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'Real-time Beds/Slots',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDeptBar('Emergency & Trauma', 0.98, AppColors.errorCrimson, isCritical: true),
                        const SizedBox(height: 14),
                        _buildDeptBar('Cardiology', 0.94, AppColors.primary),
                        const SizedBox(height: 14),
                        _buildDeptBar('Pediatrics', 0.64, AppColors.tertiary),
                        const SizedBox(height: 14),
                        _buildDeptBar('Orthopedics', 0.78, AppColors.primaryContainer),
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

  Widget _buildBentoMetric({
    required String title,
    required IconData icon,
    required String value,
    required String unit,
    required Widget bottomWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
              ),
              Icon(icon, size: 18, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.headlineSm.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            unit,
            style: AppTypography.bodySm.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 8),
          bottomWidget,
        ],
      ),
    );
  }

  Widget _buildHourlyBar(String hour, double fraction, {bool isPeak = false, String? peakValue}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isPeak && peakValue != null)
            Text(
              peakValue,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            )
          else
            const SizedBox(height: 14),
          const SizedBox(height: 4),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fraction.clamp(0.05, 1.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(
                    color: isPeak ? AppColors.primary : AppColors.surfaceContainerHigh,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hour,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isPeak ? FontWeight.bold : FontWeight.w500,
              color: isPeak ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeptBar(String name, double fraction, Color color, {bool isCritical = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  name,
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
                ),
                if (isCritical) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.badgeRedBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'High Load',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.badgeRedText,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '${(fraction * 100).toInt()}%',
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondaryEmerald
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.4, size.height * 0.75);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.55);
    path.lineTo(size.width, size.height * 0.15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
