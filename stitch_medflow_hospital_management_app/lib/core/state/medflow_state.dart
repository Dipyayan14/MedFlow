import 'package:flutter/material.dart';

enum UserRole {
  receptionist('Receptionist', 'Front Desk & Triage', Icons.badge_outlined),
  doctor('Doctor', 'OPD / IPD Consultations & Orders', Icons.medical_services_outlined),
  nurse('Nurse', 'Ward Monitoring, MAR & Vitals Tracking', Icons.monitor_heart_outlined),
  admin('Hospital Admin', 'Operations, Tariffs & Billing Control', Icons.admin_panel_settings_outlined),
  patient('Patient / Caregiver', 'Linked Health Records & Lab Reports', Icons.family_restroom_outlined);

  final String title;
  final String subtitle;
  final IconData icon;
  const UserRole(this.title, this.subtitle, this.icon);
}

enum DoctorStatus { available, procedure, onBreak }

enum AlertSeverity { critical, warning, info }

class PatientToken {
  final int tokenNumber;
  final String name;
  final int age;
  final String gender;
  final String uhid;
  final String complaint;
  final String? bp;
  final bool hasBpAlert;
  final int? pulse;
  final int? spo2;
  final String waitingLocation;
  final String arrivalTime;
  final bool isInClinic;

  PatientToken({
    required this.tokenNumber,
    required this.name,
    required this.age,
    required this.gender,
    required this.uhid,
    required this.complaint,
    this.bp,
    this.hasBpAlert = false,
    this.pulse,
    this.spo2,
    required this.waitingLocation,
    required this.arrivalTime,
    this.isInClinic = false,
  });

  PatientToken copyWith({bool? isInClinic}) {
    return PatientToken(
      tokenNumber: tokenNumber,
      name: name,
      age: age,
      gender: gender,
      uhid: uhid,
      complaint: complaint,
      bp: bp,
      hasBpAlert: hasBpAlert,
      pulse: pulse,
      spo2: spo2,
      waitingLocation: waitingLocation,
      arrivalTime: arrivalTime,
      isInClinic: isInClinic ?? this.isInClinic,
    );
  }
}

class LoggedInUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? department;

  LoggedInUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.department,
  });

  factory LoggedInUser.fromJson(Map<String, dynamic> json) {
    return LoggedInUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phoneNumber: json['phone_number'],
      department: json['department'],
    );
  }
}

class PhysicianRoster {
  final String id;
  final String name;
  final String specialization;
  final String room;
  final String degrees;
  final int fee;
  final int waitingCount;
  final DoctorStatus status;

  PhysicianRoster({
    required this.id,
    required this.name,
    required this.specialization,
    required this.room,
    required this.degrees,
    required this.fee,
    required this.waitingCount,
    required this.status,
  });

  PhysicianRoster copyWith({DoctorStatus? status, int? waitingCount}) {
    return PhysicianRoster(
      id: id,
      name: name,
      specialization: specialization,
      room: room,
      degrees: degrees,
      fee: fee,
      waitingCount: waitingCount ?? this.waitingCount,
      status: status ?? this.status,
    );
  }
}

class ClinicalAlert {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String timeAgo;
  final AlertSeverity severity;
  final bool isRead;

  ClinicalAlert({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.timeAgo,
    required this.severity,
    this.isRead = false,
  });

  ClinicalAlert copyWith({bool? isRead}) {
    return ClinicalAlert(
      id: id,
      title: title,
      subtitle: subtitle,
      tag: tag,
      timeAgo: timeAgo,
      severity: severity,
      isRead: isRead ?? this.isRead,
    );
  }
}

class MedFlowState extends ChangeNotifier {
    // Currently logged-in user (from backend)
  LoggedInUser? _currentUser;
  LoggedInUser? get currentUser => _currentUser;
  String? _authToken;
  String? get authToken => _authToken;

  void setCurrentUser(LoggedInUser user, String token) {
    _currentUser = user;
    _authToken = token;
    notifyListeners();
  }

  void clearCurrentUser() {
    _currentUser = null;
    _authToken = null;
    notifyListeners();
  }
  // Current Active Role
  UserRole _activeRole = UserRole.doctor;
  UserRole get activeRole => _activeRole;

  void setActiveRole(UserRole role) {
    _activeRole = role;
    notifyListeners();
  }

