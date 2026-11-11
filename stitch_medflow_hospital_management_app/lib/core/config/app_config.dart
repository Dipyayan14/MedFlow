/// Central configuration for MedFlow application.
class AppConfig {
  /// Base API URL for backend services.
  /// 
  /// Configuration options:
  /// - Windows Desktop / Web: 'http://localhost:8000/api'
  /// - Android Emulator: 'http://10.0.2.2:8000/api'
  /// - Physical Android / iOS devices: `http://<YOUR_LOCAL_IP>:8000/api` (e.g. 'http://192.168.1.100:8000/api')
  static const String apiBaseUrl = 'http://localhost:8000/api';
}
