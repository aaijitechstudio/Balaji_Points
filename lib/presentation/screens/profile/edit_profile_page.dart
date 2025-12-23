import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/services/user_service.dart';
import 'package:balaji_points/services/storage_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/core/utils/back_button_handler.dart';

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
  final SessionService _sessionService = SessionService();

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
      debugPrint('EditProfilePage: Loading user data from server...');
      // Force refresh from server to get latest data
      final userData = await _userService.getCurrentUserData(
        forceRefresh: true,
      );
      if (userData != null && mounted) {
        setState(() {
          _firstNameController.text = userData['firstName'] as String? ?? '';
          _lastNameController.text = userData['lastName'] as String? ?? '';
          _existingImageUrl = userData['profileImage'] as String?;
          _isLoading = false;
        });
        // Debug: Log loaded data
        debugPrint('EditProfilePage: User data loaded successfully');
        debugPrint('  firstName: ${userData['firstName']}');
        debugPrint('  lastName: ${userData['lastName']}');
        debugPrint('  profileImage: ${userData['profileImage']}');
      } else {
        debugPrint('EditProfilePage: No user data available');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('EditProfilePage: Error loading user data: $e');
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
            backgroundColor: DesignToken.error,
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
      // Get phone number from session (used as user ID in PIN-based auth)
      final phoneNumber = await _sessionService.getPhoneNumber();
      if (phoneNumber == null) {
        throw Exception('No user logged in');
      }

      // ✅ DATA SAFETY FIX: Validate and sanitize inputs before saving
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      // Validate data before proceeding
      if (firstName.isEmpty || firstName.length < 2) {
        throw Exception('First name must be at least 2 characters');
      }
      if (firstName.length > 50) {
        throw Exception('First name is too long (max 50 characters)');
      }
      if (lastName.length > 50) {
        throw Exception('Last name is too long (max 50 characters)');
      }

      // Sanitize inputs (remove any potentially harmful characters)
      final sanitizedFirstName = _sanitizeInput(firstName);
      final sanitizedLastName = lastName.isNotEmpty
          ? _sanitizeInput(lastName)
          : '';

      String? profileImageUrl = _existingImageUrl;
      String?
      oldImageUrlToDelete; // Store old image URL for deletion after successful save

      // Upload new image if user selected one
      if (_imageFile != null) {
        setState(() {
          _isUploadingImage = true;
        });

        debugPrint('EditProfilePage: Uploading new profile image...');

        // ✅ DATA SAFETY FIX: Upload new image FIRST, then delete old one
        // This prevents data loss if upload fails
        try {
          // Upload new image with phone number
          final newImageUrl = await _storageService.uploadProfileImage(
            phoneNumber: phoneNumber,
            imageFile: _imageFile!,
          );

          if (newImageUrl == null || newImageUrl.isEmpty) {
            throw Exception('Failed to upload profile image');
          }

          debugPrint(
            'EditProfilePage: Profile image uploaded successfully: $newImageUrl',
          );

          // Only after successful upload, mark old image for deletion
          // We'll delete it after Firestore update succeeds
          if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
            oldImageUrlToDelete = _existingImageUrl;
          }

          profileImageUrl = newImageUrl;

          setState(() {
            _isUploadingImage = false;
          });
        } catch (e) {
          setState(() {
            _isUploadingImage = false;
          });
          // Re-throw to show error to user - old image is still safe
          throw Exception('Failed to upload profile image: ${e.toString()}');
        }
      }

      // Update user data in Firestore (use set with merge to create if not exists)
      // ✅ DATA SAFETY FIX: Use sanitized values and preserve existing critical data
      final updateData = {
        'firstName': sanitizedFirstName,
        'lastName': sanitizedLastName,
        'updatedAt': FieldValue.serverTimestamp(),
        // Ensure phone field exists (used as unique identifier)
        'phone': phoneNumber,
      };

      // Add profile image URL if available
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        updateData['profileImage'] = profileImageUrl;
        debugPrint(
          'EditProfilePage: Saving profileImage to Firestore: $profileImageUrl',
        );
      } else {
        debugPrint('EditProfilePage: No profile image to save');
      }

      debugPrint('EditProfilePage: === SAVING USER DATA ===');
      debugPrint('  User ID (phone): $phoneNumber');
      debugPrint('  First Name: "$sanitizedFirstName"');
      debugPrint('  Last Name: "$sanitizedLastName"');
      debugPrint('  Profile Image: ${profileImageUrl ?? "none"}');
      debugPrint('  Update Data: $updateData');

      // ✅ DATA SAFETY FIX: Get current data as backup before update
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber);
      final currentDataSnapshot = await userRef.get();
      final currentData = currentDataSnapshot.data();

      // Save to Firestore
      await userRef.set(updateData, SetOptions(merge: true));

      debugPrint('EditProfilePage: ✅ Data saved successfully to Firestore!');

      // ✅ DATA SAFETY FIX: Verify the save by reading back and comparing
      final verifyDoc = await userRef.get(GetOptions(source: Source.server));
      final savedData = verifyDoc.data();

      debugPrint('EditProfilePage: Verified saved data:');
      debugPrint('  firstName: "${savedData?['firstName']}"');
      debugPrint('  lastName: "${savedData?['lastName']}"');
      debugPrint('  profileImage: ${savedData?['profileImage']}');

      // Verify critical fields were saved correctly
      if (savedData == null) {
        throw Exception('Failed to verify saved data - document not found');
      }

      if (savedData['firstName'] != sanitizedFirstName) {
        // Attempt to restore from backup
        if (currentData != null) {
          debugPrint(
            'EditProfilePage: ⚠️ Data mismatch detected, attempting restore...',
          );
          await userRef.set(currentData, SetOptions(merge: true));
        }
        throw Exception('Data verification failed - firstName mismatch');
      }

      if (savedData['phone'] != phoneNumber) {
        throw Exception('Data verification failed - phone number mismatch');
      }

      debugPrint('EditProfilePage: ✅ Data verification passed!');

      // Update session with new profile data
      await _sessionService.updateProfile(
        firstName: sanitizedFirstName,
        lastName: sanitizedLastName.isNotEmpty ? sanitizedLastName : null,
      );

      // ✅ DATA SAFETY FIX: Delete old image only after successful Firestore save
      // This ensures we don't lose the image if Firestore update fails
      if (oldImageUrlToDelete != null && oldImageUrlToDelete.isNotEmpty) {
        try {
          await _storageService.deleteOldProfileImageIfExists(
            oldImageUrlToDelete,
          );
          debugPrint('EditProfilePage: Old profile image deleted successfully');
        } catch (e) {
          // Don't fail the entire operation if old image deletion fails
          // It's just cleanup - old image will remain in storage
          debugPrint(
            'EditProfilePage: Warning - Could not delete old image: $e',
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: DesignToken.success,
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
            backgroundColor: DesignToken.error,
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

  bool _hasUnsavedChanges() {
    if (_isLoading || _isSaving) return false;

    // Compare current form state with loaded data
    final currentFirstName = _firstNameController.text.trim();
    final currentLastName = _lastNameController.text.trim();
    final hasImageChange = _imageFile != null;

    // Get initial values (from loaded data) - store them when loading
    // For simplicity, check if fields are different from empty or image changed
    return currentFirstName.isNotEmpty ||
        currentLastName.isNotEmpty ||
        hasImageChange;
  }

  /// ✅ DATA SAFETY FIX: Sanitize user input to prevent injection attacks
  String _sanitizeInput(String input) {
    // Remove any control characters and trim
    return input
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Remove control chars
        .trim();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    return Column(
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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: DesignToken.white,
                    ),
                    onPressed: () => context.pop(),
                  ),
                const SizedBox(width: 8),
                Text(
                  widget.isFirstTime ? 'Complete Your Profile' : 'Edit Profile',
                  style: AppTextStyles.nunitoBold.copyWith(
                    fontSize: 22,
                    color: DesignToken.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content
        Expanded(
          child: Container(
            color: DesignToken.woodenBackground,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: DesignToken.primary,
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
                                    color: DesignToken.white,
                                    border: Border.all(
                                      color: DesignToken.primary,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: DesignToken.black.withOpacity(
                                          0.1,
                                        ),
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
                                        : _existingImageUrl != null &&
                                              _existingImageUrl!.isNotEmpty
                                        ? Image.network(
                                            _existingImageUrl!,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                color: DesignToken.secondary
                                                    .withValues(alpha: 0.2),
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                        : null,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(DesignToken.primary),
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  debugPrint(
                                                    'EditProfilePage: Error loading profile image: $error',
                                                  );
                                                  return const Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color:
                                                        DesignToken.secondary,
                                                  );
                                                },
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: DesignToken.secondary,
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
                                      color: DesignToken.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: DesignToken.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: DesignToken.white,
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
                              color: DesignToken.textDark.withOpacity(0.6),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // First Name Field
                          Container(
                            decoration: BoxDecoration(
                              color: DesignToken.white,
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
                                color: DesignToken.textDark,
                              ),
                              decoration: InputDecoration(
                                labelText: 'First Name *',
                                labelStyle: AppTextStyles.nunitoMedium.copyWith(
                                  color: DesignToken.primary,
                                ),
                                hintText: 'Enter your first name',
                                hintStyle: AppTextStyles.nunitoRegular.copyWith(
                                  color: Colors.grey[400],
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: DesignToken.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: DesignToken.white,
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
                              color: DesignToken.white,
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
                                color: DesignToken.textDark,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                labelStyle: AppTextStyles.nunitoMedium.copyWith(
                                  color: DesignToken.primary,
                                ),
                                hintText: 'Enter your last name',
                                hintStyle: AppTextStyles.nunitoRegular.copyWith(
                                  color: Colors.grey[400],
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: DesignToken.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: DesignToken.white,
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
                                        DesignToken.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Uploading image...',
                                    style: AppTextStyles.nunitoMedium.copyWith(
                                      fontSize: 14,
                                      color: DesignToken.primary,
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
                                  color: DesignToken.secondary.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: (_isSaving || _isUploadingImage)
                                  ? null
                                  : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignToken.secondary,
                                foregroundColor: DesignToken.white,
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      widget.isFirstTime
                                          ? 'Complete Profile'
                                          : 'Save Changes',
                                      style: AppTextStyles.nunitoBold.copyWith(
                                        fontSize: 18,
                                        color: DesignToken.white,
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
                                color: DesignToken.textDark.withOpacity(0.6),
                              ),
                            ),
                          ],

                          const SizedBox(
                            height: 80,
                          ), // Extra padding for bottom nav
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isFirstTime && !_hasUnsavedChanges(),
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Check for dialogs first
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            return;
          }

          if (widget.isFirstTime) {
            // Prevent back on first-time setup
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please complete your profile'),
                backgroundColor: DesignToken.orange,
              ),
            );
          } else if (_hasUnsavedChanges()) {
            final shouldDiscard = await BackButtonHandler.showDiscardDialog(
              context,
            );
            if (shouldDiscard == true && mounted) {
              context.pop();
            }
          } else {
            context.pop();
          }
        }
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    // Don't show bottom nav when it's first time profile completion
    if (widget.isFirstTime) {
      return Scaffold(
        backgroundColor: DesignToken.primary,
        body: _buildContent(),
      );
    }

    // Show bottom navigation for edit profile
    return Scaffold(
      backgroundColor: DesignToken.primary,
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Profile tab selected
        onTap: _onBottomNavTapped,
        selectedItemColor: DesignToken.secondary,
        unselectedItemColor: Colors.white,
        backgroundColor: DesignToken.primary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            label: "Earn",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
