class Patient {
  final int id;
  final String mrn;
  final String firstName;
  final String lastName;
  final String name;
  final String dateOfBirth;
  final String gender;
  final String phone;
  final String address;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String? bloodGroup;
  final int? createdBy;
  final String? creatorName;
  final String? creatorRole;
  final String? createdAt;

  Patient({
    required this.id,
    required this.mrn,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.phone,
    required this.address,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    this.bloodGroup,
    this.createdBy,
    this.creatorName,
    this.creatorRole,
    this.createdAt,
  });

  int get calculatedAge {
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age > 0 ? age : 0;
    } catch (_) {
      return 0;
    }
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'] as Map<String, dynamic>?;

    return Patient(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      mrn: json['mrn'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      name: json['name'] ?? '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? 'other',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      emergencyContactName: json['emergency_contact_name'] ?? '',
      emergencyContactPhone: json['emergency_contact_phone'] ?? '',
      bloodGroup: json['blood_group'],
      createdBy: json['created_by'] is int ? json['created_by'] : int.tryParse('${json['created_by']}'),
      creatorName: creator?['name'],
      creatorRole: creator?['role'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mrn': mrn,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'phone': phone,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      if (bloodGroup != null) 'blood_group': bloodGroup,
    };
  }
}

class PaginatedPatients {
  final List<Patient> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  PaginatedPatients({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  factory PaginatedPatients.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>?) ?? [];
    return PaginatedPatients(
      data: list.map((item) => Patient.fromJson(item as Map<String, dynamic>)).toList(),
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 15,
    );
  }
}

