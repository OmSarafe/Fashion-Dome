import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/screens/checkout/map_address_picker_page.dart';
import 'package:ecommerence_project/services/user_profile_service.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:ecommerence_project/widgets/address_autocomplete_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Addresspage extends StatefulWidget {
  const Addresspage({super.key});

  @override
  State<Addresspage> createState() => _AddresspageState();
}

class _AddresspageState extends State<Addresspage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _profileService = UserProfileService();
  bool _addressLoaded = false;
  bool _isEditing = false;
  bool _isSaving = false;
  LatLng? _selectedLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = context.watch<ShopProvider>().userProfile;
    if (!_addressLoaded && profile != null) {
      _addressController.text = profile.deliveryAddress;
      _addressLoaded = true;
      _isEditing = profile.deliveryAddress.isEmpty;
      if (profile.deliveryLatitude != null &&
          profile.deliveryLongitude != null) {
        _selectedLocation = LatLng(
          profile.deliveryLatitude!,
          profile.deliveryLongitude!,
        );
      }
    }
  }

  Future<void> _chooseLocation() async {
    final selection = await Navigator.of(context).push<MapAddressSelection>(
      MaterialPageRoute(
        builder: (_) => MapAddressPickerPage(
          initialLocation: _selectedLocation,
        ),
      ),
    );
    if (selection == null || !mounted) return;
    setState(() {
      _selectedLocation = selection.location;
      if (selection.address.isNotEmpty) {
        _addressController.text = selection.address;
      }
      _isEditing = true;
    });
  }

  Future<void> _saveAddress() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final profile = context.read<ShopProvider>().userProfile;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your profile is still loading.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _profileService.updateDeliveryAddress(
        userId: profile.id,
        deliveryAddress: _addressController.text,
        deliveryLatitude: _selectedLocation?.latitude,
        deliveryLongitude: _selectedLocation?.longitude,
      );
      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery address saved.')),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Unable to save address.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save address.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ShopProvider>().userProfile;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Address Book'),
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveContent(
              maxWidth: 760,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.only(top: 12, bottom: 28),
                  children: [
                    const Text(
                      'Default delivery address',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This address will be filled automatically at checkout.',
                      style: TextStyle(color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _isSaving ? null : _chooseLocation,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.map_outlined),
                      label: Text(
                        _selectedLocation == null
                            ? 'Choose location on map'
                            : 'Change map location',
                      ),
                    ),
                    if (_selectedLocation != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Delivery pin selected. Confirm the written address below.',
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    AddressAutocompleteField(
                      controller: _addressController,
                      enabled: _isEditing && !_isSaving,
                      helperText:
                          'Select a suggestion or continue typing manually.',
                      onManualChanged: () => _selectedLocation = null,
                      onSelection: (selection) {
                        setState(() {
                          _selectedLocation = LatLng(
                            selection.latitude,
                            selection.longitude,
                          );
                        });
                      },
                      validator: (value) {
                        final address = value?.trim() ?? '';
                        if (address.isEmpty)
                          return 'Enter your delivery address.';
                        if (address.length < 10)
                          return 'Enter your full address.';
                        if (address.length > 250) return 'Address is too long.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _isSaving
                            ? null
                            : _isEditing
                                ? _saveAddress
                                : () => setState(() => _isEditing = true),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isSaving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _isEditing
                                    ? Icons.save_outlined
                                    : Icons.edit_outlined,
                              ),
                        label: Text(
                          _isSaving
                              ? 'Saving...'
                              : _isEditing
                                  ? 'Save address'
                                  : 'Edit address',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
