import 'package:ecommerence_project/account.dart';
import 'package:ecommerence_project/cartpage.dart';
import 'package:ecommerence_project/savedpage.dart';
import 'package:ecommerence_project/search.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  BottomNavBar({this.selectedIndex = 0});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  final List<String> _labels = [
    'Home',
    'Search',
    'Saved',
    'Cart',
    'Account',
  ];

  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.search,
    Icons.favorite_border_outlined,
    Icons.shopping_cart_outlined,
    Icons.account_circle_outlined,
  ];

  final List<Widget> _screens = [
    DiscoverScreen(),
    Search(),
    Savedpage(),
    Cartpage(),
    Account()
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: List.generate(_labels.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _labels[index],
          );
        }),
      ),
    );
  }
}
