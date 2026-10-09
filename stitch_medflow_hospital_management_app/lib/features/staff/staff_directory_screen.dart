import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme.dart';

class StaffDirectoryScreen extends StatefulWidget {
  const StaffDirectoryScreen({super.key});

  @override
  State<StaffDirectoryScreen> createState() => _StaffDirectoryScreenState();
}

class _StaffDirectoryScreenState extends State<StaffDirectoryScreen> {
  String _selectedRoleFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _staffMembers = [
    {
      'name': 'Dr. Arvind Sharma',
      'initials': 'AS',
      'role': 'Doctors',
      'designation': 'Chief Interventional Cardiologist',
      'empCode': 'MED-1042',
      'status': 'On Duty',
      'statusColor': AppColors.secondaryEmerald,
      'shift': 'Morning Shift (Room 204)',
      'location': 'Cath Lab A',
      'verified': true,
    },
    {
      'name': 'Nurse Sunita Rao',
      'initials': 'SR',
      'role': 'Nurses',
      'designation': 'Senior Triage & Critical Care Nurse',
      'empCode': 'NUR-3021',
      'status': 'On Duty',
      'statusColor': AppColors.secondaryEmerald,
      'shift': 'Morning Shift (08:00 - 16:00)',
      'location': 'Emergency Bay 3 / ICU',
      'verified': true,
    },
    {
      'name': 'Dr. Rajesh Khanna',
      'initials': 'RK',
      'role': 'Doctors',
      'designation': 'Senior Orthopedic Surgeon',
      'empCode': 'MED-1088',
      'status': 'In Surgery',
      'statusColor': AppColors.amberWarning,
      'shift': 'Surgical Block (OT-02)',
      'location': 'Operation Theatre Wing',
      'verified': true,
    },
    {
      'name': 'Amit Roy',
      'initials': 'AR',
      'role': 'Duty Desk',
      'designation': 'Reception Lead & OPD Dispatcher',
      'empCode': 'REC-0211',
      'status': 'On Duty',
      'statusColor': AppColors.secondaryEmerald,
      'shift': 'Morning Shift (07:30 - 15:30)',
      'location': 'Central Wing Desk 02',
      'verified': false,
    },
    {
      'name': 'Nurse Deepa Menon',
      'initials': 'DM',
      'role': 'On Leave',
      'designation': 'Pediatric Ward Staff Nurse',
      'empCode': 'NUR-4012',
      'status': 'On Leave',
      'statusColor': AppColors.outline,
      'shift': 'Approved Casual Leave',
      'location': 'Returns Tomorrow',
      'verified': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStaff = _staffMembers.where((s) {
      final matchesRole = _selectedRoleFilter == 'All' || s['role'] == _selectedRoleFilter;
      final q = _searchController.text.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          (s['name'] as String).toLowerCase().contains(q) ||
          (s['designation'] as String).toLowerCase().contains(q) ||
          (s['empCode'] as String).toLowerCase().contains(q);
      return matchesRole && matchesQuery;
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
                  // Page Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hospital Staff Directory',
                              style: AppTypography.headlineLgMobile.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'St. Jude Medical Command & Center',
                              style: AppTypography.bodySm.copyWith(color: AppColors.outline),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: const Icon(Icons.view_agenda, color: AppColors.primary, size: 20),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Search Bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search, color: AppColors.tertiary),
                            hintText: 'Search by name, employee code, or ward...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: AppColors.primary),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Active Shift Period Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.schedule, color: AppColors.primaryFixed, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'ACTIVE SHIFT PERIOD',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.primaryFixed,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Ward In-Sync',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.onPrimaryContainer,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Shift: Morning A (08:00 - 16:00)',
                          style: AppTypography.headlineSm.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.secondaryFixed,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '168 Staff Checked In',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.surfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: Colors.white54)),
                            const SizedBox(width: 8),
                            Text(
                              'Capacity: 94.2%',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.surfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Segmented Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Doctors', 'Nurses', 'Duty Desk', 'On Leave'].map((cat) {
                        final isSelected = _selectedRoleFilter == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedRoleFilter = cat),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                                ),
                              ),
                              child: Text(
                                cat == 'All' ? 'All Staff' : cat,
                                style: AppTypography.labelSm.copyWith(
                                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Staff Roster List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredStaff.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final s = filteredStaff[i];
                      final statusColor = s['statusColor'] as Color;

                      return Container(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainerHigh,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            s['initials'] as String,
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    s['name'] as String,
                                                    style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (s['verified'] as bool) ...[
                                                  const SizedBox(width: 4),
                                                  const Icon(Icons.verified, size: 16, color: AppColors.primary),
                                                ],
                                              ],
                                            ),
                                            Text(
                                              s['designation'] as String,
                                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Emp #${s['empCode']}',
                                              style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.outline),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        s['status'] as String,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.meeting_room, size: 16, color: AppColors.primary),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            s['shift'] as String,
                                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    s['location'] as String,
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Duty schedule for ${s['name']}')),
                                      );
                                    },
                                    icon: const Icon(Icons.calendar_month, size: 16),
                                    label: const Text('View Schedule', style: TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.primary),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Direct message sent to ${s['name']}')),
                                      );
                                    },
                                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                    label: const Text('Message', style: TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.borderSubtle),
                                      foregroundColor: AppColors.onSurface,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
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
}
