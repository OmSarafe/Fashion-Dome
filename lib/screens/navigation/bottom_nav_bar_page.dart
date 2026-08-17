import 'package:ecommerence_project/screens/admin/admin_shell.dart';
import 'package:ecommerence_project/screens/navigation/customer_shell.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const BottomNavBar({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();

    if (shop.isLoadingProfile || shop.userProfile == null) {
      return Scaffold(
        body: Center(
          child: shop.profileError == null
              ? const CircularProgressIndicator()
              : const Text('Unable to load your account. Please try again.'),
        ),
      );
    }

    if (shop.isAdmin) {
      return const AdminShell();
    }

    return CustomerShell(selectedIndex: selectedIndex);
  }
}
