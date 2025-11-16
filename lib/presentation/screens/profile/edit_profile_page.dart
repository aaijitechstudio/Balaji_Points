import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/config/theme.dart';
import 'package:balaji_points/services/user_service.dart';
import 'package:balaji_points/services/storage_service.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final bool isFirstTime;

  const EditProfilePage({super.key, this.isFirstTime = false});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _userService.getCurrentUserData();
      if (userData != null && mounted) {
        setState(() {
          _firstNameController.text = userData['firstName'] as String? ?? '';
          _lastNameController.text = userData['lastName'] as String? ?? '';
          _existingImageUrl = userData['profileImage'] as String?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      String? profileImageUrl = _existingImageUrl;

      // Upload new image if user selected one
      if (_imageFile != null) {
        setState(() {
          _isUploadingImage = true;
        });

        // Delete old image if exists
        await _storageService.deleteOldProfileImageIfExists(_existingImageUrl);

        // Upload new image
        profileImageUrl = await _storageService.uploadProfileImage(_imageFile!);

        if (profileImageUrl == null) {
          throw Exception('Failed to upload profile image');
        }

        setState(() {
          _isUploadingImage = false;
        });
      }

      // Update user data in Firestore (use set with merge to create if not exists)
      final updateData = {
        'firstName': firstName,
        'lastName': lastName,
        'updatedAt': FieldValue.serverTimestamp(),
        // Ensure basic fields exist
        'uid': user.uid,
        'phone': user.phoneNumber ?? '',
      };

      // Add profile image URL if available
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        updateData['profileImage'] = profileImageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Longer delay to ensure Firestore write completes and propagates
        await Future.delayed(const Duration(milliseconds: 1000));

        if (!mounted) return;

        // Navigate based on context
        if (widget.isFirstTime) {
          // First time - check role and navigate to appropriate page
          // Fetch fresh user data to get role
          final freshUserData = await _userService.getCurrentUserData();
          final role = (freshUserData?['role'] as String?)?.toLowerCase();

          if (!mounted) return;

          if (role == 'admin') {
            context.go('/admin');
          } else {
            context.go('/');
          }
        } else {
          // Edit mode - safely navigate back
          if (context.canPop()) {
            context.pop();
          } else {
            // Fallback to home if can't pop
            context.go('/');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // Top Safe Area with Primary Color
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (!widget.isFirstTime)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isFirstTime ? 'Complete Your Profile' : 'Edit Profile',
                    style: AppTextStyles.nunitoBold.copyWith(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: Container(
              color: AppColors.woodenBackground,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 24),

                            // Profile Image Picker
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: _imageFile != null
                                          ? Image.file(
                                              _imageFile!,
                                              fit: BoxFit.cover,
                                            )
                                          : _existingImageUrl != null
                                              ? Image.network(
                                                  _existingImageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: AppColors.secondary,
                                                    );
                                                  },
                                                )
                                              : const Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: AppColors.secondary,
                                                ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'Tap to change photo',
                              style: AppTextStyles.nunitoRegular.copyWith(
                                fontSize: 14,
                                color: AppColors.textDark.withOpacity(0.6),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // First Name Field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _firstNameController,
                                style: AppTextStyles.nunitoRegular.copyWith(
                                  fontSize: 16,
                                  color: AppColors.textDark,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'First Name *',
                                  labelStyle: AppTextStyles.nunitoMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                  hintText: 'Enter your first name',
                                  hintStyle: AppTextStyles.nunitoRegular.copyWith(
                                    color: Colors.grey[400],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'First name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Last Name Field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _lastNameController,
                                style: AppTextStyles.nunitoRegular.copyWith(
                                  fontSize: 16,
                                  color: AppColors.textDark,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  labelStyle: AppTextStyles.nunitoMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                  hintText: 'Enter your last name',
                                  hintStyle: AppTextStyles.nunitoRegular.copyWith(
                                    color: Colors.grey[400],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Upload Status
                            if (_isUploadingImage)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Uploading image...',
                                      style: AppTextStyles.nunitoMedium.copyWith(
                                        fontSize: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Save Button
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: (_isSaving || _isUploadingImage) ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        widget.isFirstTime ? 'Complete Profile' : 'Save Changes',
                                        style: AppTextStyles.nunitoBold.copyWith(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),

                            if (widget.isFirstTime) ...[
                              const SizedBox(height: 16),
                              Text(
                                'You need to complete your profile to continue',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.nunitoRegular.copyWith(
                                  fontSize: 14,
                                  color: AppColors.textDark.withOpacity(0.6),
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
