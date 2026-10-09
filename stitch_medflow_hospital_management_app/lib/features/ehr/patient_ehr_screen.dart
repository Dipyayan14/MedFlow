import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme.dart';

class PatientEhrScreen extends StatefulWidget {
  const PatientEhrScreen({super.key});

  @override
  State<PatientEhrScreen> createState() => _PatientEhrScreenState();
}

class _PatientEhrScreenState extends State<PatientEhrScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              'ELECTRONIC HEALTH RECORD',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Patient Clinical Dossier',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Patient Master Header Card
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryFixed,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppColors.outlineVariant),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'RG',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 13,
                                        height: 13,
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryEmerald,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Rajesh Gupta',
                                          style: AppTypography.headlineSm.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceContainer,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '52y Male',
                                            style: AppTypography.labelSm.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'UHID: MF-DEL-2024-8921',
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.tertiary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      'Health ID: 91-8273-1092-2341',
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.tertiary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Quick Contact Actions: Share & Call
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.share, size: 18, color: AppColors.secondaryEmerald),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.surfaceContainerLow,
                                    padding: const EdgeInsets.all(8),
                                  ),
                                  tooltip: 'Share on WhatsApp',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('EHR Records exported to registered WhatsApp')),
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.call, size: 18, color: Colors.white),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.all(8),
                                  ),
                                  tooltip: 'Call Patient',
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        const Divider(height: 1, color: AppColors.borderSubtle),
                        const SizedBox(height: 12),

                        // Clinical Flags & Allergies Pill Row
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildPillBadge(
                              icon: Icons.bloodtype,
                              iconColor: AppColors.errorCrimson,
                              label: 'O+ve',
                              bg: AppColors.surfaceContainer,
                            ),
                            _buildPillBadge(
                              icon: Icons.warning,
                              iconColor: AppColors.errorCrimson,
                              label: 'Penicillin (Severe)',
                              bg: AppColors.errorContainer,
                              textColor: AppColors.onErrorContainer,
                            ),
                            _buildPillBadge(
                              icon: Icons.circle,
                              iconColor: AppColors.primary,
                              label: 'Diabetic (Type 2)',
                              bg: AppColors.surfaceContainerHigh,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Live Triage Vitals Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Live Triage Vitals',
                        style: AppTypography.labelMd.copyWith(color: AppColors.tertiary),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppColors.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            '14m ago by Nurse Sunita',
                            style: AppTypography.bodySm.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      // BP Card
                      Expanded(
                        child: _buildVitalCard(
                          title: 'BP',
                          value: '142/90',
                          unit: 'mmHg',
                          status: 'Borderline',
                          isAlert: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Pulse Card
                      Expanded(
                        child: _buildVitalCard(
                          title: 'PULSE',
                          value: '78',
                          unit: 'bpm',
                          status: 'Normal',
                          icon: Icons.favorite,
                          iconColor: AppColors.secondaryEmerald,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // SpO2 Card
                      Expanded(
                        child: _buildVitalCard(
                          title: 'SPO2',
                          value: '98%',
                          unit: 'Room air',
                          status: 'Optimal',
                          icon: Icons.air,
                          iconColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Longitudinal Clinical Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.onSurfaceVariant,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Encounters'),
                        Tab(text: 'Medications'),
                        Tab(text: 'Labs & ECG'),
                        Tab(text: 'Clinical Notes'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tab Content Container
                  SizedBox(
                    height: 380,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEncountersTab(),
                        _buildMedicationsTab(),
                        _buildLabsTab(),
                        _buildNotesTab(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Action Dock
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Doctor clinical note dialog opened')),
                            );
                          },
                          icon: const Icon(Icons.note_add, size: 16),
                          label: const Text('Add Note'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.primary,
                                content: Text('Rx prescription written to patient record'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.medication, size: 16),
                          label: const Text('Prescribe Rx'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillBadge({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color bg,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: textColor ?? AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard({
    required String title,
    required String value,
    required String unit,
    required String status,
    IconData? icon,
    Color? iconColor,
    bool isAlert = false,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.labelSm.copyWith(color: AppColors.tertiary),
              ),
              if (icon != null)
                Icon(icon, size: 14, color: iconColor)
              else if (isAlert)
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.errorCrimson,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.labelLg.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: AppTypography.bodySm.copyWith(fontSize: 9),
              ),
            ],
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isAlert ? AppColors.errorCrimson : AppColors.secondaryEmerald,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncountersTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        _buildEncounterCard(
          date: 'Today, 21 Oct 2024',
          doctor: 'Dr. Arvind Sharma (Cardiology OPD)',
          diagnosis: 'Acute angina evaluation • Borderline systolic BP',
          type: 'OPD Encounter',
        ),
        const SizedBox(height: 8),
        _buildEncounterCard(
          date: '14 Aug 2024',
          doctor: 'Dr. Priya Nair (Internal Medicine)',
          diagnosis: 'Type 2 Diabetes routine follow-up • HbA1c 6.8%',
          type: 'Review Visit',
        ),
        const SizedBox(height: 8),
        _buildEncounterCard(
          date: '02 Mar 2024',
          doctor: 'Dr. Arvind Sharma (Cath Lab)',
          diagnosis: 'Post-Angioplasty Stent Patency Evaluation • Stable',
          type: 'IPD Procedure',
        ),
      ],
    );
  }

  Widget _buildEncounterCard({
    required String date,
    required String doctor,
    required String diagnosis,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(type, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(doctor, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(diagnosis, style: AppTypography.bodySm.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMedicationsTab() {
    final meds = [
      {'name': 'Atorvastatin 20mg', 'dose': '1 Tablet at bedtime', 'tag': 'Lipid Control', 'active': true},
      {'name': 'Metformin 500mg', 'dose': '1 Tablet twice daily with meals', 'tag': 'Diabetes', 'active': true},
      {'name': 'Telmisartan 40mg', 'dose': '1 Tablet morning', 'tag': 'Hypertension', 'active': true},
      {'name': 'Aspirin 75mg (Disprin)', 'dose': '1 Tablet post lunch', 'tag': 'Cardio Protective', 'active': true},
    ];

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: meds.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final m = meds[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m['name'] as String, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700)),
                  Text(m['dose'] as String, style: AppTypography.bodySm.copyWith(fontSize: 11)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  m['tag'] as String,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabsTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        _buildLabItem('12-Lead Electrocardiogram (ECG)', '21 Oct 2024 • Sinus rhythm, mild T-wave inversion in V4-V6', 'Review Needed', true),
        const SizedBox(height: 8),
        _buildLabItem('Comprehensive Lipid Profile', '18 Oct 2024 • Total Cholesterol: 182 mg/dL • LDL: 104 mg/dL', 'Normal Range', false),
        const SizedBox(height: 8),
        _buildLabItem('HbA1c Glycated Hemoglobin', '14 Aug 2024 • Result: 6.8% (Good Glycemic Control)', 'Normal', false),
        const SizedBox(height: 8),
        _buildLabItem('Serum Creatinine & eGFR', '14 Aug 2024 • Creatinine: 0.9 mg/dL • eGFR: > 90', 'Optimal', false),
      ],
    );
  }

  Widget _buildLabItem(String title, String result, String status, bool isAlert) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isAlert ? AppColors.badgeRedBg : AppColors.badgeEmeraldBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isAlert ? AppColors.badgeRedText : AppColors.badgeEmeraldText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(result, style: AppTypography.bodySm.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dr. Arvind Sharma (Attending)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('21 Oct 10:35 AM', style: AppTypography.bodySm.copyWith(fontSize: 10)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Patient presents with mild retrosternal tightening on brisk walking. No radiation to jaw or left arm. Advised serial ECG and continuation of Telmisartan 40mg. Follow-up after 2 weeks with repeat lipid check.',
                style: AppTypography.bodySm.copyWith(fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
