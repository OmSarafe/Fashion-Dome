import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/services/user_profile_service.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _profileService = UserProfileService();
  bool _isSaving = false;

  Future<void> _updateOrderPreference(bool enabled) async {
    final profile = context.read<ShopProvider>().userProfile;
    if (profile == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      await _profileService.updateOrderNotifications(
        userId: profile.id,
        enabled: enabled,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Order notifications enabled.'
                : 'Order notifications disabled.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update notification settings.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _updateMarketingPreference(bool enabled) async {
    final profile = context.read<ShopProvider>().userProfile;
    if (profile == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      await _profileService.updateMarketingNotifications(
        userId: profile.id,
        enabled: enabled,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Offers and new-product alerts enabled.'
                : 'Offers and new-product alerts disabled.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update notification settings.'),
        ),
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
        title: const Text('Notification Settings'),
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveContent(
              maxWidth: 760,
              child: ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 28),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.all(16),
                      secondary: const Icon(Icons.local_shipping_outlined),
                      title: const Text(
                        'Order status notifications',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Receive an alert when an order is processed, shipped, '
                          'delivered, or cancelled.',
                        ),
                      ),
                      value: profile.orderNotificationsEnabled,
                      onChanged: _isSaving ? null : _updateOrderPreference,
                      activeColor: Theme.of(context).colorScheme.onPrimary,
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.all(16),
                      secondary: const Icon(Icons.local_offer_outlined),
                      title: const Text(
                        'Offers and new products',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Receive occasional promotions and alerts when new '
                          'clothing is added.',
                        ),
                      ),
                      value: profile.marketingNotificationsEnabled,
                      onChanged: _isSaving ? null : _updateMarketingPreference,
                      activeColor: Theme.of(context).colorScheme.onPrimary,
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (_isSaving) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Your device notification permission must also remain enabled '
                    'in Android settings.',
                    style: TextStyle(color: Color(0xFF666666)),
                  ),
                ],
              ),
            ),
    );
  }
}

Widget dividernoti() {
  return const Divider(
    thickness: 0.3,
    color: Colors.grey,
    indent: 20,
    endIndent: 25,
  );
}
