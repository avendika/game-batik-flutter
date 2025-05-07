import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../services/game_setting.dart';
import '../services/user_service.dart';

class RegisterDialog extends StatefulWidget {
  final VoidCallback onRegisterSuccess;

  const RegisterDialog({
    super.key,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoadingAvatars = true;

  // Get UserService instance
  final UserService _userService = UserService();
  
  // Currently selected avatar
  String _selectedAvatar = 'assets/avatars/default.png';
  
  // For custom uploaded image
  File? _customAvatarFile;
  Uint8List? _webImageBytes;  // Store image as bytes for web
  String? _webImageBase64;    // Base64 encoded image for web
  final ImagePicker _picker = ImagePicker();
  bool _usingCustomAvatar = false;

  @override
  void initState() {
    super.initState();
    // Make sure UserService has been initialized properly
    if (_userService.availableAvatars.isEmpty) {
      // Use fallback avatars if empty
      _userService.availableAvatars = [
        'assets/avatars/avatar1.png',
        'assets/avatars/avatar2.png',
        'assets/avatars/avatar3.png',
        'assets/avatars/avatar4.png',
      ];
    }
    _loadAvatars();
  }

  Future<void> _loadAvatars() async {
    setState(() {
      _isLoadingAvatars = true;
    });

    try {
      // Explicitly call fetchAvatars to ensure we have the latest data
      await _userService.fetchAvatars();
      
      // After fetching, check if we have avatars
      setState(() {
        if (_userService.availableAvatars.isNotEmpty) {
          _selectedAvatar = _userService.availableAvatars[0];
        } else {
          // Fallback to default if still empty
          _selectedAvatar = _userService.defaultAvatar;
        }
        _isLoadingAvatars = false;
      });
      
      // Debug log the avatars we have
      debugPrint("Available avatars after loading: ${_userService.availableAvatars}");
      
    } catch (e) {
      debugPrint("Error loading avatars: $e");
      // Even if there's an error, we should still have the fallback avatars
      setState(() {
        if (_userService.availableAvatars.isNotEmpty) {
          _selectedAvatar = _userService.availableAvatars[0];
        } else {
          _selectedAvatar = _userService.defaultAvatar;
        }
        _isLoadingAvatars = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

void _register() async {
  // Hide keyboard
  FocusScope.of(context).unfocus();
  
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });
  
  // Play sound effect
  GameSettings().playSfx('button_click.mp3');
  
  // Basic validation
  if (_usernameController.text.trim().isEmpty || 
      _passwordController.text.trim().isEmpty ||
      _confirmPasswordController.text.trim().isEmpty) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Harap isi semua field';
    });
    return;
  }
  
  if (_passwordController.text != _confirmPasswordController.text) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Password tidak cocok';
    });
    return;
  }
  
  try {
    String avatarPath = _selectedAvatar;

    if (_usingCustomAvatar) {
      if (kIsWeb && _webImageBase64 != null) {
        // For web, send complete data URI with base64 data
        avatarPath = 'data:image/png;base64,${_webImageBase64}';
        debugPrint('Using web custom avatar (base64 length: ${_webImageBase64!.length})');
      } else if (!kIsWeb && _customAvatarFile != null) {
        // For mobile, use file path
        avatarPath = _customAvatarFile!.path;
        debugPrint('Using mobile custom avatar path: $avatarPath');
      }
    } else {
      debugPrint('Using selected avatar: $avatarPath');
    }
    
    // Register with API through user service
    final success = await _userService.register(
      _usernameController.text.trim(), 
      _passwordController.text.trim(),
      avatar: avatarPath,
    );
      
      if (success) {
        // Close dialog and notify success
        if (mounted) {
          Navigator.pop(context);
          widget.onRegisterSuccess();
        }
      } else {
        setState(() {
          _errorMessage = 'Username sudah digunakan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  // Methods to handle image picking
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        if (kIsWeb) {
          // Handle Web platform - read bytes and convert to base64
          final bytes = await image.readAsBytes();
          final base64String = base64Encode(bytes);
          
          setState(() {
            _webImageBytes = bytes;
            _webImageBase64 = base64String;
            _usingCustomAvatar = true;
          });
          
          debugPrint('Image loaded as base64 (first 50 chars): ${base64String.substring(0, min(50, base64String.length))}...');
        } else {
          // Handle mobile platform
          setState(() {
            _customAvatarFile = File(image.path);
            _usingCustomAvatar = true;
          });
        }
        
        // Play sound effect
        GameSettings().playSfx('button_click.mp3');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      setState(() {
        _errorMessage = 'Gagal memilih gambar: $e';
      });
    }
  }
  
  // Method to pick image from camera
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (photo != null) {
        if (kIsWeb) {
          // Handle Web platform - read bytes and convert to base64
          final bytes = await photo.readAsBytes();
          final base64String = base64Encode(bytes);
          
          setState(() {
            _webImageBytes = bytes;
            _webImageBase64 = base64String;
            _usingCustomAvatar = true;
          });
          
          debugPrint('Camera photo loaded as base64 (first 50 chars): ${base64String.substring(0, min(50, base64String.length))}...');
        } else {
          // Handle mobile platform
          setState(() {
            _customAvatarFile = File(photo.path);
            _usingCustomAvatar = true;
          });
        }
        
        // Play sound effect
        GameSettings().playSfx('button_click.mp3');
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      setState(() {
        _errorMessage = 'Gagal mengambil foto: $e';
      });
    }
  }
  
  // Method to show image source selection dialog
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFD2B48C),
        title: const Text(
          'Pilih Sumber Gambar',
          style: TextStyle(
            color: Color(0xFF2D0E00),
            fontWeight: FontWeight.bold,
            fontSize: 14, // Ukuran font diperkecil
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true, // Membuat listtile lebih kecil
              leading: const Icon(Icons.photo_library, color: Color(0xFF8B4513), size: 18),
              title: const Text(
                'Galeri',
                style: TextStyle(color: Color(0xFF2D0E00), fontSize: 13),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              dense: true, // Membuat listtile lebih kecil
              leading: const Icon(Icons.camera_alt, color: Color(0xFF8B4513), size: 18),
              title: const Text(
                'Kamera',
                style: TextStyle(color: Color(0xFF2D0E00), fontSize: 13),
              ),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF8B4513), fontSize: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatarSelection() {
    // Force using fallback avatars if empty (double safety check)
    if (_userService.availableAvatars.isEmpty) {
      _userService.availableAvatars = [
        'assets/avatars/avatar1.png',
        'assets/avatars/avatar2.png',
        'assets/avatars/avatar3.png',
        'assets/avatars/avatar4.png',
      ];
      if (_selectedAvatar == _userService.defaultAvatar && _userService.availableAvatars.isNotEmpty) {
        _selectedAvatar = _userService.availableAvatars[0];
      }
    }
    
    if (_isLoadingAvatars) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0), // Ukuran padding diperkecil
          child: CircularProgressIndicator(
            color: Color(0xFF8B4513),
            strokeWidth: 2, // Ukuran stroke diperkecil
          ),
        ),
      );
    }
    
    debugPrint('Available avatars: ${_userService.availableAvatars.length}');
    
    if (_userService.availableAvatars.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0), // Ukuran padding diperkecil
          child: Text(
            'Tidak dapat memuat avatar',
            style: TextStyle(
              color: Color(0xFF2D0E00),
              fontWeight: FontWeight.bold,
              fontSize: 11, // Ukuran teks diperkecil
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Avatar:',
          style: TextStyle(
            color: Color(0xFF2D0E00),
            fontWeight: FontWeight.bold,
            fontSize: 11, // Ukuran teks diperkecil
          ),
        ),
        const SizedBox(height: 4), // Jarak diperkecil
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36, // Ukuran avatar container diperkecil
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _userService.availableAvatars.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 5), // Jarak antar avatar diperkecil
                  itemBuilder: (context, index) {
                    final avatar = _userService.availableAvatars[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatar;
                          _usingCustomAvatar = false;
                          _customAvatarFile = null;
                          _webImageBytes = null;
                          _webImageBase64 = null;
                        });
                        // Play sound when selecting avatar
                        GameSettings().playSfx('button_click.mp3');
                      },
                      child: Container(
                        width: 36, // Ukuran avatar diperkecil
                        height: 36, // Ukuran avatar diperkecil
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedAvatar == avatar && !_usingCustomAvatar
                                ? const Color(0xFF8B4513) 
                                : Colors.transparent,
                            width: 2, // Tebal border diperkecil
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading avatar: $avatar');
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 18, // Ukuran icon diperkecil
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 5), // Jarak diperkecil
            // Upload custom avatar button
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: 36, // Ukuran button diperkecil
                height: 36, // Ukuran button diperkecil
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _usingCustomAvatar
                        ? const Color(0xFF8B4513)
                        : Colors.transparent,
                    width: 2, // Tebal border diperkecil
                  ),
                  color: const Color(0xFFE6D7B9),
                ),
                child: _buildCustomAvatarPreview(),
              ),
            ),
          ],
        ),
        if (_usingCustomAvatar)
          Padding(
            padding: const EdgeInsets.only(top: 4.0), // Jarak diperkecil
            child: Text(
              'Gambar kustom dipilih',
              style: TextStyle(
                color: const Color(0xFF2D0E00).withOpacity(0.7),
                fontSize: 10, // Ukuran teks diperkecil
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  // Helper method to build custom avatar preview based on platform
  Widget _buildCustomAvatarPreview() {
    if (_usingCustomAvatar) {
      if (kIsWeb && _webImageBytes != null) {
        // For web platform using memory image
        return ClipOval(
          child: Image.memory(
            _webImageBytes!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading web image bytes: $error');
              return const Icon(
                Icons.broken_image,
                color: Color(0xFF8B4513),
                size: 16,
              );
            },
          ),
        );
      } else if (!kIsWeb && _customAvatarFile != null) {
        // For mobile platform
        return ClipOval(
          child: Image.file(
            _customAvatarFile!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading file image: $error');
              return const Icon(
                Icons.broken_image,
                color: Color(0xFF8B4513),
                size: 16,
              );
            },
          ),
        );
      }
    }
    
    // Default icon
    return const Icon(
      Icons.add_a_photo,
      color: Color(0xFF8B4513),
      size: 16, // Ukuran icon diperkecil
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300, // Ukuran container diperkecil (dari 350 ke 290)
        padding: const EdgeInsets.all(12), // Padding diperkecil (dari 16 ke 12)
        decoration: BoxDecoration(
          color: const Color(0xFFD2B48C).withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D0E00), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'DAFTAR AKUN',
              style: GoogleFonts.cinzelDecorative(
                textStyle: const TextStyle(
                  fontSize: 16, // Ukuran judul diperkecil (dari 20 ke 16)
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC49B5D),
                  shadows: [
                    Shadow(
                      blurRadius: 3.0, // Shadow diperkecil
                      color: Colors.black38,
                      offset: Offset(1, 1), // Offset diperkecil
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8), // Jarak diperkecil (dari 12 ke 8)
            
            // Username field
            _buildTextField(
              controller: _usernameController,
              hintText: 'Username',
              icon: Icons.person,
            ),
            const SizedBox(height: 8), // Jarak diperkecil (dari 12 ke 8)
            
            // Password field
            _buildTextField(
              controller: _passwordController,
              hintText: 'Password',
              icon: Icons.lock,
              isPassword: true,
              obscureText: _obscurePassword,
              onToggleObscure: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            const SizedBox(height: 8), // Jarak diperkecil (dari 12 ke 8)
            
            // Confirm password field
            _buildTextField(
              controller: _confirmPasswordController,
              hintText: 'Konfirmasi Password',
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscureConfirmPassword,
              onToggleObscure: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            
            // Avatar selection
            const SizedBox(height: 8), // Jarak diperkecil (dari 12 ke 8)
            _buildAvatarSelection(),
            
            // Error message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6), // Jarak diperkecil (dari 12 ke 6)
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 11, // Ukuran teks diperkecil
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 10), // Jarak diperkecil (dari 16 ke 10)
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton(
                  'BATAL',
                  onPressed: () {
                    GameSettings().playSfx('button_click.mp3');
                    Navigator.pop(context);
                  },
                  isPrimary: false,
                ),
                const SizedBox(width: 8), // Jarak diperkecil (dari 12 ke 8)
                _buildButton(
                  'DAFTAR',
                  onPressed: _isLoading ? null : _register,
                  isPrimary: true,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      height: 34, // Tinggi input diperkecil (dari 40 ke 34)
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6), // Radius diperkecil (dari 8 ke 6)
        border: Border.all(color: const Color(0xFF2D0E00), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3, // Blur diperkecil
            offset: const Offset(0, 1), // Offset diperkecil
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && obscureText,
        style: const TextStyle(
          color: Color(0xFF2D0E00),
          fontSize: 12, // Ukuran font diperkecil (dari 13 ke 12)
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF2D0E00).withOpacity(0.6),
            fontSize: 12, // Ukuran hint diperkecil
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF8B4513),
            size: 16, // Ukuran icon diperkecil (dari 18 ke 16)
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF8B4513),
                    size: 16, // Ukuran icon diperkecil
                  ),
                  padding: EdgeInsets.zero, // Hapus padding pada icon button
                  constraints: const BoxConstraints(), // Hapus constraints pada icon button
                  onPressed: onToggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8, // Padding vertical diperkecil (dari 10 ke 8)
            horizontal: 8, // Padding horizontal diperkecil (dari 12 ke 8)
          ),
          isDense: true, // Membuat layout input lebih compact
        ),
      ),
    );
  }

  Widget _buildButton(
    String text, {
    VoidCallback? onPressed,
    bool isPrimary = true,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 30, // Tinggi tombol diperkecil
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFF8B4513)
              : Colors.white.withOpacity(0.9),
          foregroundColor: isPrimary
              ? Colors.white
              : const Color(0xFF8B4513),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // Radius diperkecil (dari 8 ke 6)
            side: BorderSide(
              color: const Color(0xFF2D0E00),
              width: isPrimary ? 1 : 1,
            ),
          ),
          elevation: 2, // Elevasi diperkecil (dari 4 ke 2)
          padding: const EdgeInsets.symmetric(
            vertical: 4, // Padding vertical diperkecil (dari 8 ke 4)
            horizontal: 10, // Padding horizontal diperkecil (dari 16 ke 10)
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 15, // Ukuran loading indicator diperkecil (dari 20 ke 15)
                height: 15, // Ukuran loading indicator diperkecil (dari 20 ke 15)
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 1.5, // Stroke width diperkecil (dari 2 ke 1.5)
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 12, // Ukuran font diperkecil (dari 14 ke 12)
                  fontWeight: FontWeight.bold,
                  color: isPrimary
                      ? Colors.white
                      : const Color(0xFF8B4513),
                ),
              ),
      ),
    );
  }
}