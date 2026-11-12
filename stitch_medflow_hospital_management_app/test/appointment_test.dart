import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medflow_app/core/state/medflow_state.dart';
import 'package:medflow_app/core/theme/app_theme.dart';
import 'package:medflow_app/features/booking/models/appointment.dart';
import 'package:medflow_app/features/booking/appointment_wizard_screen.dart';
import 'package:medflow_app/features/doctor/doctor_dashboard_screen.dart';
import 'package:medflow_app/features/receptionist/receptionist_dashboard_screen.dart';

void main() {
  group('Appointment Model Tests', () {
    test('Appointment fromJson parses valid payload correctly', () {
      final json = {
        'id': 101,
        'patient_id': 12,
        'doctor_id': 4,
        'scheduled_at': '2026-11-12T10:30:00.000000Z',
        'status': 'checked_in',
        'token_number': 3,
        'reason': 'Cardiology follow-up',
        'notes': null,
        'created_by': 2,
        'patient': {
          'id': 12,
          'mrn': 'MRN-2026-0012',
          'first_name': 'Sunita',
          'last_name': 'Verma',
          'phone': '+919876543210',
          'gender': 'female',
          'date_of_birth': '1980-05-15',
        },
        'doctor': {
          'id': 4,
          'name': 'Dr. Arvind Sharma',
          'department': 'Cardiology',
          'specialization': 'Cardiologist',
        },
      };

      final appointment = Appointment.fromJson(json);

      expect(appointment.id, 101);
      expect(appointment.patientId, 12);
      expect(appointment.doctorId, 4);
      expect(appointment.tokenNumber, 3);
      expect(appointment.status, 'checked_in');
      expect(appointment.isCheckedIn, true);
      expect(appointment.isInConsultation, false);
      expect(appointment.patientName, 'Sunita Verma');
      expect(appointment.patientMrn, 'MRN-2026-0012');
      expect(appointment.doctorDisplayName, 'Dr. Arvind Sharma');
    });

    test('OpdQueueData fromJson parses queue items and counts', () {
      final json = {
        'date': '2026-11-12',
        'doctor_id': 4,
        'total': 2,
        'counts': {
          'in_consultation': 1,
          'waiting': 1,
          'scheduled': 0,
          'completed': 0,
        },
        'data': [
          {
            'id': 1,
            'patient_id': 5,
            'doctor_id': 4,
            'scheduled_at': '2026-11-12T09:00:00.000000Z',
            'status': 'in_consultation',
            'token_number': 1,
          },
          {
            'id': 2,
            'patient_id': 6,
            'doctor_id': 4,
            'scheduled_at': '2026-11-12T09:30:00.000000Z',
            'status': 'checked_in',
            'token_number': 2,
          },
        ],
      };

      final opd = OpdQueueData.fromJson(json);

      expect(opd.date, '2026-11-12');
      expect(opd.total, 2);
      expect(opd.counts['in_consultation'], 1);
      expect(opd.counts['waiting'], 1);
      expect(opd.queue.length, 2);
      expect(opd.queue[0].isInConsultation, true);
      expect(opd.queue[1].isCheckedIn, true);
    });
  });

  group('Appointment UI Widget Tests', () {
    testWidgets('DoctorDashboardScreen displays OPD Queue header and initial state', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final state = MedFlowState();
      state.setCurrentUser(
        LoggedInUser(id: 4, name: 'Dr. Arvind Sharma', email: 'doctor@medflow.local', role: 'doctor'),
        'dummy_token',
      );

      await tester.pumpWidget(
        MedFlowScope(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: DoctorDashboardScreen(
              onOpenEhr: () {},
              onOpenNotifications: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('OPD Queue'), findsOneWidget);
      expect(find.text('Call Next'), findsOneWidget);
    });

    testWidgets('AppointmentWizardScreen displays booking portal title and date picker', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final state = MedFlowState();
      state.setCurrentUser(
        LoggedInUser(id: 2, name: 'Duty Desk', email: 'desk@medflow.local', role: 'duty_desk'),
        'dummy_token',
      );

      await tester.pumpWidget(
        MedFlowScope(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: AppointmentWizardScreen(
              onBookingComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('OPD BOOKING'), findsOneWidget);
      expect(find.text('Schedule Appointment'), findsOneWidget);
      expect(find.text('Select Appointment Date'), findsOneWidget);
      expect(find.text('Confirm & Book Appointment'), findsOneWidget);
    });

    testWidgets('Nurse role sees OPD queue and does NOT see Book Slot or Issue Token button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final state = MedFlowState();
      state.setCurrentUser(
        LoggedInUser(id: 3, name: 'Nurse Joy', email: 'nurse@medflow.local', role: 'nurse'),
        'dummy_token',
      );

      await tester.pumpWidget(
        MedFlowScope(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: ReceptionistDashboardScreen(
              onBookAppointment: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Nurse triage station text
      expect(find.text('Nursing Station & Live OPD Queue'), findsOneWidget);

      // Verify Today's OPD Queue is visible
      expect(find.text("Today's OPD Queue & Tokens"), findsOneWidget);

      // Verify Nurse CANNOT see Book Slot or Issue Token
      expect(find.text('Book Slot'), findsNothing);
      expect(find.text('Issue Token'), findsNothing);
    });

    testWidgets('Duty desk role sees Book Slot and Reception triage header', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final state = MedFlowState();
      state.setCurrentUser(
        LoggedInUser(id: 2, name: 'Duty Desk', email: 'desk@medflow.local', role: 'duty_desk'),
        'dummy_token',
      );

      await tester.pumpWidget(
        MedFlowScope(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: ReceptionistDashboardScreen(
              onBookAppointment: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Reception triage text
      expect(find.text('Central Wing Reception & Triage'), findsOneWidget);

      // Verify Duty Desk CAN see Book Slot
      expect(find.text('Book Slot'), findsOneWidget);
    });
  });
}

