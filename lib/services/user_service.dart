import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_config.dart';
import 'package:flutter/foundation.dart';
import 'file_avatar_service.dart';

class User {
  final String username;
  final String avatar;
  final int level;
  final int score;

  User({
    required this.username,
    this.avatar = 'assets/avatars/default.png',
    this.level = 1,
    this.score = 0,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'avatar': avatar,
    'level': level,
    'score': score,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    username: json['username'] ?? '',
    avatar: json['avatar'] ?? 'assets/avatars/default.png',
    level: json['level'] ?? 1,
    score: json['score'] ?? 0,
  );
}

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  User? _currentUser;
  String? _token;
  
  // Create a reference to the FileAvatarService
  final FileAvatarService _fileAvatarService = FileAvatarService();

  List<String> availableAvatars = [];
  String defaultAvatar = 'assets/avatars/default.png';

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null && _token != null;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('currentUser');
    final token = prefs.getString('authToken');

    if (userData != null && token != null) {
      try {
        _currentUser = User.fromJson(json.decode(userData));
        _token = token;
        final isValid = await _verifyToken();
        if (!isValid) await logout();
      } catch (e) {
        debugPrint('Error parsing user data: $e');
        await prefs.remove('currentUser');
        await prefs.remove('authToken');
        _currentUser = null;
        _token = null;
      }
    }

