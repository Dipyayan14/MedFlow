import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../state/medflow_state.dart';

class StatusPill extends StatefulWidget {
  final DoctorStatus status;
  final bool compact;

  const StatusPill({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  State<StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<StatusPill> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    Color dotColor;
    String label;

    switch (widget.status) {
      case DoctorStatus.available:
        bg = AppColors.badgeEmeraldBg;
        textColor = AppColors.badgeEmeraldText;
        dotColor = AppColors.secondaryEmerald;
        label = widget.compact ? 'Available' : 'Available for OPD';
        break;
      case DoctorStatus.procedure:
        bg = AppColors.amberContainer;
        textColor = AppColors.amberOnContainer;
        dotColor = AppColors.amberWarning;
        label = widget.compact ? 'In Procedure' : 'In Procedure / OT';
        break;
      case DoctorStatus.onBreak:
        bg = AppColors.surfaceContainerHigh;
        textColor = AppColors.onSurfaceVariant;
        dotColor = AppColors.outline;
        label = widget.compact ? 'On Break' : 'On Clinical Break';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 8 : 12,
        vertical: widget.compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: dotColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.status == DoctorStatus.available)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withValues(
                          alpha: 0.3 + (_pulseController.value * 0.4),
                        ),
                        blurRadius: 4 + (_pulseController.value * 4),
                        spreadRadius: 1 + (_pulseController.value * 2),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
