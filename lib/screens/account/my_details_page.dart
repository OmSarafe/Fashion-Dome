import 'package:ecommerence_project/models/user_profile.dart';
import 'package:ecommerence_project/services/user_profile_service.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Mydetails extends StatefulWidget {
  const Mydetails({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<Mydetails> createState() => _MydetailsState();
}

class _MydetailsState extends State<Mydetails> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = UserProfileService();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _deliveryAddressController;

  static const _genderOptions = <String>[
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  late String _gender;
  DateTime? _dateOfBirth;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _deliveryAddressController =
        TextEditingController(text: widget.profile.deliveryAddress);
    _gender = _genderOptions.contains(widget.profile.gender)
        ? widget.profile.gender
        : 'Prefer not to say';
    _dateOfBirth = DateTime.tryParse(widget.profile.dateOfBirth ?? '');
  }

  Future<void> _chooseDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(today.year - 18),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (selected != null && mounted) {
      setState(() => _dateOfBirth = selected);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await _profileService.updateProfile(
        userId: widget.profile.id,
        name: _nameController.text,
        phone: _phoneController.text,
        deliveryAddress: _deliveryAddressController.text,
        gender: _gender,
        dateOfBirth: _dateOfBirth,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Unable to update profile.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update profile.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('My Details'),
      ),
      body: ResponsiveContent(
        maxWidth: 760,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 28),
            children: [
              _field(
                controller: _nameController,
                label: 'Full name',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.length < 2) return 'Enter your full name.';
                  if (name.length > 60) return 'Name is too long.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _field(
                controller: _emailController,
                label: 'Email address',
                icon: Icons.email_outlined,
                readOnly: true,
                helperText: 'Managed by your sign-in provider',
              ),
              const SizedBox(height: 16),
              _field(
                controller: _phoneController,
                label: 'Phone number (optional)',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                  LengthLimitingTextInputFormatter(18),
                ],
                validator: (value) {
                  final phone = value?.trim() ?? '';
                  if (phone.isEmpty) return null;
                  if (!RegExp(r'^\+?[0-9 ]{7,18}$').hasMatch(phone)) {
                    return 'Enter a valid phone number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _field(
                controller: _deliveryAddressController,
                label: 'Delivery address',
                icon: Icons.location_on_outlined,
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.newline,
                maxLines: 3,
                validator: (value) {
                  final address = value?.trim() ?? '';
                  if (address.isEmpty) return null;
                  if (address.length < 10) return 'Enter your full address.';
                  if (address.length > 250) return 'Address is too long.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _chooseDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: _decoration(
                    label: 'Date of birth (optional)',
                    icon: Icons.cake_outlined,
                  ),
                  child: Text(
                    _dateOfBirth == null
                        ? 'Select date'
                        : _displayDate(_dateOfBirth!),
                    style: TextStyle(
                      color: _dateOfBirth == null
                          ? const Color(0xFF777777)
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: _decoration(
                  label: 'Gender',
                  icon: Icons.people_outline,
                ),
                items: _genderOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _gender = value);
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    String? helperText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: _decoration(
        label: label,
        icon: icon,
        helperText: helperText,
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      helperText: helperText,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
    );
  }

  String _displayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _deliveryAddressController.dispose();
    super.dispose();
  }
}