  // Doctor OPD status
  DoctorStatus _doctorStatus = DoctorStatus.available;
  DoctorStatus get doctorStatus => _doctorStatus;

  void setDoctorStatus(DoctorStatus status) {
    _doctorStatus = status;
    // Also update Dr. Arvind Sharma in physicians roster
    _physicians = _physicians.map((p) {
      if (p.id == 'doc-1') {
        return p.copyWith(status: status);
      }
      return p;
    }).toList();
    notifyListeners();
  }

  // Active Emergency State
  bool _isEmergencyActive = false;
  bool get isEmergencyActive => _isEmergencyActive;

  void triggerEmergency(bool active) {
    _isEmergencyActive = active;
    notifyListeners();
  }

  // Patient Queue
  final List<PatientToken> _queue = [
    PatientToken(
      tokenNumber: 19,
      name: 'Rajesh Gupta',
      age: 52,
      gender: 'Male',
      uhid: 'UHID-90214',
      complaint: 'Chest Discomfort & ECG Review',
      bp: '145 / 95 mmHg',
      hasBpAlert: true,
      pulse: 78,
      spo2: 98,
      waitingLocation: 'Consultation Room 204',
      arrivalTime: '25m ago',
      isInClinic: true,
    ),
    PatientToken(
      tokenNumber: 20,
      name: 'Sunita Verma',
      age: 44,
      gender: 'Female',
      uhid: 'UHID-90215',
      complaint: 'Post Angioplasty Follow-up',
      bp: '128 / 82 mmHg',
      pulse: 74,
      spo2: 98,
      waitingLocation: 'Waiting in Bay 2B',
      arrivalTime: '10m ago',
      isInClinic: false,
    ),
    PatientToken(
      tokenNumber: 21,
      name: 'Amit Malhotra',
      age: 38,
      gender: 'Male',
      uhid: 'UHID-90216',
      complaint: 'Routine Cardiology Review & Lipid Check',
      bp: '120 / 80 mmHg',
      pulse: 72,
      spo2: 99,
      waitingLocation: 'Waiting in Bay 1A',
      arrivalTime: '15m ago',
      isInClinic: false,
    ),
    PatientToken(
      tokenNumber: 22,
      name: 'Priya Mukherjee',
      age: 61,
      gender: 'Female',
      uhid: 'UHID-90217',
      complaint: 'Hypertension Medication Adjustment',
      bp: '138 / 88 mmHg',
      pulse: 80,
      spo2: 97,
      waitingLocation: 'Waiting in Bay 2B',
      arrivalTime: '5m ago',
      isInClinic: false,
    ),
  ];

  List<PatientToken> get queue => List.unmodifiable(_queue);

  PatientToken? get currentInClinic =>
      _queue.cast<PatientToken?>().firstWhere((p) => p?.isInClinic == true, orElse: () => null);

  List<PatientToken> get waitingList =>
      _queue.where((p) => !p.isInClinic).toList();

  int _tokensDoneToday = 18;
  int get tokensDoneToday => _tokensDoneToday;

  void advanceNextToken() {
    final current = currentInClinic;
    if (current != null) {
      _tokensDoneToday++;
      final index = _queue.indexOf(current);
      _queue.removeAt(index);
      if (_queue.isNotEmpty) {
        _queue[0] = _queue[0].copyWith(isInClinic: true);
      }
      notifyListeners();
    }
  }

  void addPatientToken(PatientToken token) {
    _queue.add(token);
    notifyListeners();
  }

