import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/widgets/navigation/unified_app_bar.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/services/bill_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/services/user_service.dart';
import 'package:balaji_points/core/utils/app_logger.dart';
import 'package:balaji_points/core/utils/back_button_handler.dart';
import 'package:balaji_points/features/admin/presentation/widgets/carpenter_selection_widget.dart';
import 'package:intl/intl.dart';

class AdminAddBillPage extends StatefulWidget {
  const AdminAddBillPage({super.key});

  @override
  State<AdminAddBillPage> createState() => _AdminAddBillPageState();
}

class _AdminAddBillPageState extends State<AdminAddBillPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _billNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final BillService _billService = BillService();
  final SessionService _sessionService = SessionService();
  final UserService _userService = UserService();

  Map<String, dynamic>? _selectedCarpenter;
  File? _selectedImage;
  DateTime _billDate = DateTime.now();
  bool _isSubmitting = false;
  Map<String, dynamic>? _adminData;

  bool _hasFormData() {
    return _selectedCarpenter != null ||
        _amountController.text.trim().isNotEmpty ||
        _storeNameController.text.trim().isNotEmpty ||
        _billNumberController.text.trim().isNotEmpty ||
        _notesController.text.trim().isNotEmpty ||
        _selectedImage != null;
  }

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      _adminData = await _userService.getCurrentUserData();
    } catch (e) {
      AppLogger.error('Error loading admin data', error: e);
    }
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
      initialDate: _billDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: DesignToken.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: DesignToken.textDark,
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
      AppLogger.error('Error picking image', error: e);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n?.errorOccurred ?? 'Error'}: ${e.toString()}'),
            backgroundColor: DesignToken.error,
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
      AppLogger.error('Error taking photo', error: e);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n?.errorOccurred ?? 'Error'}: ${e.toString()}'),
            backgroundColor: DesignToken.error,
          ),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignToken.radiusXL)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: DesignToken.primary,
              ),
              title: Text(l10n?.selectImage ?? 'Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: DesignToken.primary),
              title: Text(l10n?.selectImage ?? 'Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: DesignToken.error),
              title: Text(l10n?.cancel ?? 'Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  int _calculatePoints(double amount) {
    return (amount / 1000).floor();
  }

  Future<void> _submitBill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCarpenter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a carpenter'),
          backgroundColor: DesignToken.error,
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.enterValidAmount ?? 'Please enter a valid amount',
          ),
          backgroundColor: DesignToken.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get admin phone number from session
      final adminPhone = await _sessionService.getPhoneNumber();
      if (adminPhone == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.sessionExpired ?? 'Please login to submit bills',
              ),
              backgroundColor: DesignToken.error,
            ),
          );
        }
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final carpenterId = _selectedCarpenter!['userId'] as String? ??
          _selectedCarpenter!['phone'] as String;
      final carpenterPhone = _selectedCarpenter!['phone'] as String;

      // Get admin name if available
      String? adminName;
      if (_adminData != null) {
        final firstName = _adminData!['firstName'] ?? '';
        final lastName = _adminData!['lastName'] ?? '';
        adminName = ('$firstName $lastName').trim();
        if (adminName.isEmpty) {
          adminName = null;
        }
      }

      final success = await _billService.submitBillForCarpenter(
        carpenterId: carpenterId,
        carpenterPhone: carpenterPhone,
        amount: amount,
        adminId: adminPhone,
        adminPhone: adminPhone,
        adminName: adminName,
        imageFile: _selectedImage,
        billDate: _billDate,
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
            SnackBar(
              content: Text(
                l10n?.billSubmitted ??
                    'Bill submitted successfully! It will be reviewed.',
              ),
              backgroundColor: DesignToken.success,
              duration: const Duration(seconds: 3),
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
            SnackBar(
              content: Text(
                l10n?.billSubmitError ??
                    'Failed to submit bill. Please try again.',
              ),
              backgroundColor: DesignToken.error,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error submitting bill', error: e);
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n?.errorOccurred ?? 'Error'}: ${e.toString()}'),
            backgroundColor: DesignToken.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasFormData(),
      onPopInvoked: (didPop) async {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            return;
          }

          if (_hasFormData()) {
            final l10n = AppLocalizations.of(context);
            final shouldDiscard = await BackButtonHandler.showDiscardDialog(
              context,
              customMessage:
                  l10n?.discardBillMessage ??
                  'You have unsaved bill data. Do you want to discard it?',
            );
            if (shouldDiscard == true && mounted) {
              context.pop();
            }
          } else {
            context.pop();
          }
        }
      },
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          final amount = double.tryParse(_amountController.text.trim()) ?? 0;
          final points = _calculatePoints(amount);

          return Scaffold(
            backgroundColor: DesignToken.woodenBackground,
            body: Column(
              children: [
                UnifiedAppBar(
                  title: 'Add Bill for Carpenter',
                  backgroundColor: DesignToken.primary,
                  iconColor: DesignToken.white,
                  textColor: DesignToken.white,
                ),
                // Scrollable Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: DesignToken.paddingAll2XL,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: DesignToken.heightXL),

                          // Carpenter Selection
                          Text(
                            'Carpenter *',
                            style: AppTextStyles.nunitoSemiBold.copyWith(
                              fontSize: DesignToken.fontSizeLG,
                              color: DesignToken.primary,
                            ),
                          ),
                          SizedBox(height: DesignToken.heightMD),
                          CarpenterSelectionWidget(
                            selectedCarpenter: _selectedCarpenter,
                            onCarpenterSelected: (carpenter) {
                              setState(() {
                                _selectedCarpenter = carpenter;
                              });
                            },
                          ),

                          SizedBox(height: DesignToken.height3XL),

                          // Amount Field
                          Text(
                            l10n?.billAmount ?? 'Bill Amount (₹) *',
                            style: AppTextStyles.nunitoSemiBold.copyWith(
                              fontSize: DesignToken.fontSizeLG,
                              color: DesignToken.primary,
                            ),
                          ),
                          SizedBox(height: DesignToken.heightMD),

                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            style: AppTextStyles.nunitoRegular.copyWith(
                              color: DesignToken.textDark,
                              fontSize: DesignToken.fontSizeXL,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: DesignToken.white,
                              hintText:
                                  l10n?.enterBillAmount ?? 'Enter bill amount',
                              hintStyle: AppTextStyles.nunitoRegular.copyWith(
                                color: DesignToken.grey400,
                              ),
                              prefixIcon: Container(
                                margin: DesignToken.paddingAllMD,
                                decoration: BoxDecoration(
                                  color: DesignToken.primary.withOpacity(0.1),
                                  borderRadius: DesignToken.borderRadiusSM,
                                ),
                                child: const Icon(
                                  Icons.currency_rupee,
                                  color: DesignToken.primary,
                                ),
                              ),
                              suffixText: amount > 0 ? '$points pts' : null,
                              suffixStyle: AppTextStyles.nunitoBold.copyWith(
                                color: DesignToken.secondary,
                                fontSize: DesignToken.fontSizeMD,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: DesignToken.borderRadiusLG,
                                borderSide: BorderSide(
                                  color: DesignToken.primary.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: DesignToken.borderRadiusLG,
                                borderSide: BorderSide(
                                  color: DesignToken.primary.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: DesignToken.borderRadiusLG,
                                borderSide: const BorderSide(
                                  color: DesignToken.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n?.enterBillAmount ??
                                    'Please enter bill amount';
                              }
                              final amount = double.tryParse(value.trim());
                              if (amount == null || amount <= 0) {
                                return l10n?.enterValidAmount ??
                                    'Please enter a valid amount';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: DesignToken.height3XL),

                          // Bill Date Field
                          Text(
                            l10n?.billDate ?? 'Bill Date *',
                            style: AppTextStyles.nunitoSemiBold.copyWith(
                              fontSize: DesignToken.fontSizeLG,
                              color: DesignToken.primary,
                            ),
                          ),
                          SizedBox(height: DesignToken.heightMD),

                          GestureDetector(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: DesignToken.white,
                                borderRadius: DesignToken.borderRadiusLG,
                                border: Border.all(
                                  color: DesignToken.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: DesignToken.primary,
                                    size: 24,
                                  ),
                                  SizedBox(width: DesignToken.widthMD),
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd MMM yyyy').format(_billDate),
                                      style: AppTextStyles.nunitoRegular
                                          .copyWith(
                                            color: DesignToken.textDark,
                                            fontSize: DesignToken.fontSizeLG,
                                          ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: DesignToken.primary.withOpacity(0.5),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: DesignToken.height3XL),

                          // Bill Image Section
                          Text(
                            l10n?.billImage ?? 'Bill Image (Optional)',
                            style: AppTextStyles.nunitoSemiBold.copyWith(
                              fontSize: DesignToken.fontSizeLG,
                              color: DesignToken.primary,
                            ),
                          ),
                          SizedBox(height: DesignToken.heightMD),

                          GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: DesignToken.white,
                                borderRadius: DesignToken.borderRadiusLG,
                                border: Border.all(
                                  color: DesignToken.primary.withOpacity(0.3),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: DesignToken.borderRadiusMD,
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 64,
                                          color: DesignToken.primary
                                              .withOpacity(0.5),
                                        ),
                                        SizedBox(height: DesignToken.heightMD),
                                        Text(
                                          l10n?.tapToAddBillImage ??
                                              'Tap to add bill image',
                                          style: AppTextStyles.nunitoRegular
                                              .copyWith(
                                                color: DesignToken.textDark
                                                    .withOpacity(0.6),
                                                fontSize: DesignToken.fontSizeMD,
                                              ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          SizedBox(height: DesignToken.height3XL),

                          // Store Name Field
                          Text(
                            l10n?.storeVendorNameOptional ??
                                'Store/Vendor Name (Optional)',
                            style: AppTextStyles.nunitoSemiBold.copyWith(
                              fontSize: DesignToken.fontSizeLG,
                              color: DesignToken.primary,
                            ),
                          ),
                          SizedBox(height: DesignToken.heightMD),

                          TextFormField(
                            controller: _storeNameController,
                            style: AppTextStyles.nunitoRegular.copyWith(
                              color: DesignToken.textDark,
                              fontSize: DesignToken.fontSizeLG,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: DesignToken.white,
                              hintText:
                                  l10n?.enterStoreOrVendorNameOptional ??
                                  'Enter store or vendor name (optional)',
                              hintStyle: AppTextStyles.nunitoRegular.copyWith(
                                color: DesignToken.grey400,
                              ),
                              prefixIcon: Container(
                                margin: DesignToken.paddingAllMD,
                                decoration: BoxDecoration(
                                  color: DesignToken.primary.withOpacity(0.1),
                                  borderRadius: DesignToken.borderRadiusSM,
                                ),
                                child: const Icon(
                                  Icons.store,
                                  color: DesignToken.primary,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: DesignToken.borderRadiusLG,
                                borderSide: BorderSide(
                                  color: DesignToken.primary.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: DesignToken.borderRadiusLG,
                                borderSide: BorderSide(
                                  color: DesignToken.primary.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: DesignToken.borderRadiusLG,
                                borderSide: const BorderSide(
                                  color: DesignToken.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: DesignToken.height2XL),

                          // Bill Number Field
                          Text(
                            l10n?.billInvoiceNumberOptional ??
                                'Bill/Invoice Number (Optional)',
                            style: AppTextStyles.nunitoSemiBold.copyWith(
                              fontSize: DesignToken.fontSizeLG,
                              color: DesignToken.primary,
                            ),
                          ),
                          SizedBox(height: DesignToken.heightMD),

                          TextFormField(
                            controller: _billNumberController,
                            style: AppTextStyles.nunitoRegular.copyWith(
                              color: DesignToken.textDark,
                              fontSize: DesignToken.fontSizeLG,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: DesignToken.white,
                              hintText:
                                  l10n?.enterBillOrInvoiceNumberOptional ??
                                  'Enter bill or invoice number (optional)',
                              hintStyle: AppTextStyles.nunitoRegular.copyWith(
                                color: DesignToken.grey400,
                              ),
                              prefixIcon: Container(
                                margin: DesignToken.paddingAllMD,
                                decoration: BoxDecoration(
                                  color: DesignToken.primary.withOpacity(0.1),
                                  borderRadius: DesignToken.borderRadiusSM,
                                ),
                                child: const Icon(
                                  Icons.receipt,
                                  color: DesignToken.primary,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: DesignToken.borderRadiusLG,
                                borderSide: BorderSide(
                                  color: DesignToken.primary.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: DesignToken.borderRadiusLG,
                                borderSide: BorderSide(
                                  color: DesignToken.primary.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: DesignToken.borderRadiusLG,
                                borderSide: const BorderSide(
                                  color: DesignToken.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: DesignToken.height2XL),

                          // Notes Field (Optional)
                          Text(
                            l10n?.notesOptional ?? 'Notes (Optional)',
                            style: AppTextStyles.nunitoSemiBold.copyWith(
                              fontSize: DesignToken.fontSizeLG,
                              color: DesignToken.primary,
                            ),
                          ),
                          SizedBox(height: DesignToken.heightMD),

                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            style: AppTextStyles.nunitoRegular.copyWith(
                              color: DesignToken.textDark,
                              fontSize: DesignToken.fontSizeLG,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: DesignToken.white,
                              hintText:
                                  l10n?.addAnyAdditionalNotes ??
                                  'Add any additional notes...',
                              hintStyle: AppTextStyles.nunitoRegular.copyWith(
                                color: DesignToken.grey400,
                              ),
                              prefixIcon: Container(
                                margin: DesignToken.paddingAllMD,
                                decoration: BoxDecoration(
                                  color: DesignToken.primary.withOpacity(0.1),
                                  borderRadius: DesignToken.borderRadiusSM,
                                ),
                                child: const Icon(
                                  Icons.note,
                                  color: DesignToken.primary,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: DesignToken.borderRadiusLG,
                                borderSide: BorderSide(
                                  color: DesignToken.primary.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: DesignToken.borderRadiusLG,
                                borderSide: BorderSide(
                                  color: DesignToken.primary.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: DesignToken.borderRadiusLG,
                                borderSide: const BorderSide(
                                  color: DesignToken.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: DesignToken.height2XL),
                        ],
                      ),
                    ),
                  ),
                ),

                // Fixed Submit Button at Bottom
                Container(
                  padding: DesignToken.paddingAll2XL,
                  decoration: BoxDecoration(
                    color: DesignToken.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitBill,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignToken.primary,
                          foregroundColor: DesignToken.white,
                          padding: DesignToken.paddingVerticalLG,
                          shape: RoundedRectangleBorder(
                            borderRadius: DesignToken.borderRadiusLG,
                          ),
                          elevation: 2,
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
                                  fontSize: DesignToken.fontSizeXL,
                                  color: DesignToken.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

