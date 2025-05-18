import 'package:ecommerence_project/Account/faqpage.dart';
import 'package:ecommerence_project/new_address_page.dart';
import 'package:flutter/material.dart';

import 'Account/notification_setting.dart';

class Addresspage extends StatefulWidget {
  const Addresspage({super.key});

  @override
  State<Addresspage> createState() => _AddresspageState();
}

class _AddresspageState extends State<Addresspage> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _addresses = [
    {
      'title': 'Home',
      'subtitle': '925 S Chugach St #APT 10, Alaska...',
      'tag': 'Default',
    },
    {
      'title': 'Office',
      'subtitle': '2438 6th Ave, Ketchikan, Alaska 9...',
    },
    {
      'title': 'Apartment',
      'subtitle': '2551 Vista Dr #B301, Juneau, Alaska...',
    },
    {
      'title': 'Parent’s House',
      'subtitle': '4821 Ridge Top Cir, Anchorage, Al...',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Address"),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          dividernoti(),
          Padding(
            padding: const EdgeInsets.only(
                right: 20.0, left: 20, top: 10, bottom: 10),
            child: Text(
              "Saved Address"
              "",
              style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black),
            ),
          ),
          Container(
            height: 350,
            child: ListView.builder(
              itemCount: _addresses.length,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final address = _addresses[index];
                final selected = _selectedIndex == index;

                return Container(
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: RadioListTile<int>(
                    value: index,
                    groupValue: _selectedIndex,
                    onChanged: (value) {
                      setState(() {
                        _selectedIndex = value!;
                      });
                    },
                    // contentPadding: EdgeInsets.all(16),
                    controlAffinity: ListTileControlAffinity.trailing,
                    activeColor: Colors.black,
                    title: Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 30),
                        SizedBox(width: 8),
                        Text(
                          address['title']!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (address.containsKey('tag')) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              address['tag']!,
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(left: 38),
                      child: Text(
                        address['subtitle']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0,left: 20),
            child: GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NewAddressPage()), // Replace SecondPage with your target widget
                );
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),

                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    Text("Add New Address",style: TextStyle(fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,color: Colors.black),)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
