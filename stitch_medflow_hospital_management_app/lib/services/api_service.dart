import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../features/patients/models/patient.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Log in an existing staff member
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  // Sign up a new staff member
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? phoneNumber,
    String? employeeId,
    String? department,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
        'phone_number': phoneNumber,
        'employee_id': employeeId,
        'department': department,
      }),
    );

    return jsonDecode(response.body);
  }
    // Step 1: Request a password reset OTP
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'email': email,
      }),
    );

    return jsonDecode(response.body);
  }

  // Step 2: Verify the OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    return jsonDecode(response.body);
  }

  // Step 3: Reset the password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    return jsonDecode(response.body);
  }
    // Log out - invalidate the current token on the backend
  static Future<Map<String, dynamic>> logout({
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }
    // Check that a saved token is still valid and fetch the user
  static Future<Map<String, dynamic>?> getCurrentUser({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Enable biometric login and get a device pass (biometric_token)
  static Future<String?> enableBiometric({required String token}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/biometric/enable'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['biometric_token'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Authenticate using the saved biometric device pass
  static Future<Map<String, dynamic>?> biometricLogin({
    required String biometricToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/biometric/login'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $biometricToken',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // --- Patient Management ---

  static Future<PaginatedPatients> getPatients({
    required String token,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final uri = Uri.parse('$baseUrl/patients').replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PaginatedPatients.fromJson(data);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to load patients (${response.statusCode})');
    }
  }

  static Future<Patient> getPatient({
    required String token,
    required int id,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patients/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Patient.fromJson(data['patient']);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to load patient (${response.statusCode})');
    }
  }

  static Future<Patient> createPatient({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patients'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final res = jsonDecode(response.body) as Map<String, dynamic>;
      return Patient.fromJson(res['patient']);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to create patient (${response.statusCode})');
    }
  }

  static Future<Patient> updatePatient({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/patients/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body) as Map<String, dynamic>;
      return Patient.fromJson(res['patient']);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to update patient (${response.statusCode})');
    }
  }

  static Future<void> deletePatient({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/patients/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to delete patient (${response.statusCode})');
    }
  }
}