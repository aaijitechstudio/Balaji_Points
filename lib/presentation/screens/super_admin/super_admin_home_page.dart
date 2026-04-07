import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:balaji_points/config/theme.dart' hide AppColors;
import 'package:balaji_points/core/constants/app_constants.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/services/fcm_service.dart';
import 'package:balaji_points/services/session_service.dart';
import 'package:balaji_points/services/store_service.dart';

class SuperAdminHomePage extends StatefulWidget {
  const SuperAdminHomePage({super.key});

  @override
  State<SuperAdminHomePage> createState() => _SuperAdminHomePageState();
}

class _SuperAdminHomePageState extends State<SuperAdminHomePage> {
  final StoreService _storeService = StoreService();
  bool _isBootstrapping = true;
  String? _bootstrapError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await _storeService.ensureDefaultStoreExists();
      if (!mounted) return;
      setState(() {
        _isBootstrapping = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isBootstrapping = false;
        _bootstrapError = e.toString();
      });
    }
  }

  Future<void> _handleLogout() async {
    await FCMService().deleteToken();
    await SessionService().clearSession();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _openStoreForm({
    DocumentSnapshot<Map<String, dynamic>>? existing,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _StoreFormDialog(
        existing: existing?.data(),
        onSave:
            ({
              required String name,
              required String code,
              required String address,
              required String city,
              required String phone,
              required String email,
              required String gstNo,
              required bool isActive,
            }) async {
              if (existing == null) {
                await _storeService.createStore(
                  name: name,
                  code: code,
                  address: address,
                  city: city,
                  phone: phone,
                  email: email,
                  gstNo: gstNo,
                  isActive: isActive,
                );
              } else {
                await _storeService.updateStore(
                  storeId: existing.id,
                  name: name,
                  code: code,
                  address: address,
                  city: city,
                  phone: phone,
                  email: email,
                  gstNo: gstNo,
                  isActive: isActive,
                );
              }
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: DesignToken.textDark,
        elevation: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                AppConstants.logoPath,
                width: 34,
                height: 34,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Super Admin',
              style: AppTextStyles.nunitoBold.copyWith(fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isBootstrapping ? null : () => _openStoreForm(),
        backgroundColor: DesignToken.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Create Store'),
      ),
      body: _isBootstrapping
          ? const Center(child: CircularProgressIndicator())
          : _bootstrapError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to prepare stores: $_bootstrapError',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _storeService.watchStores(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Unable to load stores.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final stores = snapshot.data?.docs ?? const [];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2F5D50), Color(0xFF7E5E3A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store Control Center',
                            style: AppTextStyles.nunitoBold.copyWith(
                              color: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage stores, bootstrap the default location, and prepare the app for future branch-based expansion.',
                            style: AppTextStyles.nunitoRegular.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Total Stores',
                            value: '${stores.length}',
                            icon: Icons.storefront_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Active Stores',
                            value:
                                '${stores.where((doc) => (doc.data()['isActive'] as bool?) ?? false).length}',
                            icon: Icons.verified_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Stores',
                      style: AppTextStyles.nunitoBold.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 12),
                    if (stores.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('No stores found yet.'),
                      )
                    else
                      ...stores.map(
                        (doc) => _StoreListCard(
                          store: doc,
                          onEdit: () => _openStoreForm(existing: doc),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: DesignToken.primary),
          const SizedBox(height: 18),
          Text(value, style: AppTextStyles.nunitoBold.copyWith(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.nunitoRegular.copyWith(
              color: DesignToken.textDark.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreListCard extends StatelessWidget {
  const _StoreListCard({required this.store, required this.onEdit});

  final DocumentSnapshot<Map<String, dynamic>> store;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final data = store.data() ?? const <String, dynamic>{};
    final isActive = (data['isActive'] as bool?) ?? false;
    final updatedAt = data['updatedAt'];
    String updatedLabel = 'Recently updated';
    if (updatedAt is Timestamp) {
      final date = updatedAt.toDate();
      updatedLabel = '${date.day}/${date.month}/${date.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive
              ? DesignToken.primary.withOpacity(0.25)
              : Colors.grey.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (data['name'] as String?) ?? store.id,
                  style: AppTextStyles.nunitoBold.copyWith(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE6F4EA)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: AppTextStyles.nunitoSemiBold.copyWith(
                    color: isActive
                        ? const Color(0xFF1E7D32)
                        : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _MetaPill(
                icon: Icons.pin_drop_outlined,
                text: (data['address'] as String?) ?? '-',
              ),
              _MetaPill(
                icon: Icons.location_city_outlined,
                text: (data['city'] as String?) ?? '-',
              ),
              _MetaPill(
                icon: Icons.badge_outlined,
                text: (data['code'] as String?) ?? '-',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Phone: ${(data['phone'] as String?) ?? '-'}',
            style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Email: ${(data['email'] as String?) ?? '-'}',
            style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'GST: ${(data['gstNo'] as String?) ?? '-'}',
            style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Updated: $updatedLabel',
                style: AppTextStyles.nunitoRegular.copyWith(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: DesignToken.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.nunitoSemiBold.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _StoreFormDialog extends StatefulWidget {
  const _StoreFormDialog({required this.onSave, this.existing});

  final Map<String, dynamic>? existing;
  final Future<void> Function({
    required String name,
    required String code,
    required String address,
    required String city,
    required String phone,
    required String email,
    required String gstNo,
    required bool isActive,
  })
  onSave;

  @override
  State<_StoreFormDialog> createState() => _StoreFormDialogState();
}

class _StoreFormDialogState extends State<_StoreFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _gstController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(
      text: existing?['name'] as String? ?? '',
    );
    _codeController = TextEditingController(
      text: existing?['code'] as String? ?? '',
    );
    _addressController = TextEditingController(
      text: existing?['address'] as String? ?? '',
    );
    _cityController = TextEditingController(
      text: existing?['city'] as String? ?? '',
    );
    _phoneController = TextEditingController(
      text: existing?['phone'] as String? ?? '',
    );
    _emailController = TextEditingController(
      text: existing?['email'] as String? ?? '',
    );
    _gstController = TextEditingController(
      text: existing?['gstNo'] as String? ?? '',
    );
    _isActive = (existing?['isActive'] as bool?) ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
    });
    try {
      await widget.onSave(
        name: _nameController.text,
        code: _codeController.text,
        address: _addressController.text,
        city: _cityController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        gstNo: _gstController.text,
        isActive: _isActive,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save store: $e'),
          backgroundColor: DesignToken.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Store' : 'Create Store',
                style: AppTextStyles.nunitoBold.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 16),
              _FormField(controller: _nameController, label: 'Store name'),
              const SizedBox(height: 12),
              _FormField(
                controller: _codeController,
                label: 'Store code',
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Store code is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _FormField(controller: _addressController, label: 'Address'),
              const SizedBox(height: 12),
              _FormField(controller: _cityController, label: 'City'),
              const SizedBox(height: 12),
              _FormField(
                controller: _phoneController,
                label: 'Phone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _FormField(controller: _gstController, label: 'GST No'),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active store'),
                value: _isActive,
                activeColor: DesignToken.primary,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignToken.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isSaving ? 'Saving...' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator:
          validator ??
          (value) {
            if ((value ?? '').trim().isEmpty) {
              return '$label is required';
            }
            return null;
          },
      decoration: InputDecoration(labelText: label),
    );
  }
}
