import 'package:ecommerence_project/screens/account/account_page.dart';
import 'package:ecommerence_project/screens/cart/cart_page.dart';
import 'package:ecommerence_project/screens/catalog/home_page.dart';
import 'package:ecommerence_project/screens/catalog/saved_page.dart';
import 'package:ecommerence_project/screens/catalog/search_page.dart';
import 'package:flutter/material.dart';

class CustomerShell extends StatefulWidget {
  CustomerShell({
    super.key,
    this.selectedIndex = 0,
    List<Widget>? screens,
  }) : screens = screens ??
            [
              DiscoverScreen(),
              Search(),
              Savedpage(),
              Cartpage(),
              const Account(),
            ];

  final int selectedIndex;
  final List<Widget> screens;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  static const _labels = ['Home', 'Search', 'Saved', 'Cart', 'Account'];
  static const _icons = [
    Icons.home_outlined,
    Icons.search,
    Icons.favorite_border_rounded,
    Icons.shopping_cart_outlined,
    Icons.person_outline_rounded,
  ];
  static const _selectedIcons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.favorite_rounded,
    Icons.shopping_cart_rounded,
    Icons.person_rounded,
  ];

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    assert(widget.screens.length == _labels.length);
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: widget.screens,
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SizedBox(
                height: 72,
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  iconSize: 24,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  onTap: (index) => setState(() => _selectedIndex = index),
                  items: List.generate(
                    _labels.length,
                    (index) => BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Icon(_icons[index]),
                      ),
                      activeIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Icon(_selectedIcons[index]),
                      ),
                      label: _labels[index],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
