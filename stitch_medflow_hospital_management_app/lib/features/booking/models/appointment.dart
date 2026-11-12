import '../../patients/models/patient.dart';

class DoctorInfo {
  final int id;
  final String name;
  final String? department;
  final String? specialization;

  DoctorInfo({
    required this.id,
    required this.name,
    this.department,
    this.specialization,
  });

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      id: json['id'],
      name: json['name'] ?? '',
      department: json['department'],
      specialization: json['specialization'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'department': department,
        'specialization': specialization,
      };
}

class Appointment {
  final int id;
  final int patientId;
  final int doctorId;
  final DateTime scheduledAt;
  final String status;
  final int? tokenNumber;
  final String? reason;
  final String? notes;
  final int? createdBy;
  final Patient? patient;
  final DoctorInfo? doctor;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.scheduledAt,
    required this.status,
    this.tokenNumber,
    this.reason,
    this.notes,
    this.createdBy,
    this.patient,
    this.doctor,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      status: json['status'] ?? 'scheduled',
      tokenNumber: json['token_number'],
      reason: json['reason'],
      notes: json['notes'],
      createdBy: json['created_by'],
      patient: json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      doctor: json['doctor'] != null ? DoctorInfo.fromJson(json['doctor']) : null,
    );
  }

  String get patientName => patient?.name ?? 'Patient #$patientId';
  String get patientMrn => patient?.mrn ?? 'MRN-$patientId';
  int get patientAge => patient?.calculatedAge ?? 0;
  String get patientGender => patient?.gender ?? 'Unknown';
  String get doctorDisplayName => doctor?.name ?? 'Doctor #$doctorId';

  bool get isInConsultation => status == 'in_consultation';
  bool get isCheckedIn => status == 'checked_in';
  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}

class OpdQueueData {
  final String date;
  final int? doctorId;
  final int total;
  final Map<String, int> counts;
  final List<Appointment> queue;

  OpdQueueData({
    required this.date,
    this.doctorId,
    required this.total,
    required this.counts,
    required this.queue,
  });

  factory OpdQueueData.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>?)
            ?.map((e) => Appointment.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final countsRaw = json['counts'] as Map<String, dynamic>? ?? {};
    final counts = countsRaw.map((k, v) => MapEntry(k, v is int ? v : 0));

    return OpdQueueData(
      date: json['date'] ?? '',
      doctorId: json['doctor_id'],
      total: json['total'] ?? list.length,
      counts: counts,
      queue: list,
    );
  }
}

