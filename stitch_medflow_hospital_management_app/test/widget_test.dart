import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medflow_app/core/state/medflow_state.dart';
import 'package:medflow_app/core/theme/app_theme.dart';
import 'package:medflow_app/features/patients/screens/patients_list_screen.dart';

void main() {
  testWidgets('PatientsListScreen renders search bar and directory header', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final state = MedFlowState();
    state.setCurrentUser(
      LoggedInUser(id: 1, name: 'Admin User', email: 'admin@medflow.local', role: 'admin'),
      'dummy_token',
    );

    await tester.pumpWidget(
      MedFlowScope(
        notifier: state,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PatientsListScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Patients Directory Header
    expect(find.text('Patients Directory'), findsOneWidget);

    // Verify Search Bar
    expect(find.byType(TextField), findsOneWidget);

    // Verify Register Patient FAB for admin role
    expect(find.text('Register Patient'), findsOneWidget);
  });
}
