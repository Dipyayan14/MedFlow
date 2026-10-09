import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../state/medflow_state.dart';
import 'emergency_dialog.dart';

class MedFlowTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? subtitle;
  final Widget? leading;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onRoleTap;
  final bool showRoleBadge;

  const MedFlowTopAppBar({
    super.key,
    this.subtitle,
    this.leading,
    this.onNotificationsTap,
    this.onRoleTap,
    this.showRoleBadge = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final state = MedFlowScope.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Leading Icon & Brand
              Row(
                children: [
                  if (leading != null)
                    leading!
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            'MedFlow',
                            style: AppTypography.headlineSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'v3.4',
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
                        subtitle ?? 'Demo Hospital • Main Campus',
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.tertiarySlate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Trailing actions: Emergency, Notifications & Role badge
              Row(
                children: [
                  // Role Switcher Chip
                  if (showRoleBadge)
                    InkWell(
                      onTap: onRoleTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(state.activeRole.icon, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              state.activeRole.title.split(' ').first,
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),

                  // Emergency SOS button
                  IconButton(
                    icon: const Icon(Icons.emergency, color: AppColors.errorCrimson),
                    tooltip: 'Emergency Code Blue',
                    onPressed: () => showEmergencyEscalationDialog(context),
                  ),

                  // Notifications Bell with live unread badge
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: AppColors.tertiarySlate),
                        tooltip: 'Notifications',
                        onPressed: onNotificationsTap,
                      ),
                      if (state.unreadAlertsCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.errorCrimson,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
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
