import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/fit_profile.dart';
import '../../services/fit_profile_service.dart';
import '../../utils/responsive_layout.dart';

class FitProfilePage extends StatefulWidget {
  const FitProfilePage({super.key});

  @override
  State<FitProfilePage> createState() => _FitProfilePageState();
}

class _FitProfilePageState extends State<FitProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _profileService = FitProfileService();

  FitPreference _fitPreference = FitPreference.regular;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasSavedProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.loadProfile();
    if (!mounted) return;

    if (profile != null) {
      _heightController.text = _formatMeasurement(profile.heightCm);
      _chestController.text = _formatMeasurement(profile.chestCm);
      _waistController.text = _formatMeasurement(profile.waistCm);
      _fitPreference = profile.fitPreference;
      _hasSavedProfile = true;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final profile = FitProfile(
      heightCm: double.parse(_heightController.text.trim()),
      chestCm: double.parse(_chestController.text.trim()),
      waistCm: double.parse(_waistController.text.trim()),
      fitPreference: _fitPreference,
    );

    try {
      await _profileService.saveProfile(profile);
      if (!mounted) return;
      setState(() => _hasSavedProfile = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fit profile saved privately on this device.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete fit profile?'),
        content: const Text(
          'Your saved measurements and fit preference will be removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _profileService.deleteProfile();
    if (!mounted) return;
    _heightController.clear();
    _chestController.clear();
    _waistController.clear();
    setState(() {
      _fitPreference = FitPreference.regular;
      _hasSavedProfile = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fit profile deleted from this device.')),
    );
  }

  String? _validateMeasurement(
    String? value,
    String label,
    double minimum,
    double maximum,
  ) {
    final measurement = double.tryParse(value?.trim() ?? '');
    if (measurement == null) return 'Enter your $label in centimetres.';
    if (measurement < minimum || measurement > maximum) {
      return 'Enter a value between ${minimum.toInt()} and ${maximum.toInt()} cm.';
    }
    return null;
  }

  String _formatMeasurement(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);

  InputDecoration _fieldDecoration(String label, String helperText) =>
      InputDecoration(
        labelText: label,
        helperText: helperText,
        suffixText: 'cm',
        border: const OutlineInputBorder(),
      );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Fit Profile')),
      body: ResponsiveContent(
        maxWidth: 760,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline, color: colors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Private by design',
                                  style: TextStyle(
                                    color: colors.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your measurements stay on this device. '
                                  'They are not uploaded to Fashion Dome '
                                  'or Firebase.',
                                  style: TextStyle(
                                    color: colors.onPrimaryContainer,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Your measurements',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'These details help the app explain which available size may suit you.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        LengthLimitingTextInputFormatter(5),
                      ],
                      decoration: _fieldDecoration(
                        'Height',
                        'Measure without shoes.',
                      ),
                      validator: (value) =>
                          _validateMeasurement(value, 'height', 120, 230),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _chestController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        LengthLimitingTextInputFormatter(5),
                      ],
                      decoration: _fieldDecoration(
                        'Chest',
                        'Measure around the fullest part.',
                      ),
                      validator: (value) =>
                          _validateMeasurement(value, 'chest', 60, 160),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _waistController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        LengthLimitingTextInputFormatter(5),
                      ],
                      decoration: _fieldDecoration(
                        'Waist',
                        'Measure where you normally wear trousers.',
                      ),
                      validator: (value) =>
                          _validateMeasurement(value, 'waist', 50, 150),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<FitPreference>(
                      value: _fitPreference,
                      decoration: const InputDecoration(
                        labelText: 'Preferred fit',
                        helperText: 'Choose how you like clothes to feel.',
                        border: OutlineInputBorder(),
                      ),
                      items: FitPreference.values
                          .map(
                            (preference) => DropdownMenuItem(
                              value: preference,
                              child: Text(preference.label),
                            ),
                          )
                          .toList(),
                      onChanged: (preference) {
                        if (preference != null) {
                          setState(() => _fitPreference = preference);
                        }
                      },
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.outlineVariant),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Size recommendations are guidance only. Brand, '
                        'material and product cut can affect the final fit.',
                        style: TextStyle(height: 1.45),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(_isSaving ? 'Saving...' : 'Save fit profile'),
                      ),
                    ),
                    if (_hasSavedProfile) ...[
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _isSaving ? null : _deleteProfile,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete fit profile'),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
