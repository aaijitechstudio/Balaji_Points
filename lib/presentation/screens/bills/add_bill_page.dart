import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/config/theme.dart';
import 'package:balaji_points/services/bill_service.dart';
import 'package:balaji_points/services/user_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/core/logger.dart';

class AddBillPage extends StatefulWidget {
  const AddBillPage({super.key});

  @override
  State<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends State<AddBillPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _billNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final BillService _billService = BillService();
  final UserService _userService = UserService();
  final SessionService _sessionService = SessionService();

  File? _selectedImage;
  DateTime? _billDate;
  bool _isSubmitting = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
  }

  /// Check if profile is complete, redirect to edit profile if not
  Future<void> _checkProfileCompletion() async {
    try {
      _userData = await _userService.getCurrentUserData();

      final firstName = (_userData?['firstName'] as String? ?? '').trim();
      final lastName = (_userData?['lastName'] as String? ?? '').trim();
      final profileImage = (_userData?['profileImage'] as String? ?? '').trim();

      if (firstName.isEmpty || lastName.isEmpty || profileImage.isEmpty) {
        if (mounted) {
          // Show dialog and redirect to edit profile
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showProfileIncompleteDialog();
          });
        }
      }
    } catch (e) {
      AppLogger.error('Error checking profile completion', e);
    }
  }

  void _showProfileIncompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_alt_1,
                color: Colors.orange.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Profile Incomplete',
                style: AppTextStyles.nunitoBold.copyWith(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Text(
          'Please complete your profile (first name, last name, and profile picture) to add bills and earn points.',
          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/'); // Go back to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Go Back',
              style: AppTextStyles.nunitoSemiBold.copyWith(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/edit-profile');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Complete Profile',
              style: AppTextStyles.nunitoSemiBold.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _storeNameController.dispose();
    _billNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _billDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _billDate) {
      setState(() {
        _billDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      AppLogger.error('Error picking image', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      AppLogger.error('Error taking photo', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitBill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Use current date if bill date not selected
    final billDate = _billDate ?? DateTime.now();

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get user phone number from session (PIN-based auth)
      final phoneNumber = await _sessionService.getPhoneNumber();
      if (phoneNumber == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to submit bills'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final success = await _billService.submitBill(
        carpenterId: phoneNumber,  // Use phone number as user ID
        carpenterPhone: phoneNumber,
        amount: amount,
        imageFile: _selectedImage,
        billDate: billDate,
        storeName: _storeNameController.text.trim().isEmpty
            ? null
            : _storeNameController.text.trim(),
        billNumber: _billNumberController.text.trim().isEmpty
            ? null
            : _billNumberController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Bill submitted successfully! Admin will review it.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Navigate back after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              context.pop();
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit bill. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error submitting bill', e);
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    return Scaffold(
      backgroundColor: AppColors.woodenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Bill',
          style: AppTextStyles.nunitoBold.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Scrollable Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Bill Image Section
                    Text(
                      'Bill Image',
                      style: AppTextStyles.nunitoSemiBold.copyWith(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 64,
                                    color: AppColors.primary.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tap to add bill image',
                                    style: AppTextStyles.nunitoRegular.copyWith(
                                      color: AppColors.textDark.withOpacity(
                                        0.6,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Amount Field (moved to top)
                    Text(
                      'Bill Amount (₹)',
                      style: AppTextStyles.nunitoSemiBold.copyWith(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.nunitoRegular.copyWith(
                        color: AppColors.textDark,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter bill amount',
                        hintStyle: AppTextStyles.nunitoRegular.copyWith(
                          color: Colors.grey[400],
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.currency_rupee,
                            color: AppColors.primary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter bill amount';
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Bill Date Field
                    Text(
                      'Bill Date (Optional)',
                      style: AppTextStyles.nunitoSemiBold.copyWith(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _billDate != null
                                    ? '${_billDate!.day}/${_billDate!.month}/${_billDate!.year}'
                                    : 'Select bill date (optional)',
                                style: AppTextStyles.nunitoRegular.copyWith(
                                  color: _billDate != null
                                      ? AppColors.textDark
                                      : Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.primary.withOpacity(0.5),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Store Name Field
                    Text(
                      'Store/Vendor Name (Optional)',
                      style: AppTextStyles.nunitoSemiBold.copyWith(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _storeNameController,
                      style: AppTextStyles.nunitoRegular.copyWith(
                        color: AppColors.textDark,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter store or vendor name (optional)',
                        hintStyle: AppTextStyles.nunitoRegular.copyWith(
                          color: Colors.grey[400],
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.store,
                            color: AppColors.primary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bill Number Field
                    Text(
                      'Bill/Invoice Number (Optional)',
                      style: AppTextStyles.nunitoSemiBold.copyWith(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _billNumberController,
                      style: AppTextStyles.nunitoRegular.copyWith(
                        color: AppColors.textDark,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter bill or invoice number (optional)',
                        hintStyle: AppTextStyles.nunitoRegular.copyWith(
                          color: Colors.grey[400],
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.receipt,
                            color: AppColors.primary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Notes Field (Optional)
                    Text(
                      'Notes (Optional)',
                      style: AppTextStyles.nunitoSemiBold.copyWith(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      style: AppTextStyles.nunitoRegular.copyWith(
                        color: AppColors.textDark,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Add any additional notes...',
                        hintStyle: AppTextStyles.nunitoRegular.copyWith(
                          color: Colors.grey[400],
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.note,
                            color: AppColors.primary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info Text
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Fixed Submit Button at Bottom
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: Container(
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
                    onPressed: _isSubmitting ? null : _submitBill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
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
                            'Submit Bill',
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Earn tab selected (bills are related to earning)
        onTap: _onBottomNavTapped,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: Colors.white,
        backgroundColor: AppColors.primary,
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
