import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medflow_app/main.dart';

void main() {
  testWidgets('MedFlow App launches and displays core clinical portals', (WidgetTester tester) async {
    // Set a tablet/desktop-friendly screen size for complete rendering
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build MedFlow app
    await tester.pumpWidget(const MedFlowApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Verify MedFlow branding in Top App Bar
    expect(find.text('MedFlow'), findsOneWidget);

    // Verify Default Screen: Doctor Dashboard & OPD Queue
    expect(find.text('Dr. Arvind Sharma'), findsOneWidget);
    expect(find.text('Patient Queue'), findsOneWidget);
    expect(find.text('CURRENT IN CLINIC'), findsOneWidget);
    expect(find.text('Rajesh Gupta'), findsOneWidget);

    // Test Navigation: Tap Reception
    await tester.tap(find.text('Reception'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Physicians on Duty'), findsOneWidget);
    expect(find.text('Quick OPD Registration & Token'), findsOneWidget);

    // Test Navigation: Tap Analytics
    await tester.tap(find.text('Analytics'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Hospital Admin Command'), findsOneWidget);
    expect(find.text('Hourly Check-ins'), findsOneWidget);

    // Test Navigation: Tap Staff
    await tester.tap(find.text('Staff'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Hospital Staff Directory'), findsOneWidget);
    expect(find.text('ACTIVE SHIFT PERIOD'), findsOneWidget);

    // Test Navigation: Tap Alerts
    await tester.tap(find.text('Alerts'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Clinical Notifications'), findsOneWidget);
    expect(find.text('CRITICAL ALERT'), findsWidgets);
  });
}