  // Physicians Roster for Receptionist
  List<PhysicianRoster> _physicians = [
    PhysicianRoster(
      id: 'doc-1',
      name: 'Dr. Arvind Sharma',
      specialization: 'Cardiology',
      room: 'Room 204',
      degrees: 'MD, DM (Cardiology)',
      fee: 1200,
      waitingCount: 9,
      status: DoctorStatus.available,
    ),
    PhysicianRoster(
      id: 'doc-2',
      name: 'Dr. Priya Nair',
      specialization: 'Pediatrics',
      room: 'Room 102',
      degrees: 'MD (Pediatrics)',
      fee: 800,
      waitingCount: 4,
      status: DoctorStatus.available,
    ),
    PhysicianRoster(
      id: 'doc-3',
      name: 'Dr. Rajesh Khanna',
      specialization: 'Orthopedics',
      room: 'Room 301',
      degrees: 'MS (Ortho), DNB',
      fee: 1000,
      waitingCount: 6,
      status: DoctorStatus.procedure,
    ),
    PhysicianRoster(
      id: 'doc-4',
      name: 'Dr. Meera Desai',
      specialization: 'Dermatology',
      room: 'Room 105',
      degrees: 'MD (Dermatology)',
      fee: 900,
      waitingCount: 2,
      status: DoctorStatus.onBreak,
    ),
    PhysicianRoster(
      id: 'doc-5',
      name: 'Dr. Vikram Seth',
      specialization: 'Neurology',
      room: 'Room 402',
      degrees: 'MD, DM (Neurology)',
      fee: 1500,
      waitingCount: 5,
      status: DoctorStatus.available,
    ),
    PhysicianRoster(
      id: 'doc-6',
      name: 'Dr. Ananya Sen',
      specialization: 'General OPD',
      room: 'Room 101',
      degrees: 'MBBS, DNB (Fam Med)',
      fee: 600,
      waitingCount: 8,
      status: DoctorStatus.available,
    ),
  ];

  List<PhysicianRoster> get physicians => List.unmodifiable(_physicians);

  void issueQuickToken(String physicianId, String patientName) {
    final doc = _physicians.firstWhere((p) => p.id == physicianId);
    final newTokenNum = _queue.isNotEmpty ? _queue.last.tokenNumber + 1 : 23;
    addPatientToken(
      PatientToken(
        tokenNumber: newTokenNum,
        name: patientName,
        age: 35,
        gender: 'Adult',
        uhid: 'UHID-902${newTokenNum + 10}',
        complaint: 'Quick OPD Registration (${doc.specialization})',
        waitingLocation: 'Waiting in Central OPD Lounge',
        arrivalTime: 'Just now',
        isInClinic: false,
      ),
    );
    _physicians = _physicians.map((p) {
      if (p.id == physicianId) {
        return p.copyWith(waitingCount: p.waitingCount + 1);
      }
      return p;
    }).toList();
    notifyListeners();
  }

  // Clinical Alerts Stream
  List<ClinicalAlert> _alerts = [
    ClinicalAlert(
      id: 'alt-1',
      title: 'Dr. K. Mehta (ER Bay 3) requested urgent Cardiac Consult for Bed #12',
      subtitle: 'Troponin-T Positive • UHID: 9811-A',
      tag: 'CRITICAL ALERT',
      timeAgo: '4 mins ago',
      severity: AlertSeverity.critical,
    ),
    ClinicalAlert(
      id: 'alt-2',
      title: 'Dr. Arvind Sharma marked OPD available in Rm 204',
      subtitle: 'Queue capacity: 9 active waiting tokens in bay',
      tag: 'DOCTOR AVAILABLE',
      timeAgo: '12 mins ago',
      severity: AlertSeverity.info,
    ),
    ClinicalAlert(
      id: 'alt-3',
      title: 'High BP Alert on Token #19 (Rajesh Gupta)',
      subtitle: 'Telemetry flagged 145/95 mmHg during nurse pre-check',
      tag: 'QUEUE WARNING',
      timeAgo: '20 mins ago',
      severity: AlertSeverity.warning,
    ),
    ClinicalAlert(
      id: 'alt-4',
      title: 'ICU Telemetry Synced with Central Command',
      subtitle: 'All 24 beds online • St. Jude Pavilion',
      tag: 'SYSTEM SYNC',
      timeAgo: '45 mins ago',
      severity: AlertSeverity.info,
    ),
  ];

  List<ClinicalAlert> get alerts => List.unmodifiable(_alerts);

  int get unreadAlertsCount => _alerts.where((a) => !a.isRead).length;

  void markAllAlertsRead() {
    _alerts = _alerts.map((a) => a.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void dismissAlert(String id) {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}

/// Inherited widget for easy context access without third party dependencies
class MedFlowScope extends InheritedNotifier<MedFlowState> {
  const MedFlowScope({
    super.key,
    required MedFlowState super.notifier,
    required super.child,
  });

  static MedFlowState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MedFlowScope>();
    assert(scope != null, 'No MedFlowScope found in context');
    return scope!.notifier!;
  }
}
