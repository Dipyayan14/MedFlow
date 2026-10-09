import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/state/medflow_state.dart';
import '../../core/widgets/medflow_top_app_bar.dart';
import '../doctor/doctor_dashboard_screen.dart';
import '../receptionist/receptionist_dashboard_screen.dart';
import '../admin/admin_analytics_screen.dart';
import '../staff/staff_directory_screen.dart';
import '../notifications/notifications_center_screen.dart';
import '../booking/appointment_wizard_screen.dart';
import '../ehr/patient_ehr_screen.dart';
import '../auth/role_selector_screen.dart';
import '../auth/register_screen.dart';
import '../auth/forgot_password_screen.dart';
import '../../services/api_service.dart';

class MedFlowNavigationShell extends StatefulWidget {
  const MedFlowNavigationShell({super.key});

  @override
  State<MedFlowNavigationShell> createState() => _MedFlowNavigationShellState();
}

class _MedFlowNavigationShellState extends State<MedFlowNavigationShell> {
  int _currentIndex = 0;
  bool _showAuthScreen = true;
  bool _showRegisterScreen = false;
  bool _showForgotPasswordScreen = false;

  List<int> _allowedTabs(String? role) {
    switch (role) {
      case 'admin':
        return [0, 1, 2, 3, 4];
      case 'doctor':
        return [0, 3, 4];
      case 'duty_desk':
        return [1, 3, 4];
      case 'nurse':
      case 'staff':
      default:
        return [3, 4];
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = MedFlowScope.of(context);

    if (_showAuthScreen) {
      if (_showRegisterScreen) {
        return RegisterScreen(
          onRegisterSuccess: () {
            setState(() {
              _showAuthScreen = false;
              _showRegisterScreen = false;
              final backendRole = state.currentUser?.role;
              switch (backendRole) {
                case 'doctor':
                  state.setActiveRole(UserRole.doctor);
                  _currentIndex = 0;
                  break;
                case 'duty_desk':
                  state.setActiveRole(UserRole.receptionist);
                  _currentIndex = 1;
                  break;
                case 'admin':
                  state.setActiveRole(UserRole.admin);
                  _currentIndex = 2;
                  break;
                case 'nurse':
                  state.setActiveRole(UserRole.nurse);
                  _currentIndex = 3;
                  break;
                case 'staff':
                default:
                  state.setActiveRole(UserRole.receptionist);
                  _currentIndex = 3;
                  break;
              }
            });
          },
          onNavigateToLogin: () {
            setState(() => _showRegisterScreen = false);
          },
        );
      }

      if (_showForgotPasswordScreen) {
        return ForgotPasswordScreen(
          onNavigateToLogin: () {
            setState(() => _showForgotPasswordScreen = false);
          },
          onResetSuccess: () {
            setState(() {
              _showForgotPasswordScreen = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset successfully! Please log in with your new password.'),
                backgroundColor: AppColors.secondaryEmerald,
              ),
            );
          },
        );
      }

      return RoleSelectorScreen(
        onLoginSuccess: () {
          setState(() {
            _showAuthScreen = false;
            // Switch current tab based on the REAL backend role, not the tapped card
            final backendRole = state.currentUser?.role;
            switch (backendRole) {
              case 'doctor':
                state.setActiveRole(UserRole.doctor);
                _currentIndex = 0;
                break;
              case 'duty_desk':
                state.setActiveRole(UserRole.receptionist);
                _currentIndex = 1;
                break;
              case 'admin':
                state.setActiveRole(UserRole.admin);
                _currentIndex = 2;
                break;
              case 'nurse':
                state.setActiveRole(UserRole.nurse);
                _currentIndex = 3;
                break;
              case 'staff':
              default:
                state.setActiveRole(UserRole.receptionist);
                _currentIndex = 3;
                break;
            }
          });
        },
        onNavigateToRegister: () {
          setState(() => _showRegisterScreen = true);
        },
        onNavigateToForgotPassword: () {
          setState(() => _showForgotPasswordScreen = true);
        },
      );
    }

    final allowedTabs = _allowedTabs(state.currentUser?.role);
    final safeIndex = allowedTabs.contains(_currentIndex) ? _currentIndex : allowedTabs.first;

    final pages = [
      DoctorDashboardScreen(
        onOpenEhr: _navigateToEhr,
        onOpenNotifications: () => setState(() => _currentIndex = 4),
      ),
      ReceptionistDashboardScreen(
        onBookAppointment: _navigateToBookingWizard,
      ),
      const AdminAnalyticsScreen(),
      const StaffDirectoryScreen(),
      NotificationsCenterScreen(
        onOpenQueue: () => setState(() => _currentIndex = 0),
      ),
    ];

    NavigationDestination buildDestination(int tabIndex) {
      switch (tabIndex) {
        case 0:
          return const NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            label: 'OPD Queue',
          );
        case 1:
          return const NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            label: 'Reception',
          );
        case 2:
          return const NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          );
        case 3:
          return const NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Staff',
          );
        case 4:
        default:
          return NavigationDestination(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (state.unreadAlertsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.errorCrimson,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Alerts',
          );
      }
    }

    return Scaffold(
      appBar: MedFlowTopAppBar(
        onNotificationsTap: () => setState(() => _currentIndex = 4),
        onRoleTap: _showRoleSwitchSheet,
      ),
      body: IndexedStack(
        index: safeIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: NavigationBar(
          selectedIndex: allowedTabs.indexOf(safeIndex),
          onDestinationSelected: (idx) => setState(() => _currentIndex = allowedTabs[idx]),
          backgroundColor: AppColors.surfaceContainerLowest,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          destinations: allowedTabs.map((tab) => buildDestination(tab)).toList(),
        ),
      ),
    );
  }

  void _navigateToEhr() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PatientEhrScreen()),
    );
  }

  void _navigateToBookingWizard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppointmentWizardScreen(
          onBookingComplete: () {
            setState(() => _currentIndex = 0);
          },
        ),
      ),
    );
  }

  void _showRoleSwitchSheet() {
    final state = MedFlowScope.of(context);
    final userName = state.currentUser?.name ?? 'User';
    final userRole = (state.currentUser?.role ?? 'User').replaceAll('_', ' ');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userRole,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final token = state.authToken;
                    if (token != null) {
                      await ApiService.logout(token: token);
                    }
                    state.clearCurrentUser();
                    setState(() => _showAuthScreen = true);
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorCrimson.withValues(alpha: 0.1),
                    foregroundColor: AppColors.errorCrimson,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}