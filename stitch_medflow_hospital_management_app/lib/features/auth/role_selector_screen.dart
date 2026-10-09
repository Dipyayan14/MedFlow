import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme.dart';
import '../../core/state/medflow_state.dart';
import '../../services/api_service.dart';
import '../../services/biometric_service.dart';

class RoleSelectorScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onNavigateToRegister;
  final VoidCallback onNavigateToForgotPassword;

  const RoleSelectorScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onNavigateToRegister,
    required this.onNavigateToForgotPassword,
  });

  @override
  State<RoleSelectorScreen> createState() => _RoleSelectorScreenState();
}

class _RoleSelectorScreenState extends State<RoleSelectorScreen> {
  bool _isPhoneMode = true;
  bool _isLoading = false;
  final TextEditingController _phoneController = TextEditingController(text: '98765 43210');
  final TextEditingController _staffIdController = TextEditingController(text: 'DOC-ARV-204');
  final TextEditingController _otpController = TextEditingController(text: '729401');
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _staffIdController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

    Future<void> _handleBiometricLogin() async {
    final state = MedFlowScope.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (!await BiometricService.isAvailable()) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Set up Windows Hello on this device to use quick unlock'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final token = await BiometricService.readToken();
    if (token == null) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Log in with your password once to enable quick unlock'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final verified = await BiometricService.authenticate();
    if (!verified) return;

    final result = await ApiService.biometricLogin(biometricToken: token);
    if (!mounted) return;

    if (result == null || result['token'] == null) {
      await BiometricService.clearSession();
      messenger.showSnackBar(const SnackBar(
        content: Text("Couldn't verify your session. Log in with your password."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    state.setCurrentUser(LoggedInUser.fromJson(result['user']), result['token']);
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final state = MedFlowScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Brand & Network Node Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/icon/app_icon.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'MedFlow',
                                      style: AppTypography.headlineSm.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Hospital Management System',
                                  style: AppTypography.bodySm.copyWith(
                                    fontSize: 11,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Care Node Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                          ),
                          child: Row(
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Demo Hospital',
                                    style: AppTypography.labelSm.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    'Main Campus',
                                    style: AppTypography.bodySm.copyWith(
                                      fontSize: 9,
                                      color: AppColors.tertiary,
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

                  // Welcome Headline Banner
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user, color: AppColors.onSecondaryContainer, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Secure staff access',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.onSecondaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Clinical Access Portal',
                        style: AppTypography.headlineLgMobile.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select your authorized deployment role to proceed with verified session tokens.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Role Selection Bento Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SELECT ROLE (5 TIERS)',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.tertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Duty Matrix',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 2x2 Bento Cards for roles
                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleCard(
                          context: context,
                          role: UserRole.receptionist,
                          isSelected: state.activeRole == UserRole.receptionist,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildRoleCard(
                          context: context,
                          role: UserRole.doctor,
                          isSelected: state.activeRole == UserRole.doctor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleCard(
                          context: context,
                          role: UserRole.nurse,
                          isSelected: state.activeRole == UserRole.nurse,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildRoleCard(
                          context: context,
                          role: UserRole.admin,
                          isSelected: state.activeRole == UserRole.admin,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Role 5: Patient (Full width)
                  _buildRoleCard(
                    context: context,
                    role: UserRole.patient,
                    isSelected: state.activeRole == UserRole.patient,
                    isFullWidth: true,
                  ),

                  const SizedBox(height: 12),

                  // Dynamic Context Alert
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTypography.bodySm.copyWith(color: AppColors.primary),
                              children: [
                                TextSpan(
                                  text: '${state.activeRole.title}: ',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(text: state.activeRole.subtitle),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Authentication Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Auth Mode Toggle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isPhoneMode = true),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _isPhoneMode ? AppColors.surfaceContainerLowest : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: _isPhoneMode ? AppTheme.cardShadow : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.smartphone,
                                          size: 16,
                                          color: _isPhoneMode ? AppColors.primary : AppColors.tertiary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Mobile OTP',
                                          style: AppTypography.labelMd.copyWith(
                                            color: _isPhoneMode ? AppColors.primary : AppColors.tertiary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isPhoneMode = false),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: !_isPhoneMode ? AppColors.surfaceContainerLowest : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: !_isPhoneMode ? AppTheme.cardShadow : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.badge_outlined,
                                          size: 16,
                                          color: !_isPhoneMode ? AppColors.primary : AppColors.tertiary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Staff ID Lookup',
                                          style: AppTypography.labelMd.copyWith(
                                            color: !_isPhoneMode ? AppColors.primary : AppColors.tertiary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (_isPhoneMode) ...[
                          Text(
                            'ENTER REGISTERED MOBILE NUMBER',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.tertiary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              // +91 India Code Pill
                              Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                  border: Border.all(color: AppColors.outlineVariant),
                                ),
                                child: Row(
                                  children: [
                                    // Mini India Flag
                                    Container(
                                      width: 18,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        border: Border.all(color: Colors.black12),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(child: Container(color: const Color(0xFFFF9933))),
                                          Expanded(child: Container(color: Colors.white)),
                                          Expanded(child: Container(color: const Color(0xFF128807))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '+91',
                                      style: AppTypography.labelMd.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: 'Enter 10-digit number',
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                                      borderSide: BorderSide(color: AppColors.outlineVariant),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.send_rounded, size: 18, color: AppColors.primary),
                                      tooltip: 'Resend OTP',
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('OTP sent to registered mobile')),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // 6-digit OTP Box
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'SESSION TOKEN (OTP)',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.tertiary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Auto-filled: 729401',
                                style: AppTypography.bodySm.copyWith(
                                  fontSize: 11,
                                  color: AppColors.secondaryEmerald,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              final char = index < _otpController.text.length ? _otpController.text[index] : '';
                              return Container(
                                width: 44,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: char.isNotEmpty ? AppColors.primary : AppColors.outlineVariant,
                                    width: char.isNotEmpty ? 2 : 1,
                                  ),
                                ),
                                child: Text(
                                  char,
                                  style: AppTypography.headlineSm.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ] else ...[
                          Text(
                            'STAFF EMPLOYEE CODE',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.tertiary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _staffIdController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.badge_outlined, size: 20, color: AppColors.primary),
                              hintText: 'e.g. DOC-ARV-204 or REC-DEL-02',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'SECURITY PIN / PASSWORD',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.tertiary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline, size: 20, color: AppColors.primary),
                              hintText: '••••••••',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: widget.onNavigateToForgotPassword,
                              child: Text(
                                'Forgot Password?',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // Login CTA Button
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() => _isLoading = true);

                                  final result = await ApiService.login(
                                    email: _staffIdController.text.trim(),
                                    password: _passwordController.text,
                                  );

                                  setState(() => _isLoading = false);

                                  if (result['token'] != null) {
                                    final user = LoggedInUser.fromJson(result['user']);
                                    state.setCurrentUser(user, result['token']);
                                    final devicePass = await ApiService.enableBiometric(token: result['token']);
                                    if (devicePass != null) {
                                      await BiometricService.saveSession(devicePass);
                                    }
                                    widget.onLoginSuccess();
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result['message'] ?? 'Login failed'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Verify Session & Enter Portal',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                        ),
                        
                        const SizedBox(height: 12),

                        // Biometric Quick Unlock button
                         OutlinedButton(
                          onPressed: _handleBiometricLogin,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderSubtle),
                            backgroundColor: AppColors.surfaceContainerLow,
                            foregroundColor: AppColors.onSurface,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.fingerprint, size: 20, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Quick Biometric Unlock',
                                style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Sign Up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.onNavigateToRegister,
                              child: Text(
                                'Sign Up',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Footer Security Notice
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, size: 12, color: AppColors.outline),
                        const SizedBox(width: 4),
                        Text(
                          'Encrypted connection • Secure staff portal',
                          style: AppTypography.bodySm.copyWith(fontSize: 10, color: AppColors.outline),
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

  Widget _buildRoleCard({
    required BuildContext context,
    required UserRole role,
    required bool isSelected,
    bool isFullWidth = false,
  }) {
    final state = MedFlowScope.of(context);

    return InkWell(
      onTap: () {
        state.setActiveRole(role);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.cardShadow : null,
        ),
        child: isFullWidth
            ? Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      role.icon,
                      color: isSelected ? Colors.white : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role.title,
                          style: AppTypography.labelMd.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          role.subtitle,
                          style: AppTypography.bodySm.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          role.icon,
                          color: isSelected ? Colors.white : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    role.title,
                    style: AppTypography.labelMd.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    role.subtitle,
                    style: AppTypography.bodySm.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }
}