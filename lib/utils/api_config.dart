class ApiConfig {
  // Base API URL - change this to your Laravel API endpoint
  // For local development with an Android emulator:
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  //
  // For local development with an iOS simulator:
  // static const String baseUrl = 'http://localhost:8000/api';
  //
  // For production:
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  
  // User endpoints
  static const String profile = '/user/profile';
  static const String avatar = '/user/avatar';
  static const String progress = '/user/progress';
  static const String password = '/user/password';
  static const String avatars = '/avatars';
  
  // Timeout durations (in milliseconds)
  static const int connectionTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 15000; // 15 seconds
  
  // Avatar upload configuration
  static const bool useBase64ForAvatars = true; // Set to false to use multipart form data
  static const int maxAvatarSizeBytes = 2 * 1024 * 1024; // 2MB
  static const int avatarQuality = 80; // JPEG compression quality (0-100)
  static const int maxAvatarDimension = 512; // Maximum width/height in pixels
  
  // Headers
  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // Full URL helpers
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }
  
  // Storage paths
  static const String avatarStoragePath = 'avatars';

}