    await fetchAvatars();
  }

  Future<bool> _verifyToken() async {
    if (_token == null) return false;
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.profile)),
        headers: ApiConfig.getHeaders(token: _token),
      );
      // A successful response means token is valid
      if (response.statusCode == 200) {
        // Also update the current user data from the response if available
        try {
          final data = json.decode(response.body);
          if (data['user'] != null) {
            _currentUser = User.fromJson(data['user']);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
          }
        } catch (e) {
          debugPrint('Warning: Could not update user data during token verification: $e');
          // Continue anyway as the token is valid
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error verifying token: $e');
      return false;
    }
  }

  Future<void> fetchAvatars() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.avatars)),
        headers: ApiConfig.getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          availableAvatars = List<String>.from(data['avatars']);
          if (data['defaultAvatar'] != null) {
            defaultAvatar = data['defaultAvatar'];
          }
          debugPrint('Fetched ${availableAvatars.length} avatars from server');
        }
      } else {
        debugPrint('Failed to fetch avatars. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching avatars: $e');
    }
    
    // If no avatars were fetched or in case of error, use fallback avatars
    if (availableAvatars.isEmpty) {
      debugPrint('Using fallback avatars');
      availableAvatars = [
        'assets/avatars/avatar1.png',
        'assets/avatars/avatar2.png',
        'assets/avatars/avatar3.png',
        'assets/avatars/avatar4.png',
      ];
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.login)),
        headers: ApiConfig.getHeaders(),
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _currentUser = User.fromJson(data['user']);
          _token = data['token'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
          await prefs.setString('authToken', _token!);

          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

Future<bool> register(String username, String password, {String? avatar}) async {
  try {
    // Default request data
    final Map<String, dynamic> requestData = {
      'username': username,
      'password': password,
    };
    
    // Handle custom avatar
    if (avatar != null) {
      debugPrint('Processing avatar: $avatar');
      
      // Web - base64 image
      if (kIsWeb && avatar.startsWith('data:image')) {
        // Parse base64 from data URI
        final avatarData = avatar.split(',')[1];
        requestData['custom_avatar'] = true; 
        requestData['avatar_data'] = avatarData;
        requestData['avatar_name'] = 'custom_avatar.png';
        
        debugPrint('Sending base64 avatar data (length: ${avatarData.length})');
      } 
      // Mobile - file path
      else if (!kIsWeb && (avatar.startsWith('/') || avatar.startsWith('file://'))) {
        try {
          final cleanPath = avatar.replaceFirst('file://', '');
          debugPrint('Processing avatar file at path: $cleanPath');
          
          final avatarFile = File(cleanPath);
          if (await avatarFile.exists()) {
            // Process image before uploading (resize/compress)
            final processedFile = await _fileAvatarService.processImage(avatarFile);
            
            // Read file as bytes and encode to base64
            final bytes = await processedFile.readAsBytes();
            final base64Data = base64Encode(bytes);
            
            // Add to request
            requestData['custom_avatar'] = true;
            requestData['avatar_data'] = base64Data;
            requestData['avatar_name'] = p.basename(avatarFile.path);
            
            debugPrint('Sending processed avatar data (length: ${base64Data.length})');
          } else {
            debugPrint('Avatar file not found at: $cleanPath');
            requestData['avatar'] = defaultAvatar;
          }
        } catch (e) {
          debugPrint('Error processing avatar file: $e');
          requestData['avatar'] = defaultAvatar;
        }
      }
      // Predefined avatar
      else {
        requestData['avatar'] = avatar;
      }
    } else {
      requestData['avatar'] = defaultAvatar;
    }
    
    debugPrint('Registration request data keys: ${requestData.keys.toList()}');
    
    final response = await http.post(
      Uri.parse(ApiConfig.getFullUrl(ApiConfig.register)),
      headers: ApiConfig.getHeaders(),
      body: json.encode(requestData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      debugPrint('Registration response: ${response.body}');
      return data['success'] == true;
    } else {
      debugPrint('Registration failed: ${response.statusCode}, ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('Registration error: $e');
    return false;
  }
}

  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.logout)),
          headers: ApiConfig.getHeaders(token: _token),
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUser');
      await prefs.remove('authToken');
      _currentUser = null;
      _token = null;
    }
  }

  Future<bool> updateProfile({String? newAvatar}) async {
    if (_currentUser == null || _token == null) return false;

    try {
      String? avatarUrl;
      bool customAvatarUploaded = false;
      final Map<String, dynamic> updateData = {};
      
      // Handle avatar update
      if (newAvatar != null) {
        // Check if it's a base64 image from web
        if (kIsWeb && newAvatar.startsWith('data:image')) {
          // Handle web base64 avatar
          updateData['custom_avatar'] = 'true'; // Changed from boolean to string
          updateData['avatar_data'] = newAvatar.split(',')[1]; // Extract base64 part
          updateData['avatar_name'] = 'custom_avatar.png';
        }
        // Check if it's a local file path (for mobile)
        else if (!kIsWeb && newAvatar.startsWith('/')) {
          final avatarFile = File(newAvatar);
          if (await avatarFile.exists()) {
            try {
              // Process image before uploading (resize/compress)
              final processedFile = await _fileAvatarService.processImage(avatarFile);
              
              // Upload to server and get URL
              avatarUrl = await _fileAvatarService.uploadAvatarToServer(processedFile, _token);
              
              if (avatarUrl.isNotEmpty) {
                customAvatarUploaded = true;
                // Store the path for later use
                await _fileAvatarService.saveAvatarFile(avatarFile);
              }
            } catch (e) {
              debugPrint('Error processing/uploading avatar: $e');
              // Continue with regular update
              updateData['avatar'] = newAvatar;
            }
          }
        } else {
          // Regular avatar from the available list
          updateData['avatar'] = newAvatar;
        }
        
        // Add the avatar URL if we uploaded a custom avatar
        if (customAvatarUploaded && avatarUrl != null) {
          updateData['avatar'] = avatarUrl;
        }
      }
      
      if (updateData.isEmpty && !customAvatarUploaded) {
        return true; // Nothing to update
      }

      final response = await http.put(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.avatar)),
        headers: ApiConfig.getHeaders(token: _token),
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _currentUser = User.fromJson(data['user']);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Profile update error: $e');
      return false;
    }
  }

  Future<bool> updateProgress({int? newLevel, int? newScore}) async {
    if (_currentUser == null || _token == null) return false;

    try {
      final Map<String, dynamic> updateData = {};
      if (newLevel != null) updateData['level'] = newLevel;
      if (newScore != null) updateData['score'] = newScore;
      if (updateData.isEmpty) return true;

      final response = await http.put(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.progress)),
        headers: ApiConfig.getHeaders(token: _token),
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _currentUser = User.fromJson(data['user']);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Progress update error: $e');
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null || _token == null) return false;

    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.password)),
        headers: ApiConfig.getHeaders(token: _token),
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('Password change error: $e');
      return false;
    }
  }
}