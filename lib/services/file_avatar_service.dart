import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../utils/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img; // Add this package for image processing
import 'dart:math' as math;

/// Service to handle custom avatar file operations
class FileAvatarService {
  static final FileAvatarService _instance = FileAvatarService._internal();
  factory FileAvatarService() => _instance;
  FileAvatarService._internal();

  /// Directory where avatar files are stored locally
  Future<Directory> get _avatarsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory('${appDir.path}/avatars');
    
    // Create directory if it doesn't exist
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }
    
    return avatarsDir;
  }

  /// Copy a file to the avatars directory with a unique filename
  /// Returns the local path to the copied file
  Future<String> saveAvatarFile(File file) async {
    try {
      // Generate a unique filename
      final uuid = const Uuid().v4();
      final fileExtension = path.extension(file.path);
      final newFilename = 'avatar_$uuid$fileExtension';
      
      // Get avatars directory
      final dir = await _avatarsDir;
      final newPath = '${dir.path}/$newFilename';
      
      // Copy the file
      await file.copy(newPath);
      
      debugPrint('Avatar saved to: $newPath');
      return newPath;
    } catch (e) {
      debugPrint('Error saving avatar file: $e');
      rethrow;
    }
  }

  /// Process image before saving (resize and compress)
  Future<File> processImage(File imageFile, {int maxWidth = 512, int maxHeight = 512, int quality = 80}) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      
      // Decode image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) throw Exception('Could not decode image');
      
      // Resize the image while maintaining aspect ratio
      img.Image resized;
      if (image.width > maxWidth || image.height > maxHeight) {
        resized = img.copyResize(
          image,
          width: image.width > image.height ? maxWidth : null,
          height: image.height >= image.width ? maxHeight : null,
        );
      } else {
        resized = image;
      }
      
      // For square avatars - crop to square if needed
      int size = math.min(resized.width, resized.height);
      int offsetX = (resized.width - size) ~/ 2;
      int offsetY = (resized.height - size) ~/ 2;
      
      img.Image cropped = img.copyCrop(
        resized, 
        x: offsetX, 
        y: offsetY, 
        width: size,
        height: size
      );

      // Encode to PNG (or JPEG with quality parameter)
      List<int> encodedImage = img.encodePng(cropped);
      
      // Create temp file with the processed image
      final tempDir = await getTemporaryDirectory();
      final processedPath = '${tempDir.path}/processed_${path.basename(imageFile.path)}';
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(encodedImage);
      
      return processedFile;
    } catch (e) {
      debugPrint('Error processing image: $e');
      // Return original if processing fails
      return imageFile;
    }
  }

  /// Upload avatar file to server and return the URL
  Future<String> uploadAvatarToServer(File file, String? token) async {
    try {
      // Ensure file exists
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      // For web, use base64
      if (kIsWeb || ApiConfig.useBase64ForAvatars) {
        final bytes = await file.readAsBytes();
        return await _uploadAvatarBase64(bytes, path.basename(file.path), token);
      } 
      // For mobile, use multipart
      else {
        return await _uploadAvatarMultipart(file, token);
      }
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      // Return empty string on error
      return '';
    }
  }

  /// Upload using base64 encoding in JSON
  Future<String> _uploadAvatarBase64(Uint8List bytes, String fileName, String? token) async {
    final base64Image = base64Encode(bytes);
    
    final requestBody = {
      'custom_avatar': true,
      'avatar_data': base64Image,
      'avatar_name': fileName,
    };
    
    debugPrint('Sending base64 avatar upload request with data length: ${base64Image.length}');
    
    final response = await http.post(
      Uri.parse(ApiConfig.getFullUrl(ApiConfig.avatar)),
      headers: ApiConfig.getHeaders(token: token),
      body: json.encode(requestBody),
    );
    
    debugPrint('Base64 avatar upload response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint('Base64 avatar upload response: ${response.body}');
      if (data['success'] == true) {
        return data['avatar_url'] ?? '';
      }
    }
    
    debugPrint('Failed to upload avatar: ${response.body}');
    return '';
  }

  /// Upload using multipart form data
  Future<String> _uploadAvatarMultipart(File file, String? token) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.getFullUrl(ApiConfig.avatar)),
    );
    
    // Add headers - need to handle token separately for multipart
    final headers = ApiConfig.getHeaders(token: token);
    headers.remove('Content-Type'); // Let multipart set its own content type
    request.headers.addAll(headers);
    
    // Add file
    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar_file',
        file.path,
        filename: path.basename(file.path),
      ),
    );
    
    // Send request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['avatar_url'] ?? '';
      }
    }
    
    debugPrint('Failed to upload avatar: ${response.body}');
    return '';
  }

  /// Get a File object from a local path or URL
  Future<File?> getAvatarFile(String avatarPath) async {
    try {
      // Check if this is a local file path
      if (avatarPath.startsWith('/')) {
        final file = File(avatarPath);
        if (await file.exists()) {
          return file;
        }
        return null;
      }
      
      // Check if this is a URL
      if (avatarPath.startsWith('http')) {
        final tempDir = await getTemporaryDirectory();
        final filename = path.basename(avatarPath);
        final file = File('${tempDir.path}/$filename');
        
        // Download file if it doesn't exist
        if (!await file.exists()) {
          final response = await http.get(Uri.parse(avatarPath));
          if (response.statusCode == 200) {
            await file.writeAsBytes(response.bodyBytes);
            return file;
          }
        } else {
          return file;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting avatar file: $e');
      return null;
    }
  }

  /// Delete an avatar file by path
  Future<bool> deleteAvatarFile(String avatarPath) async {
    try {
      // Only delete files in our avatars directory
      if (avatarPath.startsWith('/')) {
        final dir = await _avatarsDir;
        if (avatarPath.startsWith(dir.path)) {
          final file = File(avatarPath);
          if (await file.exists()) {
            await file.delete();
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting avatar file: $e');
      return false;
    }
  }

  /// Clear all cached avatars
  Future<void> clearAvatarCache() async {
    try {
      final dir = await _avatarsDir;
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing avatar cache: $e');
    }
  }

  /// Get a unique temporary file for storing an avatar
  Future<File> getTemporaryAvatarFile() async {
    final tempDir = await getTemporaryDirectory();
    final uuid = const Uuid().v4();
    return File('${tempDir.path}/temp_avatar_$uuid.png');
  }
}