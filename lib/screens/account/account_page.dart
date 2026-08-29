import 'package:ecommerence_project/screens/account/faq_page.dart';
import 'package:ecommerence_project/screens/account/appearance_page.dart';
import 'package:ecommerence_project/screens/account/fit_profile_page.dart';
import 'package:ecommerence_project/screens/account/help_center_page.dart';
import 'package:ecommerence_project/screens/account/my_orders_page.dart';
import 'package:ecommerence_project/screens/account/notification_settings_page.dart';
import 'package:ecommerence_project/screens/account/privacy_policy_page.dart';
import 'package:ecommerence_project/screens/auth/login_page.dart';
import 'package:ecommerence_project/screens/notifications/notifications_page.dart';
import 'package:ecommerence_project/screens/account/address_page.dart';
import 'package:ecommerence_project/screens/account/my_details_page.dart';
import 'package:ecommerence_project/screens/checkout/payment_page.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/services/auth_service.dart';
import 'package:ecommerence_project/services/fit_profile_service.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:ecommerence_project/widgets/basicwidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  Future<void> _deleteAccount() async {
    final authService = AuthService();
    final userId = authService.currentUser?.uid;
    final usesPassword = authService.currentUserUsesPassword;
    final passwordController = TextEditingController();
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes your profile, favourites, cart, '
              'orders, and Firebase login. This cannot be undone.',
            ),
            if (usesPassword) ...[
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm your password',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              const Text(
                'Google will ask you to confirm your identity. Your Google '
                'account itself will not be deleted.',
                style: TextStyle(color: Color(0xFF666666)),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      passwordController.dispose();
      return;
    }

    if (usesPassword && passwordController.text.isEmpty) {
      passwordController.dispose();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your password to continue.')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await authService.deleteCurrentAccount(
        password: usesPassword ? passwordController.text : null,
      );
      if (userId != null) {
        await FitProfileService().deleteProfile(userId: userId);
      }
      if (!rootNavigator.mounted) return;
      rootNavigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (rootNavigator.mounted && rootNavigator.canPop()) {
        rootNavigator.pop();
      }
      if (!mounted) return;
      final message = switch (error.code) {
        'wrong-password' ||
        'invalid-credential' =>
          'The password or Google account could not be verified.',
        'network-request-failed' => 'Check your internet connection.',
        _ => error.message ?? 'Unable to delete the account.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error, stackTrace) {
      debugPrint('Account deletion failed: $error');
      debugPrintStack(
        label: 'Account deletion stack trace',
        stackTrace: stackTrace,
      );
      if (rootNavigator.mounted && rootNavigator.canPop()) {
        rootNavigator.pop();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete the account.')),
      );
    } finally {
      passwordController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final profile = shop.userProfile;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 76,
        titleSpacing: 24,
        title: const Text(
          'Account',
          style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w600,
              fontSize: 32,
              letterSpacing: -1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ResponsiveContent(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.only(top: 4, bottom: 28),
          children: [
            if (profile != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.person_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (profile.isAdmin) const Chip(label: Text('Admin')),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            if (!shop.isAdmin) ...[
              buildMenuItem(Icons.local_shipping_outlined, "My Orders",
                  onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Myorder()),
                );
              }),
              _sectionGap(),
            ],
            buildMenuItem(Icons.person_outline, "My Details", onTap: () {
              if (profile == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Your profile is still loading.')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Mydetails(profile: profile),
                ),
              );
            }),
            if (!shop.isAdmin) ...[
              divider(),
              buildMenuItem(Icons.straighten_outlined, "My Fit Profile",
                  onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FitProfilePage(),
                  ),
                );
              }),
              divider(),
              buildMenuItem(Icons.home_outlined, "Address Book", onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Addresspage()),
                );
              }),
              divider(),
              buildMenuItem(Icons.credit_card_outlined, "Payment Methods",
                  onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage()),
                );
              }),
            ],
            divider(),
            buildMenuItem(Icons.notifications_outlined, "Notifications",
                onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsPage(),
                ),
              );
            }),
            divider(),
            buildMenuItem(Icons.palette_outlined, "Appearance", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppearancePage(),
                ),
              );
            }),
            divider(),
            buildMenuItem(Icons.privacy_tip_outlined, "Privacy Policy",
                onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              );
            }),
            _sectionGap(),
            // Section 3
            buildMenuItem(Icons.help_outline, "FAQs", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Faqpage(),
                ),
              );
            }),
            divider(),
            buildMenuItem(Icons.headset_mic_outlined, "Help Center", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HelpcenterPage(),
                ),
              );
            }),
            _sectionGap(),
            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'GeneralSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => showLogoutDialog(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_forever_outlined, color: Colors.red),
              title: const Text(
                'Delete account',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'GeneralSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: _deleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildMenuItem(IconData icon, String title,
    {Color? iconColor, void Function()? onTap}) {
  return Builder(
    builder: (context) => ListTile(
      minTileHeight: 58,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Icon(icon, size: 21, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 15,
      ),
      onTap: onTap,
    ),
  );
}

Widget divider() {
  return Divider(
    thickness: 0.5,
    indent: 62,
    endIndent: 12,
  );
}

Widget _sectionGap() => const SizedBox(height: 14);